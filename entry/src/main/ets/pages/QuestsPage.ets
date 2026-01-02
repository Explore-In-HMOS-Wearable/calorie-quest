import { DataService } from '../services/DataService';
import { QuestService } from '../services/QuestService';
import { Quest } from '../models/Quest';
import { QuestCard } from '../components/QuestCard';

@Component
export struct QuestsPage {
  @Consume('pathStack') pathStack: NavPathStack;
  @State dailyQuests: Quest[] = [];
  @State weeklyQuests: Quest[] = [];
  @State loading: boolean = false;

  async aboutToAppear() {
    await this.loadQuests();
  }

  async loadQuests() {
    this.loading = true;
    const dataService = DataService.getInstance();
    const allQuests = dataService.getActiveQuests();
    this.dailyQuests = allQuests.filter(q => q.type === 'daily');
    this.weeklyQuests = allQuests.filter(q => q.type === 'weekly');
    this.loading = false;
  }

  build() {
    NavDestination() {
      Column() {
        this.buildHeader()
        if (this.loading) {
          Column() {
            LoadingProgress().color('#FFD700').width(60).height(60)
          }.layoutWeight(1).justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column({ space: 16 }) {
              this.buildQuestSection('Daily Quests 📅', this.dailyQuests)
              this.buildQuestSection('Weekly Quests 📆', this.weeklyQuests)
              this.buildTipsSection()
            }.padding(16).width('100%')
          }.layoutWeight(1).scrollBar(BarState.Off)
        }
      }.width('100%').height('100%').backgroundColor('#1A1A1A')
    }.hideTitleBar(true)
  }

  @Builder
  buildHeader() {
    Row() {
      Button({ type: ButtonType.Circle }) {
        Text('←').fontSize(20).fontColor('#FFFFFF')
      }.backgroundColor('#2A2A2A').width(40).height(40).onClick(() => { this.pathStack.pop(); })
      Text('Quests').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
        .layoutWeight(1).textAlign(TextAlign.Center)
      Button({ type: ButtonType.Circle }) {
        Text('🔄').fontSize(20)
      }.backgroundColor('#2A2A2A').width(40).height(40).onClick(() => { this.loadQuests(); })
    }.width('100%').padding(16).backgroundColor('#1A1A1A')
  }

  @Builder
  buildQuestSection(title: string, quests: Quest[]) {
    Column({ space: 12 }) {
      Text(title).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
      if (quests.length > 0) {
        Column({ space: 8 }) {
          ForEach(quests, (quest: Quest) => {
            Column({ space: 0 }) {
              QuestCard({ quest: quest, onTap: () => { this.handleQuestTap(quest); } })
              if (quest.completed && !quest.claimedReward) {
                Button('Claim Reward! 🎁').width('100%').height(44).fontSize(14)
                  .fontWeight(FontWeight.Bold).backgroundColor('#2ECC71').margin({ top: 8 })
                  .onClick(() => { this.claimReward(quest.id); })
              }
            }
          }, (quest: Quest): string => quest.id)
        }
      } else {
        Text('No quests available').fontSize(14).fontColor('#666666').padding(20)
          .width('100%').textAlign(TextAlign.Center).backgroundColor('#2A2A2A').borderRadius(12)
      }
    }.width('100%')
  }

  @Builder
  buildTipsSection() {
    Column({ space: 8 }) {
      Text('💡 Tips').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#FFFFFF')
      Column({ space: 8 }) {
        Text('• Daily quests refresh at midnight').fontSize(12).fontColor('#CCCCCC')
        Text('• Weekly quests refresh every Monday').fontSize(12).fontColor('#CCCCCC')
        Text('• Complete quests for bonus XP and coins!').fontSize(12).fontColor('#CCCCCC')
        Text('• Your streak multiplier applies to quest rewards').fontSize(12).fontColor('#CCCCCC')
      }.padding(12).backgroundColor('#2A2A2A').borderRadius(12).width('100%').alignItems(HorizontalAlign.Start)
    }.width('100%')
  }

  handleQuestTap(quest: Quest) {
    console.info(`Quest tapped: ${quest.title}`);
  }

  async claimReward(questId: string) {
    const success = await QuestService.getInstance().claimQuestReward(questId);
    if (success) {
      await this.loadQuests();
      console.info('Reward claimed!');
    }
  }
}
