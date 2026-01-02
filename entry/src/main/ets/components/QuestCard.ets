import { Quest } from '../models/Quest';
import { formatPercentage } from '../utils/FormatUtils';

@Component
export struct QuestCard {
  quest: Quest = {
    id: '',
    type: 'daily',
    title: 'Quest',
    description: 'Description',
    requirement: { type: 'workout_count', target: 1 },
    xpReward: 50,
    coinReward: 15,
    startDate: '',
    endDate: '',
    progress: 0,
    targetProgress: 1,
    completed: false,
    claimedReward: false
  };
  onTap?: () => void;

  build() {
    Column({ space: 8 }) {
      Row() {
        Text(this.quest.title)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
        
        Blank()
        
        Text(this.quest.type === 'daily' ? '📅' : '📆')
          .fontSize(14)
      }
      .width('100%')
      
      Text(this.quest.description)
        .fontSize(12)
        .fontColor('#CCCCCC')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      
      // Progress bar
      Stack({ alignContent: Alignment.Start }) {
        Row()
          .width('100%')
          .height(6)
          .backgroundColor('#1A1A1A')
          .borderRadius(3)
        
        Row()
          .width(`${Math.min((this.quest.progress / this.quest.targetProgress) * 100, 100)}%`)
          .height(6)
          .backgroundColor(this.quest.completed ? '#2ECC71' : '#4ECDC4')
          .borderRadius(3)
      }
      .width('100%')
      
      Row() {
        Text(`${this.quest.progress} / ${this.quest.targetProgress}`)
          .fontSize(11)
          .fontColor('#999999')
        
        Blank()
        
        Row({ space: 8 }) {
          Text(`${this.quest.xpReward} XP`)
            .fontSize(11)
            .fontColor('#FFD700')
          
          Text(`${this.quest.coinReward} 💰`)
            .fontSize(11)
            .fontColor('#FFD700')
        }
      }
      .width('100%')
    }
    .padding(12)
    .width('100%')
    .backgroundColor('#2A2A2A')
    .borderRadius(12)
    .onClick(() => {
      if (this.onTap) {
        this.onTap();
      }
    })
  }
}

