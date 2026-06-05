import { HomeBillDayGroup, HomeBillItem } from './MockBillData'

@Component
export struct HomeBillTimeline {
  @Prop groups: HomeBillDayGroup[] = []

  build() {
    Column({ space: 10 }) {
      ForEach(this.groups, (group: HomeBillDayGroup) => {
        BillDaySection({ group: group })
      }, (group: HomeBillDayGroup) => group.id)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}

@Component
struct BillDaySection {
  @Prop group: HomeBillDayGroup = {
    id: '',
    dateTitle: '',
    weekTitle: '',
    income: 0,
    expense: 0,
    bills: []
  }

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
        ForEach(this.group.bills, (bill: HomeBillItem) => {
          BillTimelineRow({ bill: bill })
        }, (bill: HomeBillItem) => bill.id)
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
  @Prop bill: HomeBillItem = {
    id: '',
    type: 'expense',
    icon: '',
    title: '',
    remark: '',
    category: '',
    assetName: '',
    amount: 0,
    date: ''
  }

  build() {
    Row({ space: 10 }) {
      Text(this.bill.icon)
        .fontSize(12)
        .fontColor('#3C5652')
        .textAlign(TextAlign.Center)
        .width(24)
        .height(24)
        .padding({ top: 5 })
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
          .fontColor(this.bill.type === 'income' ? '#55B8A7' : '#E07178')
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
  }

  private amountText(): string {
    const prefix = this.bill.type === 'income' ? '+' : '-'
    return prefix + this.bill.amount.toFixed(2)
  }
}
