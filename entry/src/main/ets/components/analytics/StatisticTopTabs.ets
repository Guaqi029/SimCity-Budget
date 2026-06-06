export interface StatisticTopTabItem {
  id: string
  label: string
}

@Component
export struct StatisticTopTabs {
  items: StatisticTopTabItem[] = []
  selectedId: string = ''
  onChange: (id: string) => void = (_id: string) => {}
  onMoreClick: () => void = () => {}

  build() {
    Row() {
      Row({ space: 10 }) {
        ForEach(this.items, (item: StatisticTopTabItem) => {
          Text(item.label)
            .fontSize(15)
            .fontWeight(this.selectedId === item.id ? FontWeight.Medium : FontWeight.Regular)
            .fontColor(this.selectedId === item.id ? '#FFFFFF' : '#2A3142')
            .padding({ left: 16, right: 16, top: 4, bottom: 4 })
            .backgroundColor(this.selectedId === item.id ? '#56BFAF' : '#FFFFFF')
            .borderRadius(12)
            .onClick(() => {
              this.onChange(item.id)
            })
        }, (item: StatisticTopTabItem) => item.id)
      }
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 10, bottom: 10 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: 12,
      color: '#12000000',
      offsetX: 0,
      offsetY: 4
    })
  }
}
