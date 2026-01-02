export interface DailyLog {
  id: string;
  date: string; // YYYY-MM-DD
  
  // Activity
  workouts: WorkoutSession[];
  steps: number;
  activeMinutes: number;
  
  // Nutrition
  waterLogs: WaterLog[];
  meals: NutritionLog[];
  
  // Progress
  xpEarned: XPBreakdown;
  coinsEarned: number;
  questsCompleted: string[];
  
  // Meta
  createdAt: number;
  lastUpdatedAt: number;
}

export interface WorkoutSession {
  id: string;
  type: WorkoutType;
  startTime: number;
  endTime: number;
  durationMinutes: number;
  caloriesBurned: number;
  heartRateAvg?: number;
  notes?: string;
  xpAwarded: XPBreakdown;
}

export type WorkoutType = 'cardio' | 'strength' | 'hiit' | 'yoga' | 'walking' | 'cycling' | 'other';

export interface WaterLog {
  id: string;
  timestamp: number;
  amountMl: number;
  xpAwarded: number;
}

export interface NutritionLog {
  id: string;
  timestamp: number;
  mealType: 'breakfast' | 'lunch' | 'dinner' | 'snack';
  qualityRating: 1 | 2 | 3 | 4 | 5;
  notes?: string;
  tags?: string[];
  xpAwarded: XPBreakdown;
}

export interface XPBreakdown {
  strength: number;
  endurance: number;
  vitality: number;
  focus: number;
  total: number;
}

export const createEmptyDailyLog = (date: string): DailyLog => ({
  id: `log_${date}`,
  date,
  workouts: [],
  steps: 0,
  activeMinutes: 0,
  waterLogs: [],
  meals: [],
  xpEarned: { strength: 0, endurance: 0, vitality: 0, focus: 0, total: 0 },
  coinsEarned: 0,
  questsCompleted: [],
  createdAt: Date.now(),
  lastUpdatedAt: Date.now()
});

