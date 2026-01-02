import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { notificationManager } from '@kit.NotificationKit';
import { common } from '@kit.AbilityKit';
import { DataService } from './DataService';
import { QuestService } from './QuestService';
import { formatDate } from '../utils/DateUtils';

export class BackgroundTaskService {
  private static instance: BackgroundTaskService;
  private context: common.UIAbilityContext | null = null;
  private timerId: number = -1;

  private constructor() {}

  static getInstance(): BackgroundTaskService {
    if (!BackgroundTaskService.instance) {
      BackgroundTaskService.instance = new BackgroundTaskService();
    }
    return BackgroundTaskService.instance;
  }

  initialize(context?: common.UIAbilityContext): void {
    console.info('[BackgroundTaskService] Initializing');
    if (context) {
      this.context = context;
    }
    this.schedulePeriodicTasks();
  }

  cleanup(): void {
    if (this.timerId >= 0) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  private schedulePeriodicTasks(): void {
    this.timerId = setInterval(() => {
      this.checkDailyReset();
      this.checkQuestProgress();
    }, 60 * 60 * 1000);
  }

  private async checkDailyReset(): Promise<void> {
    const dataService = DataService.getInstance();
    const profile = dataService.getUserProfile();

    if (!profile) {
      return;
    }

    const today = formatDate(new Date());

    if (profile.lastLoginDate !== today) {
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      const yesterdayStr = formatDate(yesterday);

      if (profile.lastLoginDate === yesterdayStr) {
        profile.loginStreak++;
      } else {
        profile.loginStreak = 1;
      }

      profile.lastLoginDate = today;
      await dataService.updateUserProfile(profile);
      await QuestService.getInstance().generateDailyQuests();
      await this.sendNotification('New Day, New Quests!', 'Your daily quests are ready!');
    }

    const dayOfWeek = new Date().getDay();
    if (dayOfWeek === 1) {
      await QuestService.getInstance().generateWeeklyQuests();
    }

    await QuestService.getInstance().cleanupOldQuests();
  }

  private async checkQuestProgress(): Promise<void> {
    const dataService = DataService.getInstance();
    const profile = dataService.getUserProfile();

    if (!profile || !profile.settings.notificationsEnabled) {
      return;
    }

    const quests = dataService.getActiveQuests();
    const today = formatDate(new Date());

    const almostComplete = quests.filter(
      q => !q.completed &&
           q.endDate === today &&
           q.progress >= q.targetProgress * 0.8
    );

    if (almostComplete.length > 0) {
      await this.sendNotification(
        'Almost There!',
        `You're close to completing ${almostComplete.length} quest(s)!`
      );
    }
  }

  async sendNotification(title: string, text: string): Promise<void> {
    try {
      const notificationRequest: notificationManager.NotificationRequest = {
        id: Date.now(),
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: title,
            text: text
          }
        }
      };

      await notificationManager.publish(notificationRequest);
      console.info('[BackgroundTaskService] Notification sent:', title);
    } catch (error) {
      console.error('[BackgroundTaskService] Failed to send notification:', error);
    }
  }

  async sendQuestCompleteNotification(questTitle: string, xpReward: number): Promise<void> {
    await this.sendNotification(
      'Quest Complete! 🎉',
      `${questTitle} - Earned ${xpReward} XP!`
    );
  }

  async sendLevelUpNotification(stat: string, level: number): Promise<void> {
    await this.sendNotification(
      'Level Up! ⭐',
      `${stat} reached level ${level}!`
    );
  }
}
