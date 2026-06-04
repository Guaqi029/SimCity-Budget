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
    Column({ space: 22 }) {
      ForEach(this.sections, (section: AssetTypeSection) => {
        Column({ space: 14 }) {
          Text(section.title)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111111')

          GridRow({ columns: 5, gutter: 8 }) {
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
    .padding({ left: 18, right: 18, top: 28, bottom: 28 })
    .backgroundColor('#FFFFFF')
    .borderRadius({ topLeft: 18, topRight: 18 })
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
    Column({ space: 8 }) {
      Text(this.option.icon)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .textAlign(TextAlign.Center)
        .width(36)
        .height(36)
        .padding({ top: 9 })
        .backgroundColor(this.option.color)
        .borderRadius(18)

      Text(this.option.title)
        .fontSize(16)
        .fontColor('#111111')
        .textAlign(TextAlign.Center)
        .maxLines(1)
    }
    .width('100%')
    .height(74)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.onSelect(this.option)
    })
  }
}
