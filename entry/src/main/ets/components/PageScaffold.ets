@Component
export struct PageScaffold {
  @BuilderParam header!: () => void
  @BuilderParam content!: () => void

  build() {
    Column({ space: 16 }) {
      this.header()
      this.content()
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
