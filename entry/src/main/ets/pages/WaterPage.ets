import { DataService } from '../services/DataService';
import { RPGService } from '../services/RPGService';
import { QuestService } from '../services/QuestService';
import { WaterLog } from '../models/DailyLog';
import { formatWaterAmount } from '../utils/FormatUtils';
import { DEFAULT_WATER_SERVING_ML } from '../constants/AppConstants';

@Component
export struct WaterPage {
  @Consume('pathStack') pathStack: NavPathStack;
  @State waterCount: number = 0;
  @State dailyGoal: number = 8;
  private servingSize: number = DEFAULT_WATER_SERVING_ML;

  async aboutToAppear() {
    const dataService = DataService.getInstance();
    const todayLog = dataService.getTodayLog();
    const profile = dataService.getUserProfile();
    if (todayLog) { this.waterCount = todayLog.waterLogs.length; }
    if (profile) { this.dailyGoal = Math.ceil(profile.settings.dailyWaterGoal / this.servingSize); }
  }

  build() {
    NavDestination() {
      Column() {
        this.buildHeader()
        Column({ space: 24 }) {
          this.buildWaterVisualization()
          this.buildStatsSection()
          this.buildAddWaterButton()
          this.buildTodayLog()
        }.layoutWeight(1).padding(16).width('100%')
      }.width('100%').height('100%').backgroundColor('#1A1A1A')
    }.hideTitleBar(true)
  }

  @Builder
  buildHeader() {
    Row() {
      Button({ type: ButtonType.Circle }) {
        Text('←').fontSize(20).fontColor('#FFFFFF')
      }.backgroundColor('#2A2A2A').width(40).height(40).onClick(() => { this.pathStack.pop(); })
      Text('Water Intake').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
        .layoutWeight(1).textAlign(TextAlign.Center)
      Row().width(40).height(40)
    }.width('100%').padding(16).backgroundColor('#1A1A1A')
  }

  @Builder
  buildWaterVisualization() {
    Column({ space: 16 }) {
      Stack({ alignContent: Alignment.Center }) {
        Text('💧').fontSize(120).opacity(0.3)
        Column() {
          Text(`${this.waterCount}`).fontSize(48).fontWeight(FontWeight.Bold).fontColor('#45B7D1')
          Text('glasses').fontSize(16).fontColor('#CCCCCC')
        }
      }.width(180).height(180)

      Column({ space: 8 }) {
        Stack({ alignContent: Alignment.Start }) {
          Row().width('100%').height(12).backgroundColor('#2A2A2A').borderRadius(6)
          Row().width(`${Math.min((this.waterCount / this.dailyGoal) * 100, 100)}%`)
            .height(12).backgroundColor('#45B7D1').borderRadius(6)
        }.width('100%')
        Row() {
          Text(`${this.waterCount} / ${this.dailyGoal}`).fontSize(14).fontColor('#CCCCCC')
          Blank()
          if (this.waterCount >= this.dailyGoal) {
            Text('Goal Complete! 🎉').fontSize(14).fontColor('#2ECC71').fontWeight(FontWeight.Bold)
          } else {
            Text(`${this.dailyGoal - this.waterCount} more`).fontSize(14).fontColor('#4ECDC4')
          }
        }.width('100%')
      }.width('100%')
    }
  }

  @Builder
  buildStatsSection() {
    Row({ space: 16 }) {
      Column({ space: 4 }) {
        Text(formatWaterAmount(this.waterCount * this.servingSize))
          .fontSize(20).fontWeight(FontWeight.Bold).fontColor('#45B7D1')
        Text('Total Today').fontSize(12).fontColor('#CCCCCC')
      }.layoutWeight(1).padding(12).backgroundColor('#2A2A2A').borderRadius(12)
      Column({ space: 4 }) {
        Text(`+${this.waterCount * 2}`).fontSize(20).fontWeight(FontWeight.Bold).fontColor('#FFD700')
        Text('Vitality XP').fontSize(12).fontColor('#CCCCCC')
      }.layoutWeight(1).padding(12).backgroundColor('#2A2A2A').borderRadius(12)
    }.width('100%')
  }

  @Builder
  buildAddWaterButton() {
    Button() {
      Column({ space: 8 }) {
        Text('💧').fontSize(32)
        Text(`Add ${formatWaterAmount(this.servingSize)}`).fontSize(18)
          .fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
      }
    }.width('100%').height(120).backgroundColor('#45B7D1').borderRadius(16)
    .onClick(() => { this.addWater(); })
  }

  @Builder
  buildTodayLog() {
    Column({ space: 8 }) {
      Text('Today\'s Log').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#FFFFFF')
      if (this.waterCount > 0) {
        List({ space: 8 }) {
          ForEach(Array.from({ length: this.waterCount }, (_: undefined, i: number) => `water_log_${i}`), (id: string) => {
            ListItem() {
              Row({ space: 12 }) {
                Text('💧').fontSize(20)
                Text(formatWaterAmount(this.servingSize)).fontSize(14).fontColor('#CCCCCC').layoutWeight(1)
                Text('+2 XP').fontSize(12).fontColor('#FFD700')
              }.padding(12).width('100%').backgroundColor('#2A2A2A').borderRadius(8)
            }
          }, (id: string): string => id)
        }.height(200).scrollBar(BarState.Auto)
      } else {
        Text('No water logged yet today').fontSize(14).fontColor('#666666').padding(16)
      }
    }.width('100%')
  }

  async addWater() {
    const dataService = DataService.getInstance();
    const rpgService = RPGService.getInstance();
    const todayLog = dataService.getTodayLog();
    if (!todayLog) {
      return;
    }
    if (!rpgService.canLogMoreWater(todayLog.waterLogs.length)) {
      return;
    }

    const xpBreakdown = rpgService.calculateWaterXP();
    const waterLog: WaterLog = {
      id: `water_${Date.now()}`, timestamp: Date.now(),
      amountMl: this.servingSize, xpAwarded: xpBreakdown.vitality
    };

    todayLog.waterLogs.push(waterLog);
    todayLog.xpEarned.vitality += xpBreakdown.vitality;
    todayLog.xpEarned.total += xpBreakdown.total;

    await dataService.saveDailyLog(todayLog);
    await rpgService.applyXPToProfile(xpBreakdown);
    await QuestService.getInstance().updateQuestProgress(todayLog);
    this.waterCount = todayLog.waterLogs.length;
  }
}
