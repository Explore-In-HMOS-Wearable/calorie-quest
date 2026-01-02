import { DataService } from '../services/DataService';
import { QuestService } from '../services/QuestService';
import { UserProfile } from '../models/UserProfile';
import { DailyLog } from '../models/DailyLog';
import { Quest } from '../models/Quest';
import { formatNumber } from '../utils/FormatUtils';
import { QuickActionButton } from '../components/QuickActionButton';
import { StatBar } from '../components/StatBar';
import { QuestCard } from '../components/QuestCard';

@Component
export struct HomePage {
  @Consume('pathStack') pathStack: NavPathStack;
  @State profile: UserProfile | null = null;
  @State todayLog: DailyLog | null = null;
  @State activeQuests: Quest[] = [];
  @State loading: boolean = true;

  async aboutToAppear() {
    await this.loadData();
  }

  async loadData() {
    this.loading = true;
    const dataService = DataService.getInstance();
    this.profile = dataService.getUserProfile();
    this.todayLog = dataService.getTodayLog();
    this.activeQuests = dataService.getActiveQuests().filter(q => !q.completed).slice(0, 3);

    if (this.activeQuests.length === 0) {
      await QuestService.getInstance().generateDailyQuests();
      this.activeQuests = dataService.getActiveQuests().filter(q => !q.completed).slice(0, 3);
    }
    this.loading = false;
  }

