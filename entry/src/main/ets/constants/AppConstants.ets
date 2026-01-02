export const APP_NAME = 'CalorieQuest';
export const APP_VERSION = '1.0.0';

export const MAX_XP_PER_STAT_PER_DAY = 200;
export const BASE_XP_FORMULA_EXPONENT = 1.5;
export const LEVEL_UP_COIN_REWARD = 50;
export const STAT_LEVEL_UP_COIN_REWARD = 10;

export const STREAK_BONUS_PER_DAY = 0.02;
export const MAX_STREAK_BONUS = 0.6;
export const MAX_STREAK_DAYS = 30;

export const MAX_WORKOUTS_PER_DAY = 5;
export const MAX_WATER_LOGS_PER_DAY = 15;
export const MAX_MEALS_PER_DAY = 6;
export const MIN_WORKOUT_DURATION = 5;
export const MAX_WORKOUT_DURATION = 180;
export const MIN_WORKOUT_GAP_MINUTES = 10;

export const DEFAULT_WATER_GOAL_ML = 2000;
export const DEFAULT_STEP_GOAL = 10000;
export const DEFAULT_WATER_SERVING_ML = 250;

export class WorkoutMETs {
  static readonly cardio: number = 7.0;
  static readonly strength: number = 5.0;
  static readonly hiit: number = 8.0;
  static readonly yoga: number = 3.0;
  static readonly walking: number = 3.5;
  static readonly cycling: number = 6.5;
  static readonly other: number = 5.0;
}

export const COLOR_STRENGTH = '#FF6B6B';
export const COLOR_ENDURANCE = '#4ECDC4';
export const COLOR_VITALITY = '#45B7D1';
export const COLOR_FOCUS = '#FFA07A';
export const COLOR_XP = '#FFD700';
export const COLOR_COIN = '#FFD700';
export const COLOR_SUCCESS = '#2ECC71';
export const COLOR_WARNING = '#F39C12';
export const COLOR_DANGER = '#E74C3C';

export const ANIMATION_DURATION_SHORT = 200;
export const ANIMATION_DURATION_MEDIUM = 400;
export const ANIMATION_DURATION_LONG = 600;

export const DAILY_QUEST_COUNT = 3;
export const WEEKLY_QUEST_COUNT = 2;
export const DAILY_QUEST_REFRESH_HOUR = 0;

export const STORAGE_KEY_ONBOARDING_COMPLETE = 'onboarding_complete';
export const STORAGE_KEY_LAST_SYNC = 'last_sync';
