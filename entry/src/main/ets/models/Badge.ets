export interface Badge {
  id: string;
  name: string;
  description: string;
  iconId: string;
  rarity: 'common' | 'rare' | 'epic' | 'legendary';
  unlockedAt?: number;
  unlocked: boolean;
}

export interface Achievement {
  id: string;
  title: string;
  description: string;
  progress: number;
  target: number;
  badgeReward: string;
  completed: boolean;
}

export interface BadgeDefinition {
  id: string;
  name: string;
  description: string;
  iconId: string;
  rarity: 'common' | 'rare' | 'epic' | 'legendary';
}

export class BadgeDefinitions {
  static readonly LEVEL_10: BadgeDefinition = {
    id: 'level_10',
    name: 'Novice Hero',
    description: 'Reach Level 10',
    iconId: 'badge_level_10',
    rarity: 'common'
  };

  static readonly LEVEL_25: BadgeDefinition = {
    id: 'level_25',
    name: 'Seasoned Warrior',
    description: 'Reach Level 25',
    iconId: 'badge_level_25',
    rarity: 'rare'
  };

  static readonly LEVEL_50: BadgeDefinition = {
    id: 'level_50',
    name: 'Elite Champion',
    description: 'Reach Level 50',
    iconId: 'badge_level_50',
    rarity: 'epic'
  };

  static readonly WORKOUT_10: BadgeDefinition = {
    id: 'workout_10',
    name: 'Getting Started',
    description: 'Complete 10 workouts',
    iconId: 'badge_workout_10',
    rarity: 'common'
  };

  static readonly WORKOUT_50: BadgeDefinition = {
    id: 'workout_50',
    name: 'Fitness Enthusiast',
    description: 'Complete 50 workouts',
    iconId: 'badge_workout_50',
    rarity: 'rare'
  };

  static readonly WORKOUT_100: BadgeDefinition = {
    id: 'workout_100',
    name: 'Legendary Athlete',
    description: 'Complete 100 workouts',
    iconId: 'badge_workout_100',
    rarity: 'legendary'
  };

  static readonly STREAK_7: BadgeDefinition = {
    id: 'streak_7',
    name: 'Week Warrior',
    description: '7-day login streak',
    iconId: 'badge_streak_7',
    rarity: 'common'
  };

  static readonly STREAK_30: BadgeDefinition = {
    id: 'streak_30',
    name: 'Dedication Master',
    description: '30-day login streak',
    iconId: 'badge_streak_30',
    rarity: 'epic'
  };

  static readonly WEEKLY_WARRIOR: BadgeDefinition = {
    id: 'weekly_warrior',
    name: 'Weekly Warrior',
    description: 'Complete a weekly quest',
    iconId: 'badge_weekly',
    rarity: 'rare'
  };

  static readonly STRENGTH_25: BadgeDefinition = {
    id: 'strength_25',
    name: 'Mighty Strength',
    description: 'Strength stat reaches 25',
    iconId: 'badge_strength',
    rarity: 'rare'
  };

  static readonly ENDURANCE_25: BadgeDefinition = {
    id: 'endurance_25',
    name: 'Iron Endurance',
    description: 'Endurance stat reaches 25',
    iconId: 'badge_endurance',
    rarity: 'rare'
  };

  static getAllDefinitions(): BadgeDefinition[] {
    return [
      BadgeDefinitions.LEVEL_10,
      BadgeDefinitions.LEVEL_25,
      BadgeDefinitions.LEVEL_50,
      BadgeDefinitions.WORKOUT_10,
      BadgeDefinitions.WORKOUT_50,
      BadgeDefinitions.WORKOUT_100,
      BadgeDefinitions.STREAK_7,
      BadgeDefinitions.STREAK_30,
      BadgeDefinitions.WEEKLY_WARRIOR,
      BadgeDefinitions.STRENGTH_25,
      BadgeDefinitions.ENDURANCE_25
    ];
  }

  static getById(id: string): BadgeDefinition | null {
    const all = BadgeDefinitions.getAllDefinitions();
    for (let i = 0; i < all.length; i++) {
      if (all[i].id === id) {
        return all[i];
      }
    }
    return null;
  }
}

