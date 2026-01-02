@Component
export struct QuickActionButton {
  icon: string = '⭐';
  label: string = 'Action';
  onTap?: () => void;

  build() {
    Column({ space: 8 }) {
      Text(this.icon)
        .fontSize(32)
      
      Text(this.label)
        .fontSize(12)
        .fontColor('#CCCCCC')
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
    .backgroundColor('#2A2A2A')
    .borderRadius(12)
    .onClick(() => {
      if (this.onTap) {
        this.onTap();
      }
    })
  }
}

