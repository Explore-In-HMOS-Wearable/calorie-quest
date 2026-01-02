import { DataService } from '../services/DataService';
import { RPGService } from '../services/RPGService';
import { QuestService } from '../services/QuestService';
import { BackgroundTaskService } from '../services/BackgroundTaskService';
import { WorkoutType, WorkoutSession } from '../models/DailyLog';
import { formatDuration } from '../utils/DateUtils';
import { getWorkoutTypeLabel } from '../utils/FormatUtils';

@Component
export struct WorkoutPage {
  @Consume('pathStack') pathStack: NavPathStack;
  @State selectedType: WorkoutType = 'cardio';
  @State isTracking: boolean = false;
  @State startTime: number = 0;
  @State elapsedMinutes: number = 0;
  @State estimatedCalories: number = 0;
  private timerId: number = -1;

  aboutToDisappear() {
    if (this.timerId >= 0) { clearInterval(this.timerId); }
  }

  build() {
    NavDestination() {
      Column() {
        this.buildHeader()
        Scroll() {
          Column({ space: 16 }) {
            if (!this.isTracking) { this.buildWorkoutTypeSelection(); }
            else { this.buildTrackingView(); }
            this.buildActionButton()
          }.padding(16).width('100%')
        }.layoutWeight(1).scrollBar(BarState.Off)
      }.width('100%').height('100%').backgroundColor('#1A1A1A')
    }.hideTitleBar(true)
  }

  @Builder
  buildHeader() {
    Row() {
      Button({ type: ButtonType.Circle }) {
        Text('←').fontSize(20).fontColor('#FFFFFF')
      }.backgroundColor('#2A2A2A').width(40).height(40).onClick(() => { this.pathStack.pop(); })
      Text('Workout').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
        .layoutWeight(1).textAlign(TextAlign.Center)
      Row().width(40).height(40)
    }.width('100%').padding(16).backgroundColor('#1A1A1A')
  }

  @Builder
  buildWorkoutTypeSelection() {
    Column({ space: 12 }) {
      Text('Select Workout Type').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#FFFFFF')
      Grid() {
        GridItem() { this.typeBtn('cardio', '🏃', 'Cardio') }
        GridItem() { this.typeBtn('strength', '💪', 'Strength') }
        GridItem() { this.typeBtn('hiit', '🔥', 'HIIT') }
        GridItem() { this.typeBtn('yoga', '🧘', 'Yoga') }
        GridItem() { this.typeBtn('walking', '🚶', 'Walking') }
        GridItem() { this.typeBtn('cycling', '🚴', 'Cycling') }
      }.columnsTemplate('1fr 1fr').rowsTemplate('1fr 1fr 1fr').columnsGap(12).rowsGap(12).width('100%').height(300)
    }
  }

  @Builder
  typeBtn(type: WorkoutType, icon: string, label: string) {
    Column({ space: 8 }) {
      Text(icon).fontSize(32)
      Text(label).fontSize(12)
        .fontColor(this.selectedType === type ? '#FFFFFF' : '#CCCCCC')
        .fontWeight(this.selectedType === type ? FontWeight.Bold : FontWeight.Normal)
    }.justifyContent(FlexAlign.Center).width('100%').height('100%')
    .backgroundColor(this.selectedType === type ? '#4ECDC4' : '#2A2A2A').borderRadius(12)
    .onClick(() => { this.selectedType = type; })
  }

  @Builder
  buildTrackingView() {
    Column({ space: 24 }) {
      Text(getWorkoutTypeLabel(this.selectedType)).fontSize(24).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
      Column({ space: 8 }) {
        Text(formatDuration(this.elapsedMinutes)).fontSize(48).fontWeight(FontWeight.Bold).fontColor('#4ECDC4')
        Text('Duration').fontSize(14).fontColor('#CCCCCC')
      }
      Column({ space: 8 }) {
        Text(`${this.estimatedCalories}`).fontSize(32).fontWeight(FontWeight.Bold).fontColor('#FFD700')
        Text('Estimated Calories').fontSize(14).fontColor('#CCCCCC')
      }
    }.width('100%').justifyContent(FlexAlign.Center).padding(24)
  }

  @Builder
  buildActionButton() {
    if (!this.isTracking) {
      Button('Start Workout').width('100%').height(56).fontSize(18).fontWeight(FontWeight.Bold)
        .backgroundColor('#4ECDC4').borderRadius(12).onClick(() => { this.startWorkout(); })
    } else {
      Column({ space: 12 }) {
        Button('Finish Workout').width('100%').height(56).fontSize(18).fontWeight(FontWeight.Bold)
          .backgroundColor('#2ECC71').borderRadius(12).onClick(() => { this.finishWorkout(); })
        Button('Cancel').width('100%').height(48).fontSize(16)
          .backgroundColor('#E74C3C').borderRadius(12).onClick(() => { this.cancelWorkout(); })
      }.width('100%')
    }
  }

  startWorkout() {
    this.isTracking = true;
    this.startTime = Date.now();
    this.elapsedMinutes = 0;
    this.estimatedCalories = 0;
    this.timerId = setInterval(() => {
      this.elapsedMinutes = Math.floor((Date.now() - this.startTime) / 60000);
      const profile = DataService.getInstance().getUserProfile();
      if (profile) {
        this.estimatedCalories = RPGService.getInstance().estimateCalories(
          this.selectedType, this.elapsedMinutes, profile.settings.weightKg);
      }
    }, 60000);
  }

  cancelWorkout() {
    if (this.timerId >= 0) { clearInterval(this.timerId); this.timerId = -1; }
    this.isTracking = false;
  }

  async finishWorkout() {
    if (this.timerId >= 0) { clearInterval(this.timerId); this.timerId = -1; }
    if (this.elapsedMinutes < 5) {
      return;
    }

    const dataService = DataService.getInstance();
    const rpgService = RPGService.getInstance();
    const todayLog = dataService.getTodayLog();
    const profile = dataService.getUserProfile();
    if (!todayLog || !profile) {
      return;
    }
    if (!rpgService.canLogAnotherWorkout(todayLog.workouts.length)) {
      return;
    }

    const endTime = Date.now();
    const durationMinutes = Math.floor((endTime - this.startTime) / 60000);
    const caloriesBurned = rpgService.estimateCalories(this.selectedType, durationMinutes, profile.settings.weightKg);
    const xpBreakdown = rpgService.calculateWorkoutXP(this.selectedType, durationMinutes, caloriesBurned);

    const workout: WorkoutSession = {
      id: `workout_${Date.now()}`, type: this.selectedType, startTime: this.startTime,
      endTime: endTime, durationMinutes: durationMinutes, caloriesBurned: caloriesBurned,
      notes: '', xpAwarded: xpBreakdown
    };

    todayLog.workouts.push(workout);
    todayLog.xpEarned.strength += xpBreakdown.strength;
    todayLog.xpEarned.endurance += xpBreakdown.endurance;
    todayLog.xpEarned.vitality += xpBreakdown.vitality;
    todayLog.xpEarned.focus += xpBreakdown.focus;
    todayLog.xpEarned.total += xpBreakdown.total;

    await dataService.saveDailyLog(todayLog);
    const result = await rpgService.applyXPToProfile(xpBreakdown);

    profile.totalWorkouts++;
    profile.lastWorkoutDate = new Date().toISOString().split('T')[0];
    await dataService.updateUserProfile(profile);
    await QuestService.getInstance().updateQuestProgress(todayLog);

    for (const levelUp of result.levelUps) {
      BackgroundTaskService.getInstance().sendLevelUpNotification(levelUp, 0);
    }
    this.pathStack.pop();
  }
}
