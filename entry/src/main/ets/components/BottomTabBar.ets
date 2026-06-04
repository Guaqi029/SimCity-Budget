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
          .backgroundColor(this.currentIndex === index ? this.activeColor(index) : this.inactiveColor(index))
          .layoutWeight(1)
          .height(index === 2 ? 48 : 42)
          .onClick(() => this.onChange(index))
      }, (item: TabItem) => item.label)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
  }

  private activeColor(index: number): string {
    return index === 2 ? '#55B8A7' : '#18233A'
  }

  private inactiveColor(index: number): string {
    return index === 2 ? '#E4F5F1' : '#EEF3FA'
  }
}
