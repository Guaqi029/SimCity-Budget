@Component
export struct TopMessageToast {
  @Prop visible: boolean = false
  @Prop message: string = ''

  build() {
    Column() {
      if (this.visible && this.message.length > 0) {
        Text(this.message)
          .fontSize(12)
          .fontColor('#334155')
          .maxLines(1)
          .textAlign(TextAlign.Center)
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .backgroundColor('#FFFFFFCC')
          .borderRadius(14)
          .shadow({ radius: 10, color: '#22334422', offsetY: 3 })
      }
    }
    .width('100%')
    .height(this.visible ? 42 : 0)
    .alignItems(HorizontalAlign.Center)
    .opacity(this.visible ? 1 : 0)
    .animation({ duration: 180, curve: Curve.EaseOut })
  }
}
