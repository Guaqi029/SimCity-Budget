export interface StatisticTopTabItem {
  id: string
  label: string
}

@Component
export struct StatisticTopTabs {
  items: StatisticTopTabItem[] = []
  selectedId: string = ''
  onChange: (id: string) => void = (_id: string) => {}

  build() {
    Row({ space: 12 }) {
      ForEach(this.items, (item: StatisticTopTabItem) => {
        Text(item.label)
          .fontSize(16)
          .fontWeight(this.selectedId === item.id ? FontWeight.Medium : FontWeight.Regular)
          .fontColor(this.selectedId === item.id ? '#FFFFFF' : '#2A3142')
          .padding({ left: 22, right: 22, top: 18, bottom: 18 })
          .backgroundColor(this.selectedId === item.id ? '#56BFAF' : '#FFFFFF')
          .borderRadius(16)
          .onClick(() => {
            this.onChange(item.id)
          })
      }, (item: StatisticTopTabItem) => item.id)
    }
    .width('100%')
  }
}
