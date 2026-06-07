import { BillRecord } from '../../model/BillRecord'
import { BillRecordStore } from '../../storage/BillRecordStore'

interface StatisticYearMetricItem {
  label: string
  value: number
}

interface StatisticYearSummaryData {
  yearExpense: number
  yearIncome: number
  yearBalance: number
  averageExpense: number
  averageIncome: number
  averageBalance: number
  transferAmount: number
  repayAmount: number
  topUpAmount: number
  transferFeeAmount: number
  reimburseIncomeAmount: number
  refundIncomeAmount: number
}

function createEmptyYearSummaryData(): StatisticYearSummaryData {
  return {
    yearExpense: 0,
    yearIncome: 0,
    yearBalance: 0,
    averageExpense: 0,
    averageIncome: 0,
    averageBalance: 0,
    transferAmount: 0,
    repayAmount: 0,
    topUpAmount: 0,
    transferFeeAmount: 0,
    reimburseIncomeAmount: 0,
    refundIncomeAmount: 0
  }
}

@Component
export struct StatisticYearSummaryCard {
  @Watch('onYearChanged') @Prop year: number = new Date().getFullYear()
  @Watch('onBillRefreshChanged') @Prop billRefreshVersion: number = 0

  @State private expanded: boolean = false
  @State private summary: StatisticYearSummaryData = createEmptyYearSummaryData()

  aboutToAppear(): void {
    this.loadSummary()
  }

