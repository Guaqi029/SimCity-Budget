@Builder
export function StatisticPanelCard(title: string, actionText: string, content: CustomBuilder) {
  Column({ space: 18 }) {
    Row() {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#18233A')

      Blank()

      if (actionText.length > 0) {
        Text(actionText)
          .fontSize(14)
          .fontColor('#56BFAF')
      }
    }
    .width('100%')

    content()
  }
  .width('100%')
  .padding(18)
  .backgroundColor('#FFFFFF')
  .borderRadius(24)
  .alignItems(HorizontalAlign.Start)
}
