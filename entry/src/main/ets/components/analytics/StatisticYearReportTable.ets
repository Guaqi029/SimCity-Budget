import { BillRecord } from '../../model/BillRecord'
import { BillRecordStore } from '../../storage/BillRecordStore'

interface StatisticYearReportRow {
  id: string
  month: number
  monthLabel: string
  income: number
  expense: number
  balance: number
}

interface StatisticYearReportDateParts {
  year: number
  month: number
}

type StatisticYearReportSortType = 'desc' | 'asc'

@Component
export struct StatisticYearReportTable {
  @Watch('onYearChanged') @Prop year: number = new Date().getFullYear()
  @Watch('onBillRefreshChanged') @Prop billRefreshVersion: number = 0

  @State private sortType: StatisticYearReportSortType = 'desc'
  @State private rows: StatisticYearReportRow[] = []

  aboutToAppear(): void {
    this.loadRows()
  }

  build() {
    Column({ space: 0 }) {
      this.headerRow()

      if (this.rows.length > 0) {
        this.tableHead()

        Column() {
          ForEach(this.displayRows(), (row: StatisticYearReportRow) => {
            this.reportRow(row)
          }, (row: StatisticYearReportRow) => row.id + '_' + this.sortType)
        }
        .width('100%')
      } else {
        this.emptyState()
      }
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private headerRow() {
    Row() {
      Text('报表统计')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#18233A')

      Blank()

      Text(this.sortType === 'desc' ? '⇅' : '⇵')
        .fontSize(22)
        .fontWeight(FontWeight.Medium)
        .fontColor('#4F596B')
        .onClick(() => {
          this.sortType = this.sortType === 'desc' ? 'asc' : 'desc'
        })
    }
    .width('100%')
    .margin({ bottom: 20 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private tableHead() {
    Row() {
      this.headCell('月份', 1.1, TextAlign.Start)
      this.headCell('收入', 1, TextAlign.Center)
      this.headCell('支出', 1, TextAlign.Center)
      this.headCell('结余', 1, TextAlign.End)
    }
    .width('100%')
    .padding({ left: 6, right: 6, top: 10, bottom: 10 })
    .margin({ bottom: 4 })
  }

  @Builder
  private headCell(text: string, weight: number, align: TextAlign) {
    Text(text)
      .fontSize(16)
      .fontWeight(FontWeight.Bold)
      .fontColor('#18233A')
      .textAlign(align)
      .layoutWeight(weight)
  }

  @Builder
  private reportRow(row: StatisticYearReportRow) {
    Row() {
      Text(row.monthLabel)
        .fontSize(18)
        .fontColor('#18233A')
        .textAlign(TextAlign.Start)
        .layoutWeight(1.1)

      Text(this.formatMoney(row.income))
        .fontSize(18)
        .fontColor('#56BFAF')
        .textAlign(TextAlign.Center)
        .layoutWeight(1)

      Text(this.formatMoney(row.expense))
        .fontSize(18)
        .fontColor('#FF6368')
        .textAlign(TextAlign.Center)
        .layoutWeight(1)

      Text(this.formatBalance(row.balance))
        .fontSize(18)
        .fontColor('#18233A')
        .textAlign(TextAlign.End)
        .layoutWeight(1)
    }
    .width('100%')
    .padding({ left: 6, right: 6, top: 18, bottom: 18 })
  }

  @Builder
  private emptyState() {
    Column({ space: 10 }) {
      Text('当年暂无可统计的报表数据')
        .fontSize(15)
        .fontColor('#8A94A6')

      Text('新增账单后，这里会按月份生成年报表。')
        .fontSize(13)
        .fontColor('#A5AFBF')
    }
    .width('100%')
    .padding({ top: 26, bottom: 30 })
    .alignItems(HorizontalAlign.Center)
  }

  private onYearChanged(): void {
    this.loadRows()
  }

  private onBillRefreshChanged(): void {
    this.loadRows()
  }

  private loadRows(): void {
    BillRecordStore.load(getContext(this))
      .then((records: BillRecord[]) => {
        this.rows = this.buildRows(records)
      })
      .catch(() => {
        this.rows = this.buildRows([])
      })
  }

  private buildRows(records: BillRecord[]): StatisticYearReportRow[] {
    const rows: StatisticYearReportRow[] = []
    const lastMonth = this.visibleLastMonth()

    for (let month = 1; month <= lastMonth; month++) {
      const row: StatisticYearReportRow = {
        id: this.year.toString() + '_' + month.toString(),
        month: month,
        monthLabel: month.toString() + '月',
        income: 0,
        expense: 0,
        balance: 0
      }
      rows.push(row)
    }

    for (let index = 0; index < records.length; index++) {
      const record = records[index]
      const parts = this.billDateParts(record.billDate)
      if (record.isDeleted || parts === undefined) {
        continue
      }
      if (parts.year !== this.year) {
        continue
      }
      if (parts.month < 1 || parts.month > rows.length) {
        continue
      }

      const rowIndex = parts.month - 1
      if (record.type === 'income') {
        rows[rowIndex].income += record.amount
      } else if (record.type === 'expense') {
        rows[rowIndex].expense += record.amount
      }
    }

    for (let index = 0; index < rows.length; index++) {
      rows[index].balance = rows[index].income - rows[index].expense
    }

    return rows
  }

  private displayRows(): StatisticYearReportRow[] {
    if (this.sortType === 'asc') {
      return this.rows
    }

    const reversed: StatisticYearReportRow[] = []
    for (let index = this.rows.length - 1; index >= 0; index--) {
      reversed.push(this.rows[index])
    }
    return reversed
  }

  private visibleLastMonth(): number {
    const today = new Date()
    if (today.getFullYear() === this.year) {
      return today.getMonth() + 1
    }
    return 12
  }

  private formatMoney(value: number): string {
    return value.toFixed(2)
  }

  private formatBalance(value: number): string {
    return value.toFixed(2)
  }

  private billDateParts(billDate: string): StatisticYearReportDateParts | undefined {
    const date = new Date(billDate)
    if (date.getTime() !== date.getTime()) {
      return undefined
    }

    const parts: StatisticYearReportDateParts = {
      year: date.getFullYear(),
      month: date.getMonth() + 1
    }
    return parts
  }
}
