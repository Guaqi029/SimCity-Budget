import { AssetAccount } from '../../model/AssetAccount'

@Component
export struct AssetAccountPicker {
  @Prop assets: AssetAccount[] = []
  @Prop selectedAssetId: string = ''
  onSelect: (asset: AssetAccount | undefined) => void = () => {}

  build() {
    Column() {
      Column() {
        this.header()

        Scroll() {
          Column() {
            ForEach(this.assets, (asset: AssetAccount) => {
              this.assetRow(asset)
            }, (asset: AssetAccount) => asset.id)

            this.noAccountRow()
          }
          .width('100%')
          .height(this.assetListContentHeight())
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.Start)
        }
        .width('100%')
        .height(430)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius({ topLeft: 8, topRight: 8 })
      .padding({ top: 8, bottom: 10 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.End)
  }

  @Builder
  private header() {
    Row() {
      Column({ space: 4 }) {
        Text('选择账户')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111111')
        // 暂时不做
        // Text('长按拖动可进行排序')
        //   .fontSize(12)
        //   .fontColor('#9A9A9A')
      }
      .alignItems(HorizontalAlign.Start)

      Blank()
      // 暂时不做
      // Text('组合支付')
      //   .fontSize(14)
      //   .fontWeight(FontWeight.Bold)
      //   .fontColor('#55B8A7')
      // Text('≡')
      //   .fontSize(24)
      //   .fontColor('#111111')
      //   .margin({ left: 18 })
      // Text('+')
      //   .fontSize(27)
      //   .fontColor('#111111')
      //   .margin({ left: 16 })
    }
    .width('100%')
    .height(52)
    .padding({ left: 16, right: 16 })
  }

  @Builder
  private assetRow(asset: AssetAccount) {
    Row() {
      Text(asset.icon.length > 0 ? asset.icon : '账')
        .fontSize(12)
        .fontColor('#FFFFFF')
        .textAlign(TextAlign.Center)
        .width(22)
        .height(22)
        .padding({ top: 4 })
        .borderRadius(11)
        .backgroundColor(asset.color)

      Column({ space: 3 }) {
        Text(this.assetDisplayName(asset))
          .fontSize(15)
          .fontColor('#111111')
          .maxLines(1)
        if (asset.remark !== undefined && asset.remark.length > 0) {
          Text(asset.remark)
            .fontSize(12)
            .fontColor('#777777')
            .maxLines(1)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })

      Blank()

      Text(this.formatAmount(asset.balance))
        .fontSize(14)
        .fontColor(asset.balance > 0 ? '#55B8A7' : (asset.balance < 0 ? '#D95F6A' : '#222222'))
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.selectedAssetId === asset.id ? '#F2FBF8' : '#FFFFFF')
    .onClick(() => {
      this.onSelect(asset)
    })
  }

  @Builder
  private noAccountRow() {
    Row() {
      Text('无')
        .fontSize(13)
        .fontColor('#111111')
        .textAlign(TextAlign.Center)
        .width(22)
        .height(22)
        .borderRadius(11)
        .backgroundColor('#F2F2F2')
      Text('无账户')
        .fontSize(15)
        .fontColor('#111111')
        .margin({ left: 12 })
      Blank()
    }
    .width('100%')
    .height(50)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.selectedAssetId.length === 0 ? '#F2FBF8' : '#FFFFFF')
    .onClick(() => {
      this.onSelect(undefined)
    })
  }

  private assetDisplayName(asset: AssetAccount): string {
    if (asset.shortName.length > 0) {
      return asset.name + '(' + asset.shortName + ')'
    }
    return asset.name
  }

  private formatAmount(amount: number): string {
    const fixed = Math.round(amount * 100) / 100
    return fixed.toFixed(2)
  }

  private assetListContentHeight(): number {
    const rowHeight = this.assets.length * 56 + 50
    return rowHeight < 430 ? 430 : rowHeight
  }
}
