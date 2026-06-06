export interface StatisticSummaryItem {
  label: string
  value: string
  valueColor?: string
}

@Component
export struct StatisticSummaryStrip {
  items: StatisticSummaryItem[] = []
  stripBackgroundColor: string = '#00000000'
  verticalPadding: number = 0

  build() {
    Row({ space: 12 }) {
      ForEach(this.items, (item: StatisticSummaryItem) => {
        Row({ space: 4 }) {
          Text(item.label)
            .fontSize(14)
            .fontColor('#4F596B')

          Text(item.value)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(item.valueColor === undefined ? '#18233A' : item.valueColor)
        }
      }, (item: StatisticSummaryItem) => item.label)
    }
    .width('100%')
    .padding({ top: this.verticalPadding, bottom: this.verticalPadding })
    .backgroundColor(this.stripBackgroundColor)
    .alignItems(VerticalAlign.Center)
  }
}
