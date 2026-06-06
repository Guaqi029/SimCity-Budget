import { ICON_LIBRARY_ITEMS, IconLibraryItem } from './IconLibraryConfig'

@CustomDialog
export struct IconLibraryDialog {
  controller?: CustomDialogController
  @Prop icons: IconLibraryItem[] = ICON_LIBRARY_ITEMS
  @Prop selectedIconId: string = ''
  title: string = '选择图标'
  onSelect: (icon: IconLibraryItem) => void = () => {}

  build() {
    Column({ space: 14 }) {
      Row() {
        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111111')
        Blank()
        Text('取消')
          .fontSize(14)
          .fontColor('#888888')
          .onClick(() => {
            if (this.controller !== undefined) {
              this.controller.close()
            }
          })
      }
      .width('100%')
      .height(34)

      Scroll() {
        GridRow({ columns: 4, gutter: 8 }) {
          ForEach(this.icons, (icon: IconLibraryItem) => {
            GridCol() {
              this.iconCell(icon)
            }
          }, (icon: IconLibraryItem) => icon.id)
        }
        .width('100%')
      }
      .width('100%')
      .height(330)
      .scrollBar(BarState.Off)
    }
    .width('86%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  @Builder
  private iconCell(icon: IconLibraryItem) {
    Column({ space: 7 }) {
      Stack({ alignContent: Alignment.Center }) {
        Image(icon.resource)
          .width(26)
          .height(26)
          .objectFit(ImageFit.Contain)
      }
      .width(46)
      .height(46)
      .backgroundColor(this.selectedIconId === icon.id ? '#E6F7F3' : '#F4F5F7')
      .border({
        width: this.selectedIconId === icon.id ? 1.5 : 0,
        color: '#55B8A7'
      })
      .borderRadius(23)

      Text(icon.name)
        .fontSize(12)
        .fontColor(this.selectedIconId === icon.id ? '#55B8A7' : '#333333')
        .maxLines(1)
        .textAlign(TextAlign.Center)
        .width('100%')
    }
    .width('100%')
    .height(78)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.onSelect(icon)
      if (this.controller !== undefined) {
        this.controller.close()
      }
    })
  }
}
