import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { UserProfile, DEFAULT_USER_PROFILE } from '../models/UserProfile';
import { DailyLog, createEmptyDailyLog } from '../models/DailyLog';
import { Quest } from '../models/Quest';
import { Badge, BadgeDefinitions } from '../models/Badge';
import { formatDate } from '../utils/DateUtils';
import { cloneUserProfile, applyUserProfileUpdates, applyQuestUpdates } from './DataServiceUtils';

const STORAGE_NAME = 'CalorieQuestData';
const KEY_USER_PROFILE = 'user_profile';
const KEY_DAILY_LOG_PREFIX = 'daily_log_';
const KEY_QUESTS = 'quests';
const KEY_BADGES = 'badges';

export class DataService {
  private static instance: DataService;
  private context: common.UIAbilityContext | null = null;
  private dataStore: preferences.Preferences | null = null;
  private userProfile: UserProfile | null = null;
  private todayLog: DailyLog | null = null;
  private activeQuests: Quest[] = [];
  private badges: Badge[] = [];

  private constructor() {}

  static getInstance(): DataService {
    if (!DataService.instance) {
      DataService.instance = new DataService();
    }
    return DataService.instance;
  }

  async initialize(context?: common.UIAbilityContext): Promise<void> {
    try {
      if (context) {
        this.context = context;
      }
      if (!this.context) {
        console.error('[DataService] Context not provided');
        return;
      }
      this.dataStore = await preferences.getPreferences(this.context, STORAGE_NAME);
      await this.loadUserProfile();
      await this.loadTodayLog();
      await this.loadQuests();
      await this.loadBadges();
      console.info('[DataService] Initialized successfully');
    } catch (error) {
      console.error('[DataService] Initialization failed:', error);
    }
  }

  async loadUserProfile(): Promise<UserProfile> {
    if (!this.dataStore) {
      throw new Error('DataStore not initialized');
    }

    try {
      const profileJson = await this.dataStore.get(KEY_USER_PROFILE, '');
      if (profileJson) {
        this.userProfile = JSON.parse(profileJson as string) as UserProfile;
      } else {
        this.userProfile = cloneUserProfile(DEFAULT_USER_PROFILE);
        this.userProfile.id = `user_${Date.now()}`;
        this.userProfile.createdAt = Date.now();
        this.userProfile.lastLoginAt = Date.now();
        await this.saveUserProfile();
      }
      return this.userProfile;
    } catch (error) {
      console.error('[DataService] Failed to load user profile:', error);
      this.userProfile = DEFAULT_USER_PROFILE;
      return this.userProfile;
    }
  }

  async saveUserProfile(): Promise<void> {
    if (!this.dataStore || !this.userProfile) {
      return;
    }

    try {
      await this.dataStore.put(KEY_USER_PROFILE, JSON.stringify(this.userProfile));
      await this.dataStore.flush();
    } catch (error) {
      console.error('[DataService] Failed to save user profile:', error);
    }
  }

  getUserProfile(): UserProfile | null {
    return this.userProfile;
  }

  async updateUserProfile(updates: Partial<UserProfile>): Promise<void> {
    if (!this.userProfile) {
      return;
    }

    applyUserProfileUpdates(this.userProfile, updates);
    await this.saveUserProfile();
  }

  async loadTodayLog(): Promise<DailyLog> {
    const today = formatDate(new Date());
    return this.loadDailyLog(today);
  }

  async loadDailyLog(date: string): Promise<DailyLog> {
    if (!this.dataStore) {
      throw new Error('DataStore not initialized');
    }

    try {
      const logJson = await this.dataStore.get(KEY_DAILY_LOG_PREFIX + date, '');
      if (logJson) {
        this.todayLog = JSON.parse(logJson as string) as DailyLog;
      } else {
        this.todayLog = createEmptyDailyLog(date);
        await this.saveDailyLog(this.todayLog);
      }
      return this.todayLog;
    } catch (error) {
      console.error(`[DataService] Failed to load daily log for ${date}:`, error);
      this.todayLog = createEmptyDailyLog(date);
      return this.todayLog;
    }
  }