  build() {
    Column() {
      if (this.loading) {
        Column() {
          LoadingProgress().color('#FFD700').width(60).height(60)
        }.width('100%').height('100%').justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 16 }) {
            this.buildHeader()
            this.buildQuickActions()
            this.buildTodayStats()
            this.buildQuests()
            this.buildStatsPreview()
          }.padding(16).width('100%')
        }.scrollBar(BarState.Off).width('100%').height('100%')
      }
    }.width('100%').height('100%').backgroundColor('#1A1A1A')
  }

  @Builder
  buildHeader() {
    Column({ space: 8 }) {
      Row() {
        Column({ space: 4 }) {
          Text(this.profile?.username || 'Hero').fontSize(24).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
          Row({ space: 8 }) {
            Text(`Lv.${this.profile?.level || 1}`).fontSize(14).fontColor('#FFD700')
            Text(`${formatNumber(this.profile?.coins || 0)} 💰`).fontSize(14).fontColor('#FFD700')
          }
        }.alignItems(HorizontalAlign.Start)
        Blank()
        Button({ type: ButtonType.Circle }) {
          Text('⚙️').fontSize(20)
        }.backgroundColor('#2A2A2A').width(48).height(48)
        .onClick(() => { this.pathStack.pushPath({ name: 'SettingsPage' }); })
      }.width('100%')

      if (this.profile && this.profile.loginStreak > 0) {
        Row({ space: 8 }) {
          Text('🔥').fontSize(16)
          Text(`${this.profile.loginStreak} day streak`).fontSize(14).fontColor('#FF6B6B')
          Text(`+${Math.floor(this.profile.loginStreak * 2)}% XP`).fontSize(12).fontColor('#4ECDC4')
        }.padding(8).backgroundColor('#2A2A2A').borderRadius(8)
      }
    }.width('100%').padding(12).backgroundColor('#2A2A2A').borderRadius(12)
  }

  @Builder
  buildQuickActions() {
    Column({ space: 8 }) {
      Text('Quick Actions').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#FFFFFF')
      Grid() {
        GridItem() {
          QuickActionButton({ icon: '🏃', label: 'Workout',
            onTap: () => { this.pathStack.pushPath({ name: 'WorkoutPage' }); } })
        }
        GridItem() {
          QuickActionButton({ icon: '💧', label: 'Water',
            onTap: () => { this.pathStack.pushPath({ name: 'WaterPage' }); } })
        }
        GridItem() {
          QuickActionButton({ icon: '🍽️', label: 'Meal',
            onTap: () => { this.pathStack.pushPath({ name: 'MealPage' }); } })
        }
        GridItem() {
          QuickActionButton({ icon: '📊', label: 'Stats',
            onTap: () => { this.pathStack.pushPath({ name: 'StatsPage' }); } })
        }
      }.columnsTemplate('1fr 1fr').rowsTemplate('1fr 1fr').columnsGap(12).rowsGap(12).width('100%').height(160)
    }.width('100%')
  }

  @Builder
  buildTodayStats() {
    Column({ space: 8 }) {
      Text('Today\'s Progress').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#FFFFFF')
      Column({ space: 12 }) {
        this.statRow('🏋️ Workouts', `${this.todayLog?.workouts.length || 0}`)
        this.statRow('👣 Steps', `${formatNumber(this.todayLog?.steps || 0)}`)
        this.statRow('💧 Water', `${this.todayLog?.waterLogs.length || 0} glasses`)
        this.statRow('🍽️ Meals', `${this.todayLog?.meals.length || 0}`)
        this.statRow('⭐ XP Today', String(this.todayLog?.xpEarned.total || 0), '#FFD700')
      }.padding(12).backgroundColor('#2A2A2A').borderRadius(12).width('100%')
    }.width('100%')
  }

  @Builder
  statRow(label: string, value: string, color: string = '#FFFFFF') {
    Row() {
      Text(label).fontSize(14).fontColor('#CCCCCC')
      Blank()
      Text(value).fontSize(14).fontWeight(FontWeight.Bold).fontColor(color)
    }.width('100%')
  }

  @Builder
  buildQuests() {
    Column({ space: 8 }) {
      Row() {
        Text('Active Quests').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#FFFFFF')
        Blank()
        Button('View All').fontSize(12).backgroundColor('#3A3A3A').height(28)
          .onClick(() => { this.pathStack.pushPath({ name: 'QuestsPage' }); })
      }.width('100%')

      if (this.activeQuests.length > 0) {
        Column({ space: 8 }) {
          ForEach(this.activeQuests, (quest: Quest) => {
            QuestCard({ quest: quest, onTap: () => {} })
          }, (quest: Quest): string => quest.id)
        }.width('100%')
      } else {
        Text('No active quests').fontSize(14).fontColor('#666666').padding(16)
      }
    }.width('100%')
  }

  @Builder
  buildStatsPreview() {
    Column({ space: 8 }) {
      Row() {
        Text('Character Stats').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#FFFFFF')
        Blank()
        Button('Details').fontSize(12).backgroundColor('#3A3A3A').height(28)
          .onClick(() => { this.pathStack.pushPath({ name: 'StatsPage' }); })
      }.width('100%')

      if (this.profile) {
        Column({ space: 12 }) {
          StatBar({ name: 'Strength', emoji: '💪', level: this.profile.stats.strength.level,
            currentXP: this.profile.stats.strength.currentXP,
            maxXP: this.profile.stats.strength.xpToNextLevel, color: '#FF6B6B' })
          StatBar({ name: 'Endurance', emoji: '🏃', level: this.profile.stats.endurance.level,
            currentXP: this.profile.stats.endurance.currentXP,
            maxXP: this.profile.stats.endurance.xpToNextLevel, color: '#4ECDC4' })
          StatBar({ name: 'Vitality', emoji: '💧', level: this.profile.stats.vitality.level,
            currentXP: this.profile.stats.vitality.currentXP,
            maxXP: this.profile.stats.vitality.xpToNextLevel, color: '#45B7D1' })
          StatBar({ name: 'Focus', emoji: '🧠', level: this.profile.stats.focus.level,
            currentXP: this.profile.stats.focus.currentXP,
            maxXP: this.profile.stats.focus.xpToNextLevel, color: '#FFA07A' })
        }.padding(12).backgroundColor('#2A2A2A').borderRadius(12).width('100%')
      }
    }.width('100%')
  }
}
