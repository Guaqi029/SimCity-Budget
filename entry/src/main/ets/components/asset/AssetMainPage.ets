import { AssetAccount, AssetGroup } from '../../model/AssetAccount'

@Component
export struct AssetMainPage {
  @Prop assets: AssetAccount[] = []
  @State private showAddButton: boolean = true
  @State private lastScrollY: number = 0
  onAddAsset: () => void = () => {}

  build() {
    Stack({alignContent:Alignment.Top}) {
      Scroll() {
        Column({ space: 16 }) {
          AssetOverviewCard({
            netAsset: this.totalIncludedBalance(),
            totalAsset: this.totalPositiveBalance(),
            liability: this.totalLiability()
          })

          if (this.assets.length === 0) {
            EmptyAssetCard({
              onAddAsset: () => {
                this.onAddAsset()
              }
            })
          } else {
            AssetGroupCard({
              title: '资金账户',
              total: this.groupBalance('fund'),
              assets: this.filterGroup('fund')
            })

            AssetGroupCard({
              title: '储蓄账户',
              total: this.groupBalance('investment'),
              assets: this.filterGroup('investment')
            })
          }
        }
        .width('100%')
        .height('100%')
        .padding({ bottom: 104 })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .onScroll((_xOffset: number, yOffset: number) => {
        this.updateAddButtonByScroll(yOffset)
      })
      .onScrollStop(() => {
        this.showAddButton = true
      })

      Text('+')
        .fontSize(46)
        .fontColor('#FFFFFF')
        .textAlign(TextAlign.Center)
        .width(60)
        .height(60)
        .padding({ top: 5 })
        .backgroundColor('#55B8A7')
        .borderRadius(30)
        .shadow({ radius: 18, color: '#3355B8A744', offsetY: 8 })
        .align(Alignment.BottomEnd)
        .margin({ right: 10, bottom: 24 })
        .scale({ x: this.showAddButton ? 1 : 0.2, y: this.showAddButton ? 1 : 0.2 })
        .opacity(this.showAddButton ? 1 : 0)
        .animation({ duration: 180, curve: Curve.EaseOut })
        .onClick(() => {
          this.onAddAsset()
        })
    }
    .width('100%')
    .height('100%')
  }

  private updateAddButtonByScroll(yOffset: number) {
    if (yOffset > this.lastScrollY + 2) {
      this.showAddButton = false
    } else if (yOffset < this.lastScrollY - 2) {
      this.showAddButton = true
    }
    this.lastScrollY = yOffset
  }

  private filterGroup(group: AssetGroup): AssetAccount[] {
    const result: AssetAccount[] = []
    for (let index = 0; index < this.assets.length; index++) {
      if (this.assets[index].group === group) {
        result.push(this.assets[index])
      }
    }
    return result
  }

  private groupBalance(group: AssetGroup): number {
    let total = 0
    for (let index = 0; index < this.assets.length; index++) {
      if (this.assets[index].group === group && this.assets[index].includeInTotal) {
        total += this.assets[index].balance
      }
    }
    return total
  }

  private totalIncludedBalance(): number {
    let total = 0
    for (let index = 0; index < this.assets.length; index++) {
      if (this.assets[index].includeInTotal) {
        total += this.assets[index].balance
      }
    }
    return total
  }

  private totalPositiveBalance(): number {
    let total = 0
    for (let index = 0; index < this.assets.length; index++) {
      if (this.assets[index].includeInTotal && this.assets[index].balance > 0) {
        total += this.assets[index].balance
      }
    }
    return total
  }

  private totalLiability(): number {
    let total = 0
    for (let index = 0; index < this.assets.length; index++) {
      if (this.assets[index].includeInTotal && this.assets[index].balance < 0) {
        total += Math.abs(this.assets[index].balance)
      }
    }
    return total
  }
}

@Component
struct EmptyAssetCard {
  onAddAsset: () => void = () => {}

  build() {
    Column({ space: 12 }) {
      Text('暂无资产账户')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#18233A')
      Text('添加银行卡、支付宝、微信或现金账户后，会在这里汇总展示')
        .fontSize(14)
        .fontColor('#7D8CA7')
        .textAlign(TextAlign.Center)
      Button('添加账户')
        .type(ButtonType.Capsule)
        .height(42)
        .fontSize(15)
        .fontColor('#FFFFFF')
        .backgroundColor('#55B8A7')
        .onClick(() => {
          this.onAddAsset()
        })
    }
    .width('100%')
    .padding(24)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
  }
}

@Component
struct AssetOverviewCard {
  @Prop netAsset: number = 0
  @Prop totalAsset: number = 0
  @Prop liability: number = 0

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width('100%')
        .height(140)
        .backgroundColor('#DDF5F2')
        .borderRadius(14)

