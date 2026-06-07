import { BillRecord } from '../../model/BillRecord'
import { BillRecordStore } from '../../storage/BillRecordStore'

interface StatisticMonthBarItem {
  id: string
  day: number
  expense: number
  income: number
}

interface StatisticMonthDateParts {
  year: number
  month: number
  day: number
}

interface StatisticMonthLabelGroup {
  id: string
  label: string
  spanDays: number
}

type StatisticMonthMetricType = 'expense' | 'income'

@Component
export struct StatisticMonthBarChart {
  @Watch('onPeriodChanged') @Prop year: number = new Date().getFullYear()
  @Watch('onPeriodChanged') @Prop month: number = new Date().getMonth() + 1
  @Watch('onBillRefreshChanged') @Prop billRefreshVersion: number = 0

  @State private items: StatisticMonthBarItem[] = []
  @State private selectedMetric: StatisticMonthMetricType = 'expense'

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
      Row({ space: 8 }) {
        Text('收支统计')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#18233A')

        Text('⌟')
          .fontSize(20)
          .fontColor('#737D92')
      }
      .alignItems(VerticalAlign.Center)

      Blank()

      Row({ space: 0 }) {
        this.metricToggleButton('expense', '支出')
        this.metricToggleButton('income', '收入')
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
  private metricToggleButton(metric: StatisticMonthMetricType, label: string) {
    Text(label)
      .fontSize(14)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.selectedMetric === metric ? '#FFFFFF' : '#56BFAF')
      .padding({ left: 26, right: 26, top: 10, bottom: 10 })
      .backgroundColor(this.selectedMetric === metric ? '#56BFAF' : '#FFFFFF')
      .onClick(() => {
        this.selectedMetric = metric
      })
  }

  @Builder
  private chartCard() {
    Column({ space: 0 }) {
      Row({ space: 0 }) {
        this.axisLabelColumn()

        Column({ space: 0 }) {
          Row({ space: 0 }) {
            Column()
              .width(1)
              .height(180)
              .backgroundColor('#BFE8DF')

            Row({ space: 0 }) {
              ForEach(this.items, (item: StatisticMonthBarItem) => {
                this.barSlot(item)
              }, (item: StatisticMonthBarItem) => item.id)
            }
            .layoutWeight(1)
            .height(180)
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
              ForEach(this.dayLabelGroups(), (group: StatisticMonthLabelGroup) => {
                this.dayLabelSlot(group)
              }, (group: StatisticMonthLabelGroup) => group.id)
            }
            .layoutWeight(1)
          }
          .width('100%')
          .margin({ top: 8 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Bottom)
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 18, bottom: 10 })
    .backgroundColor('#FCFCFC')
    .borderRadius(22)
  }

  @Builder
  private axisLabelColumn() {
    Column() {
      ForEach(this.axisLabels(), (label: string) => {
        Text(label)
          .fontSize(11)
          .fontColor('#737D92')
          .width('100%')
          .textAlign(TextAlign.End)
      }, (label: string, index: number) => label + '_' + index.toString())
    }
    .width(34)
    .height(180)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ right: 10 })
  }

  @Builder
  private barSlot(item: StatisticMonthBarItem) {
    Column() {
      Column()
        .width(this.barWidthPercent())
        .height(this.barHeight(item))
        .borderRadius(4)
        .backgroundColor(this.barColor())
    }
    .layoutWeight(1)
    .height(180)
    .justifyContent(FlexAlign.End)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private dayLabelSlot(group: StatisticMonthLabelGroup) {
    Column() {
      Text(group.label)
        .fontSize(10)
        .fontColor('#737D92')
        .textAlign(TextAlign.Center)
        .maxLines(1)
    }
    .layoutWeight(group.spanDays)
    .alignItems(HorizontalAlign.Center)
  }

  private onPeriodChanged(): void {
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

  private buildItems(records: BillRecord[]): StatisticMonthBarItem[] {
    const items: StatisticMonthBarItem[] = []
    const daysInMonth = this.daysInSelectedMonth()

    for (let day = 1; day <= daysInMonth; day++) {
      items.push({
        id: this.year.toString() + '-' + this.pad2(this.month) + '-' + this.pad2(day),
        day: day,
        expense: 0,
        income: 0
      })
    }

    for (let index = 0; index < records.length; index++) {
      const record = records[index]
      const parts = this.billDateParts(record.billDate)
      if (record.isDeleted || parts === undefined) {
        continue
      }
      if (parts.year !== this.year || parts.month !== this.month) {
        continue
      }
      const itemIndex = parts.day - 1
      if (itemIndex < 0 || itemIndex >= items.length) {
        continue
      }
      if (record.type === 'expense') {
        items[itemIndex].expense += record.amount
      } else if (record.type === 'income') {
        items[itemIndex].income += record.amount
      }
    }

    return items
  }

  private metricValue(item: StatisticMonthBarItem): number {
    return this.selectedMetric === 'expense' ? item.expense : item.income
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

  private axisLabels(): string[] {
    const labels: string[] = []
    const axisMaxValue = this.axisMaxValue()
    if (!(axisMaxValue > 0)) {
      for (let index = 0; index < 5; index++) {
        labels.push('0')
      }
      return labels
    }
    const step = axisMaxValue / 4

    for (let index = 4; index >= 0; index--) {
      labels.push(this.formatAxisValue(step * index))
    }
    return labels
  }

  private barHeight(item: StatisticMonthBarItem): number {
    const value = this.metricValue(item)
    const axisMaxValue = this.axisMaxValue()
    if (!(value > 0) || !(axisMaxValue > 0)) {
      return 0
    }
    const height = value / axisMaxValue * 180
    return height < 4 ? 4 : height
  }

  private barWidthPercent(): string {
    const dayCount = this.items.length
    if (dayCount >= 31) {
      return '46%'
    }
    if (dayCount >= 30) {
      return '50%'
    }
    if (dayCount >= 29) {
      return '54%'
    }
    return '58%'
  }

  private barColor(): string {
    return this.selectedMetric === 'expense' ? '#FF5A5F' : '#56BFAF'
  }

  private dayLabelGroups(): StatisticMonthLabelGroup[] {
    const groups: StatisticMonthLabelGroup[] = []
    const dayCount = this.items.length
    const step = dayCount <= 16 ? 1 : 2
    let day = 1

    while (day <= dayCount) {
      let spanDays = step
      if (day + spanDays - 1 > dayCount) {
        spanDays = dayCount - day + 1
      }

      const group: StatisticMonthLabelGroup = {
        id: 'label_' + day.toString(),
        label: day.toString(),
        spanDays: spanDays
      }
      groups.push(group)
      day += step
    }

    return groups
  }

  private formatAxisValue(value: number): string {
    if (Math.abs(value - Math.round(value)) < 0.001) {
      return Math.round(value).toString()
    }
    return value.toFixed(1)
  }

  private daysInSelectedMonth(): number {
    return new Date(this.year, this.month, 0).getDate()
  }

  private billDateParts(billDate: string): StatisticMonthDateParts | undefined {
    const date = new Date(billDate)
    if (date.getTime() !== date.getTime()) {
      return undefined
    }
    const dateParts: StatisticMonthDateParts = {
      year: date.getFullYear(),
      month: date.getMonth() + 1,
      day: date.getDate()
    }
    return dateParts
  }

  private pad2(value: number): string {
    return value < 10 ? '0' + value.toString() : value.toString()
  }
}
