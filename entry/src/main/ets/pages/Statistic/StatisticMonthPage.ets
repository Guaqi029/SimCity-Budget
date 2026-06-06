@Component
export struct StatisticMonthPage {
  build() {
    // 新增：在月统计占位页下方补一段透明占位空间。
    // 原因：当前页面内容还比较少，如果不额外撑高，顶部白色内容卡容易在视觉上悬在中间，不够“置顶和居上”。
    // 新增功能：即使真实内容还没填满，页面也会保持从上往下铺开的布局感。
    Column({ space: 14 }) {
      Text('月统计')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#18233A')

      Text('这里先作为月统计页面占位，后续可以继续接月度趋势、月分类对比、月预算达成等内容。')
        .fontSize(14)
        .fontColor('#6B7A99')
        .lineHeight(22)

      Column({ space: 10 }) {
        Text('已初始化页面骨架')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#24314A')

        Text('当前页面已具备顶部切换进入能力，后面可以直接往这里填真实月统计组件。')
          .fontSize(13)
          .fontColor('#7D8CA7')
          .lineHeight(20)
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#FFFFFF')
      .borderRadius(20)
      .alignItems(HorizontalAlign.Start)

      Column()
        .width('100%')
        .height(420)
        .backgroundColor('#00000000')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
