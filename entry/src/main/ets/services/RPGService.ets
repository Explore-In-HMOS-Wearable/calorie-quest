import { WorkoutType, XPBreakdown } from '../models/DailyLog';
import { UserProfile, CharacterStats, StatDetail } from '../models/UserProfile';
import { DataService } from './DataService';

export interface LevelUpResult {
  levelUps: string[];
  coinsEarned: number;
}

export interface StatUpdateResult {
  stat: StatDetail;
  leveledUp: boolean;
}

export class RPGService {
  private static instance: RPGService;

  private constructor() {}

  static getInstance(): RPGService {
    if (!RPGService.instance) {
      RPGService.instance = new RPGService();
    }
    return RPGService.instance;
  }

  // Types
  private createXPBreakdown(strength: number, endurance: number, vitality: number, focus: number): XPBreakdown {
    return {
      strength: strength,
      endurance: endurance,
      vitality: vitality,
      focus: focus,
      total: strength + endurance + vitality + focus
    };
  }

  // XP Calculation Methods
  calculateWorkoutXP(
    workoutType: WorkoutType,
    durationMinutes: number,
    caloriesBurned: number
  ): XPBreakdown {
    const baseXP = Math.floor(durationMinutes * 0.5 + caloriesBurned * 0.05);
    
    let distribution: XPBreakdown;
    
    switch (workoutType) {
      case 'cardio':
        distribution = {
          strength: Math.floor(baseXP * 0.1),
          endurance: Math.floor(baseXP * 0.6),
          vitality: Math.floor(baseXP * 0.15),
          focus: Math.floor(baseXP * 0.15),
          total: 0
        };
        break;
      case 'strength':
        distribution = {
          strength: Math.floor(baseXP * 0.6),
          endurance: Math.floor(baseXP * 0.1),
          vitality: Math.floor(baseXP * 0.15),
          focus: Math.floor(baseXP * 0.15),
          total: 0
        };
        break;
      case 'hiit':
        distribution = {
          strength: Math.floor(baseXP * 0.35),
          endurance: Math.floor(baseXP * 0.4),
          vitality: Math.floor(baseXP * 0.1),
          focus: Math.floor(baseXP * 0.15),
          total: 0
        };
        break;
      case 'yoga':
        distribution = {
          strength: Math.floor(baseXP * 0.15),
          endurance: Math.floor(baseXP * 0.2),
          vitality: Math.floor(baseXP * 0.4),
          focus: Math.floor(baseXP * 0.25),
          total: 0
        };
        break;
      case 'walking':
        distribution = {
          strength: 0,
          endurance: Math.floor(baseXP * 0.6),
          vitality: Math.floor(baseXP * 0.3),
          focus: Math.floor(baseXP * 0.1),
          total: 0
        };
        break;
      case 'cycling':
        distribution = {
          strength: Math.floor(baseXP * 0.2),
          endurance: Math.floor(baseXP * 0.6),
          vitality: Math.floor(baseXP * 0.1),
          focus: Math.floor(baseXP * 0.1),
          total: 0
        };
        break;
      default:
        distribution = {
          strength: Math.floor(baseXP * 0.25),
          endurance: Math.floor(baseXP * 0.25),
          vitality: Math.floor(baseXP * 0.25),
          focus: Math.floor(baseXP * 0.25),
          total: 0
        };
    }
    
    distribution.total = distribution.strength + distribution.endurance + 
                        distribution.vitality + distribution.focus;
    
    return distribution;
  }

  calculateWaterXP(): XPBreakdown {
    return {
      strength: 0,
      endurance: 0,
      vitality: 2,
      focus: 0,
      total: 2
    };
  }

  calculateMealXP(qualityRating: number): XPBreakdown {
    let xp: XPBreakdown;
    
    switch (qualityRating) {
      case 1:
        xp = { strength: 0, endurance: 0, vitality: -1, focus: -1, total: -2 };
        break;
      case 2:
        xp = { strength: 0, endurance: 0, vitality: 0, focus: 1, total: 1 };
        break;
      case 3:
        xp = { strength: 0, endurance: 0, vitality: 1, focus: 2, total: 3 };
        break;
      case 4:
        xp = { strength: 1, endurance: 0, vitality: 2, focus: 4, total: 7 };
        break;
      case 5:
        xp = { strength: 1, endurance: 0, vitality: 3, focus: 6, total: 10 };
        break;
      default:
        xp = { strength: 0, endurance: 0, vitality: 0, focus: 0, total: 0 };
    }
    
    return xp;
  }

  calculateStepsXP(steps: number): XPBreakdown {
    let xp: XPBreakdown = {
      strength: 0,
      endurance: 0,
      vitality: 0,
      focus: 0,
      total: 0
    };
    
    if (steps >= 5000) {
      xp.endurance += 2;
      xp.vitality += 1;
    }
    if (steps >= 10000) {
      xp.endurance += 3;
    }
    if (steps >= 15000) {
      xp.endurance += 3;
    }
    
    xp.total = xp.strength + xp.endurance + xp.vitality + xp.focus;
    return xp;
  }

