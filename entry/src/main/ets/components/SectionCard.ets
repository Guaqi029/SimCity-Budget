@Component
export struct SectionCard {
  title: string = ''
  description: string = ''

  build() {
    Column({ space: 10 }) {
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#18233A')

      Text(this.description)
        .fontSize(13)
        .fontColor('#6B7A99')
    }
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(24)
  }
}
