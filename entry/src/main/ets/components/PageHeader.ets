@Component
export struct PageHeader {
  eyebrow: string = 'SIMCITY BUDGET'
  title: string = ''
  subtitle: string = ''

  build() {
    Column({ space: 8 }) {
      Text(this.eyebrow)
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor('#7D8CA7')
        .letterSpacing(3)

      Text(this.title)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#18233A')

      // 这里把原来“无论 subtitle 是否为空都固定渲染一行文本”的写法改成了条件渲染。
      if (this.subtitle.length > 0) {
        Text(this.subtitle)
          .fontSize(14)
          .fontColor('#6B7A99')
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }
}
