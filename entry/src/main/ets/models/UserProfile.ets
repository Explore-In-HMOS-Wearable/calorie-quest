export interface UserProfile {
  id: string;
  createdAt: number;
  lastLoginAt: number;
  username: string;
  avatarId: string;
  level: number;
  totalXP: number;
  coins: number;
  stats: CharacterStats;
  loginStreak: number;
  lastLoginDate: string;
  workoutStreak: number;
  lastWorkoutDate: string;
  settings: UserSettings;
  totalWorkouts: number;
  totalWaterGlasses: number;
  totalMealsLogged: number;
}

export interface CharacterStats {
  strength: StatDetail;
  endurance: StatDetail;
  vitality: StatDetail;
  focus: StatDetail;
}

export interface StatDetail {
  level: number;
  currentXP: number;
  xpToNextLevel: number;
}

export interface UserSettings {
  weightKg: number;
  dailyWaterGoal: number;
  dailyStepGoal: number;
  questDifficulty: 'easy' | 'normal' | 'hard';
  notificationsEnabled: boolean;
  hapticFeedback: boolean;
}

export const DEFAULT_USER_PROFILE: UserProfile = {
  id: '',
  createdAt: Date.now(),
  lastLoginAt: Date.now(),
  username: 'Hero',
  avatarId: 'default',
  level: 1,
  totalXP: 0,
  coins: 0,
  stats: {
    strength: { level: 1, currentXP: 0, xpToNextLevel: 100 },
    endurance: { level: 1, currentXP: 0, xpToNextLevel: 100 },
    vitality: { level: 1, currentXP: 0, xpToNextLevel: 100 },
    focus: { level: 1, currentXP: 0, xpToNextLevel: 100 }
  },
  loginStreak: 0,
  lastLoginDate: '',
  workoutStreak: 0,
  lastWorkoutDate: '',
  settings: {
    weightKg: 70,
    dailyWaterGoal: 2000,
    dailyStepGoal: 10000,
    questDifficulty: 'normal',
    notificationsEnabled: true,
    hapticFeedback: true
  },
  totalWorkouts: 0,
  totalWaterGlasses: 0,
  totalMealsLogged: 0
};
