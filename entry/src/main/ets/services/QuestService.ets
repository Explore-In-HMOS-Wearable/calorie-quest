import { Quest, QuestType, QuestTemplates, QuestTemplate } from '../models/Quest';
import { DailyLog, WorkoutSession } from '../models/DailyLog';
import { DataService } from './DataService';
import { formatDate, getStartOfWeek } from '../utils/DateUtils';

export class QuestService {
  private static instance: QuestService;

  private constructor() {}

  static getInstance(): QuestService {
    if (!QuestService.instance) {
      QuestService.instance = new QuestService();
    }
    return QuestService.instance;
  }

  async generateDailyQuests(): Promise<Quest[]> {
    const today = formatDate(new Date());
    const dataService = DataService.getInstance();
    const existingQuests = dataService.getActiveQuests();

    // Check if today's quests already exist
    const todayQuests = existingQuests.filter(
      q => q.type === 'daily' && q.startDate === today
    );

    if (todayQuests.length >= 3) {
      return todayQuests;
    }

    // Generate 3 random daily quests
    const allTemplates = QuestTemplates.daily;
    const templates: QuestTemplate[] = [];
    for (let i = 0; i < allTemplates.length; i++) {
      templates.push(allTemplates[i]);
    }
    const selectedQuests: Quest[] = [];

    for (let i = 0; i < 3; i++) {
      if (templates.length === 0) {
        break;
      }

      const randomIndex = Math.floor((Date.now() % 1000) / 1000 * templates.length) % templates.length;
      const template = templates.splice(randomIndex, 1)[0];

      const quest: Quest = {
        id: `${template.id}_${Date.now()}_${i}`,
        type: 'daily' as QuestType,
        title: template.title,
        description: template.description,
        requirement: template.requirement,
        xpReward: template.xpReward,
        coinReward: template.coinReward,
        badgeReward: template.badgeReward,
        startDate: today,
        endDate: today,
        progress: 0,
        targetProgress: template.requirement.target,
        completed: false,
        claimedReward: false
      };

      selectedQuests.push(quest);
    }

    // Add to existing quests
    const filteredQuests = existingQuests.filter(q => q.startDate >= today);
    const updatedQuests: Quest[] = [];
    for (let i = 0; i < filteredQuests.length; i++) {
      updatedQuests.push(filteredQuests[i]);
    }
    for (let i = 0; i < selectedQuests.length; i++) {
      updatedQuests.push(selectedQuests[i]);
    }
    
    const activeQuests = dataService.getActiveQuests();
    activeQuests.length = 0;
    for (let i = 0; i < updatedQuests.length; i++) {
      activeQuests.push(updatedQuests[i]);
    }
    await dataService.saveQuests();

    return selectedQuests;
  }

  async generateWeeklyQuests(): Promise<Quest[]> {
    const weekStart = formatDate(getStartOfWeek(new Date()));
    const weekEnd = formatDate(new Date(getStartOfWeek(new Date()).getTime() + 6 * 24 * 60 * 60 * 1000));
    const dataService = DataService.getInstance();
    const existingQuests = dataService.getActiveQuests();

    // Check if this week's quests already exist
    const weeklyQuests = existingQuests.filter(
      q => q.type === 'weekly' && q.startDate === weekStart
    );

    if (weeklyQuests.length >= 2) {
      return weeklyQuests;
    }

    // Generate 2 weekly quests
    const weeklyTemplates = QuestTemplates.weekly;
    const selectedQuests: Quest[] = [];
    
    for (let i = 0; i < weeklyTemplates.length; i++) {
      const template = weeklyTemplates[i];
      const quest: Quest = {
        id: `${template.id}_${Date.now()}_${i}`,
        type: 'weekly' as QuestType,
        title: template.title,
        description: template.description,
        requirement: template.requirement,
        xpReward: template.xpReward,
        coinReward: template.coinReward,
        badgeReward: template.badgeReward,
        startDate: weekStart,
        endDate: weekEnd,
        progress: 0,
        targetProgress: template.requirement.target,
        completed: false,
        claimedReward: false
      };
      selectedQuests.push(quest);
    }

    // Add to existing quests
    const updatedQuests: Quest[] = [];
    for (let i = 0; i < existingQuests.length; i++) {
      updatedQuests.push(existingQuests[i]);
    }
    for (let i = 0; i < selectedQuests.length; i++) {
      updatedQuests.push(selectedQuests[i]);
    }
    
    const activeQuests = dataService.getActiveQuests();
    activeQuests.length = 0;
    for (let i = 0; i < updatedQuests.length; i++) {
      activeQuests.push(updatedQuests[i]);
    }
    await dataService.saveQuests();

    return selectedQuests;
  }

  async updateQuestProgress(dailyLog: DailyLog): Promise<string[]> {
    const dataService = DataService.getInstance();
    const quests = dataService.getActiveQuests();
    const completedQuestIds: string[] = [];

    for (const quest of quests) {
      if (quest.completed) {
        continue;
      }

      const oldProgress = quest.progress;
      quest.progress = this.calculateQuestProgress(quest, dailyLog);

      if (quest.progress >= quest.targetProgress && !quest.completed) {
        quest.completed = true;
        completedQuestIds.push(quest.id);
      }
    }

    await dataService.saveQuests();
    return completedQuestIds;
  }

  private calculateQuestProgress(quest: Quest, dailyLog: DailyLog): number {
    const req = quest.requirement;

    switch (req.type) {
      case 'workout_count':
        if (req.workoutType) {
          return dailyLog.workouts.filter(w => w.type === req.workoutType).length;
        }
        return dailyLog.workouts.length;

      case 'workout_duration':
        const totalDuration = dailyLog.workouts.reduce((sum, w) => sum + w.durationMinutes, 0);
        return totalDuration;

      case 'steps':
        return dailyLog.steps;

      case 'water':
        return dailyLog.waterLogs.length;

      case 'meals':
        if (req.mealQuality) {
          return dailyLog.meals.filter(m => m.qualityRating >= req.mealQuality!).length;
        }
        return dailyLog.meals.length;

      case 'calories':
        const totalCalories = dailyLog.workouts.reduce((sum, w) => sum + w.caloriesBurned, 0);
        return totalCalories;

      default:
        return 0;
    }
  }

  async claimQuestReward(questId: string): Promise<boolean> {
    const dataService = DataService.getInstance();
    const profile = dataService.getUserProfile();
    const quest = dataService.getActiveQuests().find(q => q.id === questId);

    if (!quest || !quest.completed || quest.claimedReward || !profile) {
      return false;
    }

    // Award rewards
    profile.totalXP += quest.xpReward;
    profile.coins += quest.coinReward;
    quest.claimedReward = true;

    // Check for badge reward
    if (quest.badgeReward) {
      await dataService.unlockBadge(quest.badgeReward);
    }

    await dataService.updateUserProfile(profile);
    await dataService.saveQuests();

    return true;
  }

  async cleanupOldQuests(): Promise<void> {
    const today = formatDate(new Date());
    const dataService = DataService.getInstance();
    const quests = dataService.getActiveQuests();

    // Remove quests older than their end date
    const filteredQuests = quests.filter(q => q.endDate >= today);
    
    const activeQuests = dataService.getActiveQuests();
    activeQuests.length = 0;
    for (let i = 0; i < filteredQuests.length; i++) {
      activeQuests.push(filteredQuests[i]);
    }
    await dataService.saveQuests();
  }
}