  async saveDailyLog(log: DailyLog): Promise<void> {
    if (!this.dataStore) {
      return;
    }

    try {
      log.lastUpdatedAt = Date.now();
      await this.dataStore.put(KEY_DAILY_LOG_PREFIX + log.date, JSON.stringify(log));
      await this.dataStore.flush();

      if (log.date === formatDate(new Date())) {
        this.todayLog = log;
      }
    } catch (error) {
      console.error('[DataService] Failed to save daily log:', error);
    }
  }

  getTodayLog(): DailyLog | null {
    return this.todayLog;
  }

  async loadQuests(): Promise<Quest[]> {
    if (!this.dataStore) {
      throw new Error('DataStore not initialized');
    }

    try {
      const questsJson = await this.dataStore.get(KEY_QUESTS, '[]');
      this.activeQuests = JSON.parse(questsJson as string) as Quest[];
      return this.activeQuests;
    } catch (error) {
      console.error('[DataService] Failed to load quests:', error);
      this.activeQuests = [];
      return this.activeQuests;
    }
  }

  async saveQuests(): Promise<void> {
    if (!this.dataStore) {
      return;
    }

    try {
      await this.dataStore.put(KEY_QUESTS, JSON.stringify(this.activeQuests));
      await this.dataStore.flush();
    } catch (error) {
      console.error('[DataService] Failed to save quests:', error);
    }
  }

  getActiveQuests(): Quest[] {
    return this.activeQuests;
  }

  async updateQuest(questId: string, updates: Partial<Quest>): Promise<void> {
    const questIndex = this.activeQuests.findIndex(q => q.id === questId);
    if (questIndex >= 0) {
      applyQuestUpdates(this.activeQuests[questIndex], updates);
      await this.saveQuests();
    }
  }

  async loadBadges(): Promise<Badge[]> {
    if (!this.dataStore) {
      throw new Error('DataStore not initialized');
    }

    try {
      const badgesJson = await this.dataStore.get(KEY_BADGES, '');
      if (badgesJson) {
        this.badges = JSON.parse(badgesJson as string) as Badge[];
      } else {
        const allDefs = BadgeDefinitions.getAllDefinitions();
        this.badges = [];
        for (let i = 0; i < allDefs.length; i++) {
          const def = allDefs[i];
          const badge: Badge = {
            id: def.id,
            name: def.name,
            description: def.description,
            iconId: def.iconId,
            rarity: def.rarity,
            unlocked: false
          };
          this.badges.push(badge);
        }
        await this.saveBadges();
      }
      return this.badges;
    } catch (error) {
      console.error('[DataService] Failed to load badges:', error);
      this.badges = [];
      return this.badges;
    }
  }

  async saveBadges(): Promise<void> {
    if (!this.dataStore) {
      return;
    }

    try {
      await this.dataStore.put(KEY_BADGES, JSON.stringify(this.badges));
      await this.dataStore.flush();
    } catch (error) {
      console.error('[DataService] Failed to save badges:', error);
    }
  }

  getBadges(): Badge[] {
    return this.badges;
  }

  async unlockBadge(badgeId: string): Promise<boolean> {
    const badge = this.badges.find(b => b.id === badgeId);
    if (badge && !badge.unlocked) {
      badge.unlocked = true;
      badge.unlockedAt = Date.now();
      await this.saveBadges();
      return true;
    }
    return false;
  }

  refreshData(): void {
    const today = formatDate(new Date());
    if (!this.todayLog || this.todayLog.date !== today) {
      this.loadTodayLog();
    }
  }

  async clearAllData(): Promise<void> {
    if (!this.dataStore) {
      return;
    }

    try {
      await this.dataStore.clear();
      await this.dataStore.flush();
      await this.initialize();
    } catch (error) {
      console.error('[DataService] Failed to clear data:', error);
    }
  }
}
