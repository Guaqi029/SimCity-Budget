export interface TabItem {
  label: string
}

@Component
export struct BottomTabBar {
  @Prop currentIndex: number = 0
  @Prop items: TabItem[] = []
  onChange: (index: number) => void = () => {}

  build() {
    Row({ space: 8 }) {
      ForEach(this.items, (item: TabItem, index: number) => {
        Button(item.label)
          .type(ButtonType.Capsule)
          .fontColor(this.currentIndex === index ? '#FFFFFF' : '#6B7A99')
          .backgroundColor(this.currentIndex === index ? '#18233A' : '#EEF3FA')
          .layoutWeight(1)
          .onClick(() => this.onChange(index))
      }, (item: TabItem) => item.label)
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(28)
  }
}
