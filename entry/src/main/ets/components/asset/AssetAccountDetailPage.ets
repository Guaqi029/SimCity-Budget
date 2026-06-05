import { AssetAccount } from '../../model/AssetAccount'

@Component
export struct AssetAccountDetailPage {
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

  @State private showMenu: boolean = false
  onBack: () => void = () => {}
  onEdit: () => void = () => {}
  onDelete: () => void = () => {}

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column({ space: 14 }) {
        this.header()
        this.balanceCard()
        this.actionBar()

        // 账单列表后续接入，这里只保留一个轻量空白区域。
        Column()
          .width('100%')
          .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F4F4F4')

      if (this.showMenu) {
        Column({ space: 0 }) {
          Text('编辑账户')
            .fontSize(14)
            .fontColor('#111111')
            .width(104)
            .height(40)
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.showMenu = false
              this.onEdit()
            })

          Divider()
            .strokeWidth(0.5)
            .color('#EEEEEE')

          Text('删除账户')
            .fontSize(14)
            .fontColor('#E07178')
            .width(104)
            .height(40)
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.showMenu = false
              this.onDelete()
            })
        }
        .margin({ top: 58, right: 12 })
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .shadow({ radius: 12, color: '#22334422', offsetY: 4 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private header() {
    Row() {
      Image($r('app.media.arrow_back'))
        .width(30)
        .height(30)
        .onClick(() => {
          this.onBack()
        })

      Text(this.asset.name)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#111111')
        .maxLines(1)
        .margin({ left: 14 })
        .layoutWeight(1)

      Text('统计')
        .fontSize(18)
        .fontColor('#111111')
        .margin({ right: 18 })

      Image($r('app.media.more_col'))
        .width(28)
        .height(28)
        .onClick(() => {
          this.showMenu = !this.showMenu
        })
    }
    .width('100%')
    .height(60)
    .padding({ left: 18, right: 18 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  private balanceCard() {
    Column({ space: 8 }) {
      Text('账户余额')
        .fontSize(16)
        .fontColor('#E9FFF8')

      Text(this.formatMoney(this.asset.balance))
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
    }
    .width('100%')
    .height(108)
    .padding({ left: 22, top: 20 })
    .alignItems(HorizontalAlign.Start)
    .backgroundColor('#55B8A7')
    .borderRadius(10)
    .margin({ left: 16, right: 16, top: 8 })
  }

  @Builder
  private actionBar() {
    Row() {
      this.actionItem('□+', '添加一条新记账')
      Column()
        .width(1)
        .height(26)
        .backgroundColor('#EFEFEF')
      this.actionItem('⇄', '转账')
    }
    .width('100%')
    .height(58)
    .backgroundColor('#FFFFFF')
    .borderRadius(10)
    .margin({ left: 16, right: 16 })
  }

  @Builder
  private actionItem(icon: string, title: string) {
    Row({ space: 10 }) {
      Text(icon)
        .fontSize(18)
        .fontColor('#111111')
      Text(title)
        .fontSize(16)
        .fontColor('#111111')
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  private formatMoney(value: number): string {
    return (value < 0 ? '-' : '') + Math.abs(value).toFixed(2)
  }
}
