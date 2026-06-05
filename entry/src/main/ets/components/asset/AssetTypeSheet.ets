import { AssetTypeOption } from '../../model/AssetAccount'

export interface AssetTypeSection {
  title: string
  options: AssetTypeOption[]
}

@Component
export struct AssetTypeSheet {
  @Prop sections: AssetTypeSection[] = []
  onSelect: (option: AssetTypeOption) => void = () => {}

  build() {
    Column({ space: 10 }) {
      ForEach(this.sections, (section: AssetTypeSection) => {
        Column({ space: 6 }) {
          Text(section.title)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111111')

          GridRow({ columns: 5, gutter: 4 }) {
            ForEach(section.options, (option: AssetTypeOption) => {
              GridCol() {
                AssetTypeCell({
                  option: option,
                  onSelect: (nextOption: AssetTypeOption) => {
                    this.onSelect(nextOption)
                  }
                })
              }
            }, (option: AssetTypeOption) => section.title + option.title + option.type)
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }, (section: AssetTypeSection) => section.title)
    }
    .width('100%')
    .height('70%')
    .padding({ left: 14, right: 14, top: 18, bottom: 12 })
    .backgroundColor('#FFFFFF')
    .borderRadius({ topLeft: 18, topRight: 18 })
    .justifyContent(FlexAlign.SpaceBetween)
  }
}

@Component
struct AssetTypeCell {
  @Prop option: AssetTypeOption = {
    type: 'custom',
    group: 'fund',
    title: '',
    icon: '',
    color: '#55B8A7'
  }
  onSelect: (option: AssetTypeOption) => void = () => {}

  build() {
    Column({ space: 4 }) {
      Text(this.option.icon)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .textAlign(TextAlign.Center)
        .width(28)
        .height(28)
        .padding({ top: 7 })
        .backgroundColor(this.option.color)
        .borderRadius(14)

      Text(this.option.title)
        .fontSize(13)
        .fontColor('#111111')
        .textAlign(TextAlign.Center)
        .maxLines(1)
    }
    .width('100%')
    .height(52)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.onSelect(this.option)
    })
  }
}
