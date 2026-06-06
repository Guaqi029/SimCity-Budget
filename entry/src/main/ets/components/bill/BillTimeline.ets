export interface BillTimelineItem {
  id: string
  type: 'income' | 'expense' | 'transfer'
  icon: string
  iconResource?: Resource
  title: string
  remark: string
  category: string
  assetName: string
  amount: number
  date: string
}

export interface BillTimelineDayGroup {
  id: string
  dateTitle: string
  weekTitle: string
  income: number
  expense: number
  bills: BillTimelineItem[]
}

@Component
export struct BillTimeline {
  @Prop groups: BillTimelineDayGroup[] = []
  onOpenBill: (billId: string) => void = () => {}

  build() {
    Column({ space: 10 }) {
      if (this.groups.length === 0) {
        Text('暂无账单')
          .fontSize(14)
          .fontColor('#8A94A6')
          .width('100%')
          .height(54)
          .textAlign(TextAlign.Center)
          .padding({ top: 18 })
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
      } else {
        ForEach(this.groups, (group: BillTimelineDayGroup) => {
          BillDaySection({
            group: group,
            onOpenBill: (billId: string) => {
              this.onOpenBill(billId)
            }
          })
        }, (group: BillTimelineDayGroup) => group.id)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}

@Component
struct BillDaySection {
  @Prop group: BillTimelineDayGroup = {
    id: '',
    dateTitle: '',
    weekTitle: '',
    income: 0,
    expense: 0,
    bills: []
  }
  onOpenBill: (billId: string) => void = () => {}

  build() {
    Column({ space: 4 }) {
      Row() {
        Text(this.group.dateTitle)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111111')
        Text(this.group.weekTitle)
          .fontSize(14)
          .fontColor('#777777')
          .margin({ left: 12 })

        Blank()

        Text('收 ' + this.formatMoney(this.group.income))
          .fontSize(13)
          .fontColor('#55B8A7')
        Text('支 ' + this.formatMoney(this.group.expense))
          .fontSize(13)
          .fontColor('#E07178')
          .margin({ left: 14 })
      }
      .width('100%')
      .height(26)

      Column({ space: 0 }) {
        ForEach(this.group.bills, (bill: BillTimelineItem) => {
          BillTimelineRow({
            bill: bill,
            onOpenBill: (billId: string) => {
              this.onOpenBill(billId)
            }
          })
        }, (bill: BillTimelineItem) => bill.id)
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor('#FFFFFF')
      .borderRadius(8)
    }
    .width('100%')
  }

  private formatMoney(value: number): string {
    return value.toFixed(2)
  }
}

@Component
struct BillTimelineRow {
  @Prop bill: BillTimelineItem = {
    id: '',
    type: 'expense',
    icon: '',
    iconResource: undefined,
    title: '',
    remark: '',
    category: '',
    assetName: '',
    amount: 0,
    date: ''
  }
  onOpenBill: (billId: string) => void = () => {}

  build() {
    Row({ space: 10 }) {
      Stack({ alignContent: Alignment.Center }) {
        if (this.bill.iconResource !== undefined) {
          Image(this.bill.iconResource)
            .width(18)
            .height(18)
            .objectFit(ImageFit.Contain)
        } else {
          Text(this.bill.icon)
            .fontSize(12)
            .fontColor('#3C5652')
            .textAlign(TextAlign.Center)
        }
      }
      .width(24)
      .height(24)
      .border({ width: 1, color: '#DDE8E5' })
      .borderRadius(4)

      Column({ space: 3 }) {
        Text(this.bill.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111111')
          .maxLines(1)

        Text(this.bill.category + '-' + this.bill.remark)
          .fontSize(11)
          .fontColor('#777777')
          .maxLines(1)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Column({ space: 4 }) {
        Text(this.amountText())
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.amountColor())
          .maxLines(1)
          .textAlign(TextAlign.End)

        Text(this.bill.assetName)
          .fontSize(11)
          .fontColor('#666666')
          .maxLines(1)
          .textAlign(TextAlign.End)
      }
      .alignItems(HorizontalAlign.End)
      .width(82)
    }
    .width('100%')
    .height(48)
    .onClick(() => {
      this.onOpenBill(this.bill.id)
    })
  }

  private amountText(): string {
    const prefix = this.bill.type === 'income' ? '+' : (this.bill.type === 'transfer' ? '' : '-')
    return prefix + this.bill.amount.toFixed(2)
  }

  private amountColor(): string {
    if (this.bill.type === 'income') {
      return '#55B8A7'
    }
    if (this.bill.type === 'transfer') {
      return '#666666'
    }
    return '#E07178'
  }
}