      Text('⋮')
        .fontSize(36)
        .fontColor('#000000')
        .width(34)
        .height(60)
        .textAlign(TextAlign.Center)
        .margin({ top: 12, right: 12 })
        .align(Alignment.TopEnd)

      Row() {
        Column({ space: 18 }) {
          Row({ space: 10 }) {
            Text('净资产(元)')
              .fontSize(15)
              .fontColor('#6E7D83')
            Text('⊙')
              .fontSize(18)
              .fontColor('#8A9EA0')
          }

          Text(this.formatMoney(this.netAsset))
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor('#55B8A7')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 22 }) {
          this.metricLine('总资产', this.totalAsset)
          this.metricLine('负资产', this.liability)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: 20, right: 42, top: 28 })
    }
    .width('100%')
    .height(140)
  }

  @Builder
  private metricLine(label: string, value: number) {
    Row({ space: 16 }) {
      Text(label)
        .fontSize(16)
        .fontColor('#6E7D83')
      Text(this.formatMoney(value))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#111111')
    }
  }

  private formatMoney(value: number): string {
    return Math.abs(value).toFixed(2)
  }
}

@Component
struct SummaryTile {
  @Prop title: string = ''
  @Prop lineOneLabel: string = ''
  @Prop lineOneValue: string = ''
  @Prop lineTwoLabel: string = ''
  @Prop lineTwoValue: string = ''
  @Prop alertLineOne: boolean = false

  build() {
    Column({ space: 8 }) {
      Text(this.title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#111111')
      this.tileLine(this.lineOneLabel, this.lineOneValue, this.alertLineOne)
      this.tileLine(this.lineTwoLabel, this.lineTwoValue, false)
    }
    .height(92)
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  @Builder
  private tileLine(label: string, value: string, alert: boolean) {
    Row({ space: 2 }) {
      Text(label + ':')
        .fontSize(14)
        .fontColor('#9A9A9A')
      Text(value)
        .fontSize(14)
        .fontColor(alert ? '#E07178' : '#55B8A7')
    }
  }
}

@Component
struct AssetGroupCard {
  @Prop title: string = ''
  @Prop total: number = 0
  @Prop assets: AssetAccount[] = []

  build() {
    Column({ space: 18 }) {
      Row() {
        Text(this.title)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111111')
        Blank()
        Text(this.formatMoney(this.total))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111111')
        Text('⌄')
          .fontSize(22)
          .fontColor('#555555')
          .margin({ left: 10 })
      }
      .width('100%')

      ForEach(this.assets, (asset: AssetAccount) => {
        AssetAccountRow({ asset: asset })
      }, (asset: AssetAccount) => asset.id)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
    .alignItems(HorizontalAlign.Start)
  }

  private formatMoney(value: number): string {
    return (value < 0 ? '-' : '') + Math.abs(value).toFixed(2)
  }
}

@Component
struct AssetAccountRow {
  @Prop asset: AssetAccount = {
    id: '',
    type: 'custom',
    group: 'fund',
    name: '',
    balance: 0,
    shortName: '',
    icon: '',
    color: '#55B8A7',
    includeInTotal: true,
    bookScope: '全部账本',
    createTime: '',
    updateTime: '',
    isDeleted: false
  }

  build() {
    Row({ space: 14 }) {
      Text(this.asset.icon)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .textAlign(TextAlign.Center)
        .width(32)
        .height(32)
        .padding({ top: 8 })
        .backgroundColor(this.asset.color)
        .borderRadius(16)

      Text(this.asset.name)
        .fontSize(20)
        .fontColor('#111111')
        .layoutWeight(1)

      Text(this.formatMoney(this.asset.balance))
        .fontSize(20)
        .fontColor(this.asset.balance === 0 ? '#111111' : '#55B8A7')
    }
    .width('100%')
    .height(58)
  }

  private formatMoney(value: number): string {
    return (value < 0 ? '-' : '') + Math.abs(value).toFixed(2)
  }
}
