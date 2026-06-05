import { AssetAccount, AssetGroup } from '../../model/AssetAccount'

@Component
export struct AssetMainPage {
  @Prop assets: AssetAccount[] = []
  @State private showAddButton: boolean = true
  @State private lastScrollY: number = 0
  onAddAsset: () => void = () => {}
  onOpenAsset: (asset: AssetAccount) => void = () => {}

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Scroll() {
        Column({ space: 12 }) {
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
            this.assetGroup('资金账户', 'fund')
            this.assetGroup('信贷账户', 'credit')
            this.assetGroup('充值账户', 'stored_value')
            this.assetGroup('储蓄账户', 'investment')
            this.assetGroup('二手货物', 'second_hand')
            this.assetGroup('债务', 'debt')
          }
        }
        .width('100%')
        // 只给内容区设置最小高度：短内容也能多出约 10% 可滚动空间，长内容则按真实高度继续增长。
        .constraintSize({ minHeight: '110%' })
        .padding({ bottom: 104 })
      }
      .width('100%')
      .height('100%')
      .align(Alignment.TopStart)
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
        .width(50)
        .height(50)
        .backgroundColor('#55B8A7')
        .borderRadius(25)
        .shadow({ radius: 18, color: '#3355B8A744', offsetY: 8 })
        .margin({ right: 16, bottom: 18 })
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

  @Builder
  private assetGroup(title: string, group: AssetGroup) {
    if (this.hasGroup(group)) {
      AssetGroupCard({
        title: title,
        total: this.groupBalance(group),
        assets: this.filterGroup(group),
        onOpenAsset: (asset: AssetAccount) => {
          this.onOpenAsset(asset)
        }
      })
    }
  }

  private hasGroup(group: AssetGroup): boolean {
    for (let index = 0; index < this.assets.length; index++) {
      if (this.assets[index].group === group) {
        return true
      }
    }
    return false
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
      const balance = Number(this.assets[index].balance)
      if (this.assets[index].group === group && this.assets[index].includeInTotal && balance === balance) {
        total += balance
      }
    }
    return total
  }

  private totalIncludedBalance(): number {
    let total = 0
    for (let index = 0; index < this.assets.length; index++) {
      const asset = this.assets[index]
      const balance = Number(asset.balance)

      if (asset.includeInTotal && balance === balance) {
        total += balance
      }
    }
    return total
  }

  private totalPositiveBalance(): number {
    let total = 0
    for (let index = 0; index < this.assets.length; index++) {
      const asset = this.assets[index]
      const balance = Number(asset.balance)

      if (asset.includeInTotal && balance > 0) {
        total += balance
      }
    }
    return total
  }

  private totalLiability(): number {
    let total = 0
    for (let index = 0; index < this.assets.length; index++) {
      const asset = this.assets[index]
      const balance = Number(asset.balance)

      if (asset.includeInTotal && balance < 0) {
        total += Math.abs(balance)
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
          this.totalAssetLine()
          this.liabilityLine()
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
  private totalAssetLine() {
    Row({ space: 16 }) {
      Text('总资产')
        .fontSize(16)
        .fontColor('#6E7D83')
      Text(this.formatMoney(this.totalAsset))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#111111')
    }
  }

  @Builder
  private liabilityLine() {
    Row({ space: 16 }) {
      Text('负资产')
        .fontSize(16)
        .fontColor('#6E7D83')
      Text(this.formatMoney(this.liability))
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
  @State private expanded: boolean = true
  onOpenAsset: (asset: AssetAccount) => void = () => {}

  build() {
    Column({ space: 8 }) {
      Row() {
        Text(this.title)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111111')
        Blank()
        Text(this.formatMoney(this.total))
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111111')

        Image(this.expanded ? $r('app.media.arrow_down') : $r('app.media.arrow_forward'))
          .width(24)
          .height(24)
          .margin({ left: 8 })
          .animation({ duration: 180, curve: Curve.EaseOut })
      }
      .width('100%')
      .height(28)
      .onClick(() => {
        this.expanded = !this.expanded
      })

      Column({ space: 4 }) {
        ForEach(this.assets, (asset: AssetAccount) => {
          AssetAccountRow({
            asset: asset,
            onOpenAsset: (nextAsset: AssetAccount) => {
              this.onOpenAsset(nextAsset)
            }
          })
        }, (asset: AssetAccount) => asset.id)
      }
      .width('100%')
      .height(this.expanded ? this.groupContentHeight() : 0)
      .opacity(this.expanded ? 1 : 0)
      .clip(true)
      .animation({ duration: 220, curve: Curve.EaseInOut })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  private formatMoney(value: number): string {
    return (value < 0 ? '-' : '') + Math.abs(value).toFixed(2)
  }

  private groupContentHeight(): number {
    if (this.assets.length === 0) {
      return 0
    }
    return this.assets.length * 56 + (this.assets.length - 1) * 4
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
  onOpenAsset: (asset: AssetAccount) => void = () => {}

  build() {
    Row({ space: 10 }) {
      Text(this.asset.icon)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .textAlign(TextAlign.Center)
        .width(26)
        .height(26)
        .padding({ top: 6 })
        .backgroundColor(this.asset.color)
        .borderRadius(13)

      Column({ space: 2 }) {
        Text(this.displayName())
          .fontSize(16)
          .fontColor('#111111')
          .maxLines(1)

        if (this.hasRemark()) {
          Text(this.remarkText())
            .fontSize(12)
            .fontColor('#8A8A8A')
            .maxLines(1)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text(this.formatMoney(this.asset.balance))
        .fontSize(16)
        .fontColor(this.balanceColor())
        .maxLines(1)
    }
    .width('100%')
    .height(56)
    .onClick(() => {
      this.onOpenAsset(this.asset)
    })
  }

  private displayName(): string {
    if (this.asset.shortName.length === 0) {
      return this.asset.name
    }
    return this.asset.name + '(' + this.asset.shortName + ')'
  }

  private hasRemark(): boolean {
    return this.asset.remark !== undefined && this.asset.remark.length > 0
  }

  private remarkText(): string {
    if (this.asset.remark === undefined) {
      return ''
    }
    return this.asset.remark
  }

  private formatMoney(value: number): string {
    return (value < 0 ? '-' : '') + Math.abs(value).toFixed(2)
  }

  private balanceColor(): string {
    if (this.asset.balance > 0) {
      return '#55B8A7'
    }
    if (this.asset.balance < 0) {
      return '#E07178'
    }
    return '#9A9A9A'
  }
}
