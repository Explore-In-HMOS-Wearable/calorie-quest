import { WorkoutType } from './DailyLog';

export interface Quest {
  id: string;
  type: QuestType;
  title: string;
  description: string;
  
  // Requirements
  requirement: QuestRequirement;
  
  // Rewards
  xpReward: number;
  coinReward: number;
  badgeReward?: string;
  
  // Timing
  startDate: string; // YYYY-MM-DD
  endDate: string;
  
  // Progress
  progress: number;
  targetProgress: number;
  completed: boolean;
  claimedReward: boolean;
}

export type QuestType = 'daily' | 'weekly' | 'milestone';

export interface QuestRequirement {
  type: 'workout_count' | 'workout_duration' | 'steps' | 'water' | 'meals' | 'calories' | 'stat_level';
  target: number;
  workoutType?: WorkoutType;
  mealQuality?: number;
}

export interface QuestProgress {
  questId: string;
  progress: number;
  completed: boolean;
  completedAt?: number;
}

export interface QuestTemplate {
  id: string;
  title: string;
  description: string;
  requirement: QuestRequirement;
  xpReward: number;
  coinReward: number;
  badgeReward?: string;
}

export class QuestTemplates {
  static readonly daily: QuestTemplate[] = [
    {
      id: 'daily_workout_20',
      title: 'Morning Exercise',
      description: 'Complete a 20-minute workout',
      requirement: { type: 'workout_duration', target: 20 } as QuestRequirement,
      xpReward: 50,
      coinReward: 15
    } as QuestTemplate,
    {
      id: 'daily_water_8',
      title: 'Hydration Hero',
      description: 'Drink 8 glasses of water',
      requirement: { type: 'water', target: 8 } as QuestRequirement,
      xpReward: 30,
      coinReward: 10
    } as QuestTemplate,
    {
      id: 'daily_steps_10k',
      title: 'Step Champion',
      description: 'Walk 10,000 steps',
      requirement: { type: 'steps', target: 10000 } as QuestRequirement,
      xpReward: 35,
      coinReward: 10
    } as QuestTemplate,
    {
      id: 'daily_meals_3',
      title: 'Mindful Eating',
      description: 'Log 3 quality meals',
      requirement: { type: 'meals', target: 3, mealQuality: 3 } as QuestRequirement,
      xpReward: 40,
      coinReward: 12
    } as QuestTemplate,
    {
      id: 'daily_cardio',
      title: 'Cardio Quest',
      description: 'Complete a cardio workout',
      requirement: { type: 'workout_count', target: 1, workoutType: 'cardio' } as QuestRequirement,
      xpReward: 45,
      coinReward: 15
    } as QuestTemplate
  ];

  static readonly weekly: QuestTemplate[] = [
    {
      id: 'weekly_workout_5',
      title: 'Epic Training Week',
      description: 'Complete 5 workouts this week',
      requirement: { type: 'workout_count', target: 5 } as QuestRequirement,
      xpReward: 200,
      coinReward: 100,
      badgeReward: 'weekly_warrior'
    } as QuestTemplate,
    {
      id: 'weekly_water_streak',
      title: 'Hydration Master',
      description: 'Hit water goal 7 days in a row',
      requirement: { type: 'water', target: 7 } as QuestRequirement,
      xpReward: 150,
      coinReward: 80
    } as QuestTemplate
  ];
}