  build() {
    Column({ space: this.expanded ? 28 : 18 }) {
      this.topMetricRow()

      if (this.expanded) {
        this.metricRow(this.averageMetrics())
        this.metricRow(this.transferMetrics())
        this.metricRow(this.adjustmentMetrics())
      }

      Row() {
        Blank()
        Text(this.expanded ? '⌃' : '⌄')
          .fontSize(20)
          .fontColor('#F7FFFD')
          .fontWeight(FontWeight.Medium)
        Blank()
      }
      .width('100%')
      .onClick(() => {
        this.expanded = !this.expanded
      })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 18, bottom: 14 })
    .backgroundColor('#55B8A7')
    .borderRadius(18)
  }

  @Builder
  private topMetricRow() {
    Row() {
      Column({ space: 10 }) {
        Text('年支出')
          .fontSize(14)
          .fontColor('#F4FFFD')
          .fontWeight(FontWeight.Regular)
          .textAlign(TextAlign.Center)

        Text(this.formatMetricValue(this.summary.yearExpense))
          .fontSize(19)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
      }
      .width('31%')
      .alignItems(HorizontalAlign.Center)

      Column({ space: 10 }) {
        Text('年收入')
          .fontSize(14)
          .fontColor('#F4FFFD')
          .fontWeight(FontWeight.Regular)
          .textAlign(TextAlign.Center)

        Text(this.formatMetricValue(this.summary.yearIncome))
          .fontSize(19)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
      }
      .width('31%')
      .alignItems(HorizontalAlign.Center)

      Column({ space: 10 }) {
        Text('年结余')
          .fontSize(14)
          .fontColor('#F4FFFD')
          .fontWeight(FontWeight.Regular)
          .textAlign(TextAlign.Center)

        Text(this.formatMetricValue(this.summary.yearBalance))
          .fontSize(19)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
      }
      .width('31%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  private metricRow(items: StatisticYearMetricItem[]) {
    Row() {
      ForEach(items, (item: StatisticYearMetricItem) => {
        this.metricCell(item)
      }, (item: StatisticYearMetricItem) => item.label + '_' + this.formatMetricValue(item.value))
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  private metricCell(item: StatisticYearMetricItem) {
    Column({ space: 10 }) {
      Text(item.label)
        .fontSize(14)
        .fontColor('#F4FFFD')
        .fontWeight(FontWeight.Regular)
        .textAlign(TextAlign.Center)

      Text(this.formatMetricValue(item.value))
        .fontSize(19)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
    }
    .width('31%')
    .alignItems(HorizontalAlign.Center)
  }

  private onYearChanged(): void {
    this.loadSummary()
  }

  private onBillRefreshChanged(): void {
    this.loadSummary()
  }

  private loadSummary(): void {
    BillRecordStore.load(getContext(this))
      .then((records: BillRecord[]) => {
        this.summary = this.buildSummary(records)
      })
      .catch(() => {
        this.summary = createEmptyYearSummaryData()
      })
  }

  private buildSummary(records: BillRecord[]): StatisticYearSummaryData {
    let yearExpense = 0
    let yearIncome = 0
    let transferAmount = 0
    let repayAmount = 0
    let topUpAmount = 0
    let transferFeeAmount = 0
    let reimburseIncomeAmount = 0
    let refundIncomeAmount = 0

    for (let index = 0; index < records.length; index++) {
      const record = records[index]
      if (record.isDeleted || !this.isInSelectedYear(record.billDate)) {
        continue
      }

      if (record.type === 'expense') {
        yearExpense += record.amount
      } else if (record.type === 'income') {
        yearIncome += record.amount
      } else if (record.type === 'transfer') {
        transferAmount += record.amount
      }

      if (record.type === 'transfer' && record.categoryId === 'transfer_repay') {
        repayAmount += record.amount
      }

      if (record.type === 'transfer' && record.categoryId === 'transfer_top_up') {
        topUpAmount += record.amount
      }

      if (record.type === 'transfer' && record.transferFee !== undefined) {
        transferFeeAmount += record.transferFee
      }

      if (record.type === 'income' && record.categoryId === 'income_reimburse') {
        reimburseIncomeAmount += record.amount
      }

      if (record.type === 'income' && record.categoryId === 'income_refund') {
        refundIncomeAmount += record.amount
      }
    }

    const yearBalance = yearIncome - yearExpense
    const summary: StatisticYearSummaryData = {
      yearExpense: yearExpense,
      yearIncome: yearIncome,
      yearBalance: yearBalance,
      averageExpense: yearExpense / 12,
      averageIncome: yearIncome / 12,
      averageBalance: yearBalance / 12,
      transferAmount: transferAmount,
      repayAmount: repayAmount,
      topUpAmount: topUpAmount,
      transferFeeAmount: transferFeeAmount,
      reimburseIncomeAmount: reimburseIncomeAmount,
      refundIncomeAmount: refundIncomeAmount
    }
    return summary
  }

  private averageMetrics(): StatisticYearMetricItem[] {
    const items: StatisticYearMetricItem[] = []
    items.push({ label: '月均支出', value: this.summary.averageExpense })
    items.push({ label: '月均收入', value: this.summary.averageIncome })
    items.push({ label: '月均结余', value: this.summary.averageBalance })
    return items
  }

  private transferMetrics(): StatisticYearMetricItem[] {
    const items: StatisticYearMetricItem[] = []
    items.push({ label: '转账', value: this.summary.transferAmount })
    items.push({ label: '还款', value: this.summary.repayAmount })
    items.push({ label: '充值', value: this.summary.topUpAmount })
    return items
  }

  private adjustmentMetrics(): StatisticYearMetricItem[] {
    const items: StatisticYearMetricItem[] = []
    items.push({ label: '报销收入', value: this.summary.reimburseIncomeAmount })
    items.push({ label: '退款收入', value: this.summary.refundIncomeAmount })
    items.push({ label: '手续费', value: this.summary.transferFeeAmount })
    return items
  }

  private isInSelectedYear(billDate: string): boolean {
    const date = new Date(billDate)
    if (date.getTime() !== date.getTime()) {
      return false
    }
    return date.getFullYear() === this.year
  }

  private formatMetricValue(value: number): string {
    const rounded = Math.round(value * 100) / 100
    if (Math.abs(rounded) < 0.005) {
      return '0.00'
    }
    return rounded.toFixed(2)
  }
}
