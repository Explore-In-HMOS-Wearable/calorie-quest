import { DataService } from '../services/DataService';
import { RPGService } from '../services/RPGService';
import { QuestService } from '../services/QuestService';
import { NutritionLog } from '../models/DailyLog';
import { getStarDisplay } from '../utils/FormatUtils';

@Component
export struct MealPage {
  @Consume('pathStack') pathStack: NavPathStack;
  @State selectedMealType: 'breakfast' | 'lunch' | 'dinner' | 'snack' = 'breakfast';
  @State selectedQuality: 1 | 2 | 3 | 4 | 5 = 3;

  build() {
    NavDestination() {
      Column() {
        this.buildHeader()
        Scroll() {
          Column({ space: 20 }) {
            this.buildMealTypeSection()
            this.buildQualitySection()
            this.buildXPPreview()
            this.buildSaveButton()
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
      Text('Log Meal').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
        .layoutWeight(1).textAlign(TextAlign.Center)
      Row().width(40).height(40)
    }.width('100%').padding(16).backgroundColor('#1A1A1A')
  }

  @Builder
  buildMealTypeSection() {
    Column({ space: 12 }) {
      Text('Meal Type').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#FFFFFF')
      Grid() {
        GridItem() { this.mealTypeBtn('breakfast', '🍳', 'Breakfast') }
        GridItem() { this.mealTypeBtn('lunch', '🍱', 'Lunch') }
        GridItem() { this.mealTypeBtn('dinner', '🍽️', 'Dinner') }
        GridItem() { this.mealTypeBtn('snack', '🍎', 'Snack') }
      }.columnsTemplate('1fr 1fr').rowsTemplate('1fr 1fr').columnsGap(12).rowsGap(12).width('100%').height(200)
    }
  }

  @Builder
  mealTypeBtn(type: 'breakfast' | 'lunch' | 'dinner' | 'snack', icon: string, label: string) {
    Column({ space: 8 }) {
      Text(icon).fontSize(32)
      Text(label).fontSize(12)
        .fontColor(this.selectedMealType === type ? '#FFFFFF' : '#CCCCCC')
        .fontWeight(this.selectedMealType === type ? FontWeight.Bold : FontWeight.Normal)
    }.justifyContent(FlexAlign.Center).width('100%').height('100%')
    .backgroundColor(this.selectedMealType === type ? '#FFA07A' : '#2A2A2A').borderRadius(12)
    .onClick(() => { this.selectedMealType = type; })
  }

  @Builder
  buildQualitySection() {
    Column({ space: 12 }) {
      Text('Meal Quality').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#FFFFFF')
      Column({ space: 8 }) {
        Text(getStarDisplay(this.selectedQuality)).fontSize(48)
        Text(this.getQualityLabel(this.selectedQuality)).fontSize(14).fontColor('#CCCCCC')
      }.width('100%').padding(16).backgroundColor('#2A2A2A').borderRadius(12)
      Row({ space: 12 }) {
        ForEach([1, 2, 3, 4, 5], (rating: number) => {
          Button() {
            Text(`${rating}⭐`).fontSize(16)
              .fontColor(this.selectedQuality === rating ? '#FFFFFF' : '#CCCCCC')
          }.backgroundColor(this.selectedQuality === rating ? '#FFA07A' : '#2A2A2A')
          .layoutWeight(1).height(48)
          .onClick(() => { this.selectedQuality = rating as (1 | 2 | 3 | 4 | 5); })
        }, (rating: number): string => rating.toString())
      }.width('100%')
    }
  }

  @Builder
  buildXPPreview() {
    Column({ space: 12 }) {
      Text('XP Reward').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#FFFFFF')
      Row({ space: 16 }) {
        if (this.getXPForQuality().focus > 0) {
          this.xpCard(`+${this.getXPForQuality().focus}`, '🧠 Focus', '#FFA07A')
        }
        if (this.getXPForQuality().vitality > 0) {
          this.xpCard(`+${this.getXPForQuality().vitality}`, '💧 Vitality', '#45B7D1')
        }
        if (this.selectedQuality === 5) {
          this.xpCard('+5', '💰 Coins', '#FFD700')
        }
      }.width('100%')
    }
  }

  @Builder
  xpCard(value: string, label: string, color: string) {
    Column({ space: 4 }) {
      Text(value).fontSize(20).fontWeight(FontWeight.Bold).fontColor(color)
      Text(label).fontSize(12).fontColor('#CCCCCC')
    }.layoutWeight(1).padding(12).backgroundColor('#2A2A2A').borderRadius(8)
  }

  getXPForQuality() {
    return RPGService.getInstance().calculateMealXP(this.selectedQuality);
  }

  @Builder
  buildSaveButton() {
    Button('Log Meal').width('100%').height(56).fontSize(18).fontWeight(FontWeight.Bold)
      .backgroundColor('#FFA07A').borderRadius(12).onClick(() => { this.saveMeal(); })
  }

  getQualityLabel(quality: number): string {
    const labels: string[] = ['', 'Fast food / Highly processed', 'Convenient / Mixed quality',
      'Balanced / Home-cooked', 'Nutritious / Vegetable-rich', 'Optimal / Whole foods'];
    return labels[quality] || '';
  }

  async saveMeal() {
    const dataService = DataService.getInstance();
    const rpgService = RPGService.getInstance();
    const todayLog = dataService.getTodayLog();
    const profile = dataService.getUserProfile();
    if (!todayLog || !profile) {
      return;
    }
    if (!rpgService.canLogMoreMeals(todayLog.meals.length)) {
      return;
    }

    const xpBreakdown = rpgService.calculateMealXP(this.selectedQuality);
    const mealLog: NutritionLog = {
      id: `meal_${Date.now()}`, timestamp: Date.now(), mealType: this.selectedMealType,
      qualityRating: this.selectedQuality, notes: '', xpAwarded: xpBreakdown
    };

    todayLog.meals.push(mealLog);
    todayLog.xpEarned.strength += xpBreakdown.strength;
    todayLog.xpEarned.endurance += xpBreakdown.endurance;
    todayLog.xpEarned.vitality += xpBreakdown.vitality;
    todayLog.xpEarned.focus += xpBreakdown.focus;
    todayLog.xpEarned.total += xpBreakdown.total;

    if (this.selectedQuality === 5) {
      profile.coins += 5;
      todayLog.coinsEarned += 5;
      await dataService.updateUserProfile(profile);
    }

    await dataService.saveDailyLog(todayLog);
    await rpgService.applyXPToProfile(xpBreakdown);
    await QuestService.getInstance().updateQuestProgress(todayLog);
    this.pathStack.pop();
  }
}
