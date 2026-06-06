export interface TabItem {
  label: string
  icon: Resource
  selectedIcon: Resource
}


@Component
export struct BottomTabBar {
  @Prop currentIndex: number = 0
  @Prop items: TabItem[] = []
  onChange: (index: number) => void = () => {}

  build() {
    Column() {
      Row() {
        ForEach(this.items, (item: TabItem, index: number) => {
          Column() {
            Image(this.currentIndex === index ? item.selectedIcon : item.icon)
              .width(index === 2 ? 34 : 28)
              .height(index === 2 ? 34 : 28)
              .objectFit(ImageFit.Contain)
          }
          .layoutWeight(1)
          .height(34)
          .justifyContent(FlexAlign.End)
          .alignItems(HorizontalAlign.Center)
          .backgroundColor('#FFFFFF')
          .onClick(() => this.onChange(index))
        }, (item: TabItem) => item.label)
      }
      .width('100%')
      .height(38)
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}
