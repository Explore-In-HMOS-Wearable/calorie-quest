import { UserProfile } from '../models/UserProfile';
import { Quest } from '../models/Quest';

export function cloneUserProfile(source: UserProfile): UserProfile {
  const cloned: UserProfile = {
    id: source.id,
    createdAt: source.createdAt,
    lastLoginAt: source.lastLoginAt,
    username: source.username,
    avatarId: source.avatarId,
    level: source.level,
    totalXP: source.totalXP,
    coins: source.coins,
    stats: {
      strength: {
        level: source.stats.strength.level,
        currentXP: source.stats.strength.currentXP,
        xpToNextLevel: source.stats.strength.xpToNextLevel
      },
      endurance: {
        level: source.stats.endurance.level,
        currentXP: source.stats.endurance.currentXP,
        xpToNextLevel: source.stats.endurance.xpToNextLevel
      },
      vitality: {
        level: source.stats.vitality.level,
        currentXP: source.stats.vitality.currentXP,
        xpToNextLevel: source.stats.vitality.xpToNextLevel
      },
      focus: {
        level: source.stats.focus.level,
        currentXP: source.stats.focus.currentXP,
        xpToNextLevel: source.stats.focus.xpToNextLevel
      }
    },
    loginStreak: source.loginStreak,
    lastLoginDate: source.lastLoginDate,
    workoutStreak: source.workoutStreak,
    lastWorkoutDate: source.lastWorkoutDate,
    settings: {
      weightKg: source.settings.weightKg,
      dailyWaterGoal: source.settings.dailyWaterGoal,
      dailyStepGoal: source.settings.dailyStepGoal,
      questDifficulty: source.settings.questDifficulty,
      notificationsEnabled: source.settings.notificationsEnabled,
      hapticFeedback: source.settings.hapticFeedback
    },
    totalWorkouts: source.totalWorkouts,
    totalWaterGlasses: source.totalWaterGlasses,
    totalMealsLogged: source.totalMealsLogged
  };
  return cloned;
}

export function applyUserProfileUpdates(target: UserProfile, updates: Partial<UserProfile>): void {
  if (updates.id !== undefined) {
    target.id = updates.id;
  }
  if (updates.createdAt !== undefined) {
    target.createdAt = updates.createdAt;
  }
  if (updates.lastLoginAt !== undefined) {
    target.lastLoginAt = updates.lastLoginAt;
  }
  if (updates.username !== undefined) {
    target.username = updates.username;
  }
  if (updates.avatarId !== undefined) {
    target.avatarId = updates.avatarId;
  }
  if (updates.level !== undefined) {
    target.level = updates.level;
  }
  if (updates.totalXP !== undefined) {
    target.totalXP = updates.totalXP;
  }
  if (updates.coins !== undefined) {
    target.coins = updates.coins;
  }
  if (updates.stats !== undefined) {
    target.stats = updates.stats;
  }
  if (updates.loginStreak !== undefined) {
    target.loginStreak = updates.loginStreak;
  }
  if (updates.lastLoginDate !== undefined) {
    target.lastLoginDate = updates.lastLoginDate;
  }
  if (updates.workoutStreak !== undefined) {
    target.workoutStreak = updates.workoutStreak;
  }
  if (updates.lastWorkoutDate !== undefined) {
    target.lastWorkoutDate = updates.lastWorkoutDate;
  }
  if (updates.settings !== undefined) {
    target.settings = updates.settings;
  }
  if (updates.totalWorkouts !== undefined) {
    target.totalWorkouts = updates.totalWorkouts;
  }
  if (updates.totalWaterGlasses !== undefined) {
    target.totalWaterGlasses = updates.totalWaterGlasses;
  }
  if (updates.totalMealsLogged !== undefined) {
    target.totalMealsLogged = updates.totalMealsLogged;
  }
}

export function applyQuestUpdates(target: Quest, updates: Partial<Quest>): void {
  if (updates.id !== undefined) {
    target.id = updates.id;
  }
  if (updates.type !== undefined) {
    target.type = updates.type;
  }
  if (updates.title !== undefined) {
    target.title = updates.title;
  }
  if (updates.description !== undefined) {
    target.description = updates.description;
  }
  if (updates.requirement !== undefined) {
    target.requirement = updates.requirement;
  }
  if (updates.xpReward !== undefined) {
    target.xpReward = updates.xpReward;
  }
  if (updates.coinReward !== undefined) {
    target.coinReward = updates.coinReward;
  }
  if (updates.badgeReward !== undefined) {
    target.badgeReward = updates.badgeReward;
  }
  if (updates.startDate !== undefined) {
    target.startDate = updates.startDate;
  }
  if (updates.endDate !== undefined) {
    target.endDate = updates.endDate;
  }
  if (updates.progress !== undefined) {
    target.progress = updates.progress;
  }
  if (updates.targetProgress !== undefined) {
    target.targetProgress = updates.targetProgress;
  }
  if (updates.completed !== undefined) {
    target.completed = updates.completed;
  }
  if (updates.claimedReward !== undefined) {
    target.claimedReward = updates.claimedReward;
  }
}