  // Stat Update Methods
  async applyXPToProfile(xpBreakdown: XPBreakdown): Promise<LevelUpResult> {
    const dataService = DataService.getInstance();
    const profile = dataService.getUserProfile();
    
    if (!profile) {
      const emptyResult: LevelUpResult = { levelUps: [], coinsEarned: 0 };
      return emptyResult;
    }

    const levelUps: string[] = [];
    let coinsEarned = 0;

    // Apply streak multiplier
    const streakBonus = Math.min(profile.loginStreak * 0.02, 0.6); // Max 60%
    const multiplier = 1 + streakBonus;

    // Update each stat
    const stats = profile.stats;
    
    // Strength
    const strengthXP = Math.floor(xpBreakdown.strength * multiplier);
    if (strengthXP > 0) {
      const result = this.addXPToStat(stats.strength, strengthXP);
      stats.strength = result.stat;
      if (result.leveledUp) {
        levelUps.push('Strength');
        coinsEarned += 10;
      }
    }

    // Endurance
    const enduranceXP = Math.floor(xpBreakdown.endurance * multiplier);
    if (enduranceXP > 0) {
      const result = this.addXPToStat(stats.endurance, enduranceXP);
      stats.endurance = result.stat;
      if (result.leveledUp) {
        levelUps.push('Endurance');
        coinsEarned += 10;
      }
    }

    // Vitality
    const vitalityXP = Math.floor(xpBreakdown.vitality * multiplier);
    if (vitalityXP !== 0) {
      const result = this.addXPToStat(stats.vitality, vitalityXP);
      stats.vitality = result.stat;
      if (result.leveledUp) {
        levelUps.push('Vitality');
        coinsEarned += 10;
      }
    }

    // Focus
    const focusXP = Math.floor(xpBreakdown.focus * multiplier);
    if (focusXP !== 0) {
      const result = this.addXPToStat(stats.focus, focusXP);
      stats.focus = result.stat;
      if (result.leveledUp) {
        levelUps.push('Focus');
        coinsEarned += 10;
      }
    }

    // Update total XP and level
    const totalXPGained = Math.floor(xpBreakdown.total * multiplier);
    profile.totalXP += totalXPGained;
    const newLevel = this.calculateLevelFromXP(profile.totalXP);
    
    if (newLevel > profile.level) {
      profile.level = newLevel;
      levelUps.push(`Overall Level ${newLevel}`);
      coinsEarned += 50;
    }

    profile.coins += coinsEarned;
    await dataService.updateUserProfile(profile);

    const result: LevelUpResult = { levelUps: levelUps, coinsEarned: coinsEarned };
    return result;
  }

  private addXPToStat(stat: StatDetail, xp: number): StatUpdateResult {
    let currentXP = stat.currentXP + xp;
    let level = stat.level;
    let leveledUp = false;

    while (currentXP >= stat.xpToNextLevel) {
      currentXP -= stat.xpToNextLevel;
      level++;
      leveledUp = true;
    }

    const xpToNextLevel = this.calculateXPForNextLevel(level);

    const updatedStat: StatDetail = {
      level: level,
      currentXP: currentXP,
      xpToNextLevel: xpToNextLevel
    };
    
    const result: StatUpdateResult = {
      stat: updatedStat,
      leveledUp: leveledUp
    };
    
    return result;
  }

  calculateXPForNextLevel(currentLevel: number): number {
    return Math.floor(100 * Math.pow(currentLevel, 1.5));
  }

  calculateLevelFromXP(totalXP: number): number {
    let level = 1;
    let xpRequired = 0;
    
    while (xpRequired <= totalXP) {
      xpRequired += this.calculateXPForNextLevel(level);
      if (xpRequired <= totalXP) {
        level++;
      }
    }
    
    return level;
  }

  // Calorie Estimation
  estimateCalories(
    workoutType: WorkoutType,
    durationMinutes: number,
    weightKg: number
  ): number {
    let met: number = 5.0; // default
    
    if (workoutType === 'cardio') {
      met = 7.0;
    } else if (workoutType === 'strength') {
      met = 5.0;
    } else if (workoutType === 'hiit') {
      met = 8.0;
    } else if (workoutType === 'yoga') {
      met = 3.0;
    } else if (workoutType === 'walking') {
      met = 3.5;
    } else if (workoutType === 'cycling') {
      met = 6.5;
    } else {
      met = 5.0;
    }

    const hours = durationMinutes / 60;
    const calories = Math.floor(met * weightKg * hours);

    return calories;
  }

  // Validation Methods
  validateWorkout(durationMinutes: number, caloriesBurned: number): boolean {
    if (durationMinutes < 5 || durationMinutes > 180) {
      return false;
    }
    if (caloriesBurned < 0 || caloriesBurned > 2000) {
      return false;
    }
    return true;
  }

  canLogAnotherWorkout(workoutCount: number): boolean {
    return workoutCount < 5;
  }

  canLogMoreWater(waterCount: number): boolean {
    return waterCount < 15;
  }

  canLogMoreMeals(mealCount: number): boolean {
    return mealCount < 6;
  }
}

