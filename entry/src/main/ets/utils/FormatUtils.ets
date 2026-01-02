export function formatNumber(num: number): string {
  if (num >= 1000000) {
    return (num / 1000000).toFixed(1) + 'M';
  }
  if (num >= 1000) {
    return (num / 1000).toFixed(1) + 'K';
  }
  return num.toString();
}

export function formatCalories(calories: number): string {
  return `${calories} cal`;
}

export function formatSteps(steps: number): string {
  return formatNumber(steps);
}

export function formatWaterAmount(ml: number): string {
  if (ml >= 1000) {
    return `${(ml / 1000).toFixed(1)}L`;
  }
  return `${ml}ml`;
}

export function formatPercentage(current: number, target: number): string {
  const percentage = Math.min(Math.floor((current / target) * 100), 100);
  return `${percentage}%`;
}

export function getStatEmoji(statName: string): string {
  const emojiMap: Record<string, string> = {
    'strength': '💪',
    'endurance': '🏃',
    'vitality': '💧',
    'focus': '🧠'
  };
  return emojiMap[statName.toLowerCase()] || '⭐';
}

export function getWorkoutTypeLabel(type: string): string {
  const labelMap: Record<string, string> = {
    'cardio': 'Cardio',
    'strength': 'Strength',
    'hiit': 'HIIT',
    'yoga': 'Yoga',
    'walking': 'Walking',
    'cycling': 'Cycling',
    'other': 'Other'
  };
  return labelMap[type] || 'Workout';
}

export function getMealTypeLabel(type: string): string {
  const labelMap: Record<string, string> = {
    'breakfast': 'Breakfast',
    'lunch': 'Lunch',
    'dinner': 'Dinner',
    'snack': 'Snack'
  };
  return labelMap[type] || 'Meal';
}

export function getStarDisplay(rating: number): string {
  return '⭐'.repeat(rating);
}

