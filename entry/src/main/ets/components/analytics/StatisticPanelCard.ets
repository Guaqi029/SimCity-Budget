// 这里把原来的裸 @Builder 函数实现替换成标准组件。
// 删除原因：AnalyticsPage 现在需要像普通组件一样稳定复用“统计面板”壳子，
// 直接改成带 @BuilderParam 的组件后，页面传入标题、操作文案和内容区都会更清晰，也更不容易踩 Builder 调用语法差异。
// 新增功能：统计页、账单页后续如果都需要“白色卡片 + 标题栏 + 自定义内容区”，都可以直接复用这个组件。
@Builder
function EmptyStatisticPanelContent() {
}

@Component
export struct StatisticPanelCard {
  title: string = ''
  actionText: string = ''
  // 这里把原来用普通箭头函数初始化 @BuilderParam 的写法替换成空的 @Builder。
  // 删除原因：ArkTS 要求 @BuilderParam 只能由 @Builder / @LocalBuilder 初始化，普通函数会触发编译错误。
  // 新增功能：保留 content 的默认空内容能力，同时满足 ArkTS 对 Builder 参数的语法要求。
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
