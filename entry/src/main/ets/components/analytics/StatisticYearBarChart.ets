import { BillRecord } from '../../model/BillRecord'
import { BillRecordStore } from '../../storage/BillRecordStore'

interface StatisticYearBarItem {
  id: string
  month: number
  expense: number
  income: number
  balance: number
}

interface StatisticYearBarDateParts {
  year: number
  month: number
}

type StatisticYearMetricType = 'expense' | 'income' | 'balance'

@Component
export struct StatisticYearBarChart {
  @Watch('onYearChanged') @Prop year: number = new Date().getFullYear()
  @Watch('onBillRefreshChanged') @Prop billRefreshVersion: number = 0

  @State private items: StatisticYearBarItem[] = []
  @State private selectedMetric: StatisticYearMetricType = 'expense'

  aboutToAppear(): void {
    this.loadChartData()
  }

  build() {
    Column({ space: 16 }) {
      this.headerRow()
      this.chartCard()
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private headerRow() {
    Row() {
      Text('收支统计')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#18233A')

      Blank()

      Row({ space: 0 }) {
        this.metricToggleButton('expense', '支出')
        this.metricToggleButton('income', '收入')
        this.metricToggleButton('balance', '结余')
      }
      .border({
        width: 1,
        color: '#56BFAF'
      })
      .borderRadius(14)
      .clip(true)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private metricToggleButton(metric: StatisticYearMetricType, label: string) {
    Text(label)
      .fontSize(14)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.selectedMetric === metric ? '#FFFFFF' : '#56BFAF')
      .padding({ left: 18, right: 18, top: 10, bottom: 10 })
      .backgroundColor(this.selectedMetric === metric ? '#56BFAF' : '#FFFFFF')
      .onClick(() => {
        this.selectedMetric = metric
      })
  }

  @Builder
  private chartCard() {
    Column({ space: 0 }) {
      Column({ space: 0 }) {
        Row({ space: 0 }) {
          Column()
            .width(1)
            .height(214)
            .backgroundColor('#BFE8DF')

          Row({ space: 0 }) {
            ForEach(this.items, (item: StatisticYearBarItem) => {
              this.barSlot(item)
            }, (item: StatisticYearBarItem) => item.id)
          }
          .layoutWeight(1)
          .height(214)
          .alignItems(VerticalAlign.Bottom)
        }
        .width('100%')

        Row({ space: 0 }) {
          Column()
            .width(1)
            .height(1)
            .backgroundColor('#D6DDE8')

          Column()
            .layoutWeight(1)
            .height(1)
            .backgroundColor('#D6DDE8')
        }
        .width('100%')

        Row({ space: 0 }) {
          Column()
            .width(1)
            .height(1)
            .opacity(0)

          Row({ space: 0 }) {
            ForEach(this.items, (item: StatisticYearBarItem) => {
              this.monthLabelSlot(item)
            }, (item: StatisticYearBarItem) => item.id + '_label')
          }
          .layoutWeight(1)
        }
        .width('100%')
        .margin({ top: 10 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 18, bottom: 12 })
    .backgroundColor('#FCFCFC')
    .borderRadius(22)
  }

  @Builder
  private barSlot(item: StatisticYearBarItem) {
    Column({ space: 8 }) {
      Text(this.barValueText(item))
        .fontSize(10)
        .fontColor('#20293A')
        .textAlign(TextAlign.Center)
        .opacity(this.metricValue(item) > 0 ? 1 : 0)
        .maxLines(1)

      Column()
        .width('68%')
        .height(this.barHeight(item))
        .borderRadius(4)
        .backgroundColor(this.barColor())
    }
    .layoutWeight(1)
    .height(214)
    .justifyContent(FlexAlign.End)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private monthLabelSlot(item: StatisticYearBarItem) {
    Column() {
      Text(item.month.toString())
        .fontSize(12)
        .fontColor('#737D92')
        .textAlign(TextAlign.Center)
        .maxLines(1)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  private onYearChanged(): void {
    this.loadChartData()
  }

  private onBillRefreshChanged(): void {
    this.loadChartData()
  }

  private loadChartData(): void {
    BillRecordStore.load(getContext(this))
      .then((records: BillRecord[]) => {
        this.items = this.buildItems(records)
      })
      .catch(() => {
        this.items = this.buildItems([])
      })
  }

  private buildItems(records: BillRecord[]): StatisticYearBarItem[] {
    const items: StatisticYearBarItem[] = []

    for (let month = 1; month <= 12; month++) {
      const item: StatisticYearBarItem = {
        id: this.year.toString() + '_' + month.toString(),
        month: month,
        expense: 0,
        income: 0,
        balance: 0
      }
      items.push(item)
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

      const itemIndex = parts.month - 1
      if (itemIndex < 0 || itemIndex >= items.length) {
        continue
      }

      if (record.type === 'expense') {
        items[itemIndex].expense += record.amount
      } else if (record.type === 'income') {
        items[itemIndex].income += record.amount
      }
    }

    for (let index = 0; index < items.length; index++) {
      items[index].balance = items[index].income - items[index].expense
    }

    return items
  }

  private metricValue(item: StatisticYearBarItem): number {
    if (this.selectedMetric === 'income') {
      return item.income
    }
    if (this.selectedMetric === 'balance') {
      return item.balance > 0 ? item.balance : 0
    }
    return item.expense
  }

  private maxMetricValue(): number {
    let maxValue = 0
    for (let index = 0; index < this.items.length; index++) {
      const value = this.metricValue(this.items[index])
      if (value > maxValue) {
        maxValue = value
      }
    }
    return maxValue
  }

  private axisMaxValue(): number {
    const maxValue = this.maxMetricValue()
    if (!(maxValue > 0)) {
      return 0
    }
    return this.prettyAxisStep(maxValue / 4) * 4
  }

  private prettyAxisStep(rawValue: number): number {
    if (!(rawValue > 0)) {
      return 25
    }
    const exponent = Math.floor(Math.log10(rawValue))
    const magnitude = Math.pow(10, exponent)
    const normalized = rawValue / magnitude

    if (normalized <= 1) {
      return magnitude
    }
    if (normalized <= 2) {
      return 2 * magnitude
    }
    if (normalized <= 5) {
      return 5 * magnitude
    }
    return 10 * magnitude
  }

  private barHeight(item: StatisticYearBarItem): number {
    const value = this.metricValue(item)
    const axisMaxValue = this.axisMaxValue()
    if (!(value > 0) || !(axisMaxValue > 0)) {
      return 0
    }
    const height = value / axisMaxValue * 168
    return height < 4 ? 4 : height
  }

  private barValueText(item: StatisticYearBarItem): string {
    const value = this.metricValue(item)
    if (!(value > 0)) {
      return ''
    }
    return this.formatBarValue(value)
  }

  private formatBarValue(value: number): string {
    const fixed = value.toFixed(1)
    if (fixed.endsWith('.0')) {
      return value.toFixed(0)
    }
    return fixed
  }

  private barColor(): string {
    if (this.selectedMetric === 'income') {
      return '#56BFAF'
    }
    if (this.selectedMetric === 'balance') {
      return '#1AA8A9'
    }
    return '#FF5A5F'
  }

  private billDateParts(billDate: string): StatisticYearBarDateParts | undefined {
    const date = new Date(billDate)
    if (date.getTime() !== date.getTime()) {
      return undefined
    }
    const parts: StatisticYearBarDateParts = {
      year: date.getFullYear(),
      month: date.getMonth() + 1
    }
    return parts
  }
}
