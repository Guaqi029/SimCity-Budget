@Builder
function EmptyStatisticPanelContent() {
}

@Component
export struct StatisticPanelCard {
  title: string = ''
  actionText: string = ''
  @BuilderParam content: () => void = EmptyStatisticPanelContent

  build() {
    Column({ space: 18 }) {
      Row() {
        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#18233A')

        Blank()

        if (this.actionText.length > 0) {
          Text(this.actionText)
            .fontSize(14)
            .fontColor('#56BFAF')
        }
      }
      .width('100%')

      this.content()
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .alignItems(HorizontalAlign.Start)
  }
}
