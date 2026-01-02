import { DataService } from '../services/DataService';
import { UserProfile, StatDetail } from '../models/UserProfile';
import { StatBar } from '../components/StatBar';
import { formatNumber } from '../utils/FormatUtils';

@Component
export struct StatsPage {
  @Consume('pathStack') pathStack: NavPathStack;
  @State profile: UserProfile | null = null;

  aboutToAppear() {
    this.profile = DataService.getInstance().getUserProfile();
  }

  build() {
    NavDestination() {
      Column() {
        this.buildHeader()
        Scroll() {
          Column({ space: 16 }) {
            this.buildCharacterOverview()
            this.buildMainStats()
            this.buildLifetimeStats()
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
      Text('Character Stats').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
        .layoutWeight(1).textAlign(TextAlign.Center)
      Row().width(40).height(40)
    }.width('100%').padding(16).backgroundColor('#1A1A1A')
  }

  @Builder
  buildCharacterOverview() {
    Column({ space: 16 }) {
      Text('⚔️').fontSize(80)
      Text(this.profile?.username || 'Hero').fontSize(28).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
      Row({ space: 24 }) {
        Column({ space: 4 }) {
          Text(`${this.profile?.level || 1}`).fontSize(32).fontWeight(FontWeight.Bold).fontColor('#FFD700')
          Text('Level').fontSize(14).fontColor('#CCCCCC')
        }
        Column({ space: 4 }) {
          Text(formatNumber(this.profile?.totalXP || 0)).fontSize(32).fontWeight(FontWeight.Bold).fontColor('#4ECDC4')
          Text('Total XP').fontSize(14).fontColor('#CCCCCC')
        }
        Column({ space: 4 }) {
          Text(formatNumber(this.profile?.coins || 0)).fontSize(32).fontWeight(FontWeight.Bold).fontColor('#FFD700')
          Text('Coins').fontSize(14).fontColor('#CCCCCC')
        }
      }
    }.width('100%').padding(20).backgroundColor('#2A2A2A').borderRadius(16)
  }

  @Builder
  buildMainStats() {
    Column({ space: 12 }) {
      Text('Character Stats').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
      if (this.profile) {
        Column({ space: 16 }) {
          this.statCard('Strength', '💪', this.profile.stats.strength, '#FF6B6B',
            'Your muscle power and physical capability')
          this.statCard('Endurance', '🏃', this.profile.stats.endurance, '#4ECDC4',
            'Your stamina and cardiovascular fitness')
          this.statCard('Vitality', '💧', this.profile.stats.vitality, '#45B7D1',
            'Your health, recovery, and hydration')
          this.statCard('Focus', '🧠', this.profile.stats.focus, '#FFA07A',
            'Your mental clarity and discipline')
        }
      }
    }.width('100%')
  }

  @Builder
  statCard(name: string, emoji: string, stat: StatDetail, color: string, description: string) {
    Column({ space: 8 }) {
      StatBar({ name: name, emoji: emoji, level: stat.level, currentXP: stat.currentXP,
        maxXP: stat.xpToNextLevel, color: color })
      Text(description).fontSize(12).fontColor('#999999').margin({ top: 4 })
    }.padding(16).backgroundColor('#2A2A2A').borderRadius(12)
  }

  @Builder
  buildLifetimeStats() {
    Column({ space: 12 }) {
      Text('Lifetime Achievements').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
      Column({ space: 12 }) {
        Row({ space: 12 }) {
          this.achievementCard(`${this.profile?.totalWorkouts || 0}`, 'Workouts', '#FF6B6B')
          this.achievementCard(`${this.profile?.totalWaterGlasses || 0}`, 'Water Glasses', '#45B7D1')
        }
        Row({ space: 12 }) {
          this.achievementCard(`${this.profile?.totalMealsLogged || 0}`, 'Meals Logged', '#FFA07A')
          this.achievementCard(`${this.profile?.loginStreak || 0}`, 'Day Streak 🔥', '#FFD700')
        }
      }
    }.width('100%')
  }

  @Builder
  achievementCard(value: string, label: string, color: string) {
    Column({ space: 4 }) {
      Text(value).fontSize(24).fontWeight(FontWeight.Bold).fontColor(color)
      Text(label).fontSize(12).fontColor('#CCCCCC')
    }.layoutWeight(1).padding(16).backgroundColor('#2A2A2A').borderRadius(12)
  }
}
