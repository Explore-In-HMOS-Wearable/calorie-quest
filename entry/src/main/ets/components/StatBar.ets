import { formatPercentage } from '../utils/FormatUtils';

@Component
export struct StatBar {
  name: string = 'Stat';
  emoji: string = '⭐';
  level: number = 1;
  currentXP: number = 0;
  maxXP: number = 100;
  color: string = '#4ECDC4';

  build() {
    Column({ space: 4 }) {
      Row() {
        Text(`${this.emoji} ${this.name}`)
          .fontSize(14)
          .fontColor('#FFFFFF')
        
        Blank()
        
        Text(`Lv.${this.level}`)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.color)
      }
      .width('100%')
      
      Stack({ alignContent: Alignment.Start }) {
        // Background
        Row()
          .width('100%')
          .height(8)
          .backgroundColor('#1A1A1A')
          .borderRadius(4)
        
        // Progress
        Row()
          .width(`${(this.currentXP / this.maxXP) * 100}%`)
          .height(8)
          .backgroundColor(this.color)
          .borderRadius(4)
      }
      .width('100%')
      
      Row() {
        Text(`${this.currentXP} / ${this.maxXP} XP`)
          .fontSize(11)
          .fontColor('#999999')
      }
      .width('100%')
    }
    .width('100%')
  }
}

