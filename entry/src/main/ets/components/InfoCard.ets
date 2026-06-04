@Component
export struct InfoCard {
  title: string = ''
  value: string = ''
  description: string = ''

  build() {
    Column({ space: 10 }) {
      Text(this.title)
        .fontSize(14)
        .fontColor('#6B7A99')

      Text(this.value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#18233A')

      Text(this.description)
        .fontSize(12)
        .fontColor('#95A2BC')
    }
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .width('100%')
    .backgroundColor('#F8FBFF')
    .borderRadius(20)
  }
}
