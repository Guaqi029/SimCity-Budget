export interface StatisticTopTabItem {
  id: string
  label: string
}

@Component
export struct StatisticTopTabs {
  // 这里把原来的普通字段 items / selectedId 替换成 @Prop。
  // 删除原因：上一版虽然把点击事件回调到了父页面，但顶部组件本身没有把“当前选中项”当作响应式外部输入来接收，
  // 所以父页面的 selectedTabId 已经变化时，这个组件内部不一定会按新的值重绘高亮。
  // 新增功能：items 和 selectedId 现在会跟随父页面状态同步刷新，顶部绿色高亮会正确切换到当前页面对应的按钮。
  @Prop items: StatisticTopTabItem[] = []
  @Prop selectedId: string = ''
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
            .width(100)
            .textAlign(TextAlign.Center)
            .padding({ top: 8, bottom: 8 })
            .backgroundColor(this.selectedId === item.id ? '#56BFAF' : '#FFFFFF')
            .borderRadius(12)
            .onClick(() => {
              this.onChange(item.id)
            })
        }, (item: StatisticTopTabItem) => item.id)
      }
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 12, bottom: 12 })
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
