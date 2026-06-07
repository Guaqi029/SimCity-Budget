import { BillRecord } from '../../model/BillRecord'
import { BillRecordStore } from '../../storage/BillRecordStore'

interface StatisticYearHeatDayValue {
  income: number
  expense: number
  balance: number
}

interface StatisticYearHeatCell {
  id: string
  visible: boolean
  month: number
  day: number
  metricValue: number
  level: number
}

interface StatisticYearHeatMonthSection {
  month: number
  cells: StatisticYearHeatCell[]
}

interface StatisticYearHeatDateParts {
  year: number
  month: number
  day: number
}

type StatisticYearHeatMetricType = 'expense' | 'income' | 'balance'

@Component
export struct StatisticYearHeatMap {
  private readonly monthPanelGap: number = 12

  @Watch('onYearChanged') @Prop year: number = new Date().getFullYear()
  @Watch('onBillRefreshChanged') @Prop billRefreshVersion: number = 0

  @State private selectedMetric: StatisticYearHeatMetricType = 'expense'
  @State private monthSections: StatisticYearHeatMonthSection[] = []
  @State private gridWidth: number = 0

  aboutToAppear(): void {
    this.loadSections()
  }

  build() {
    Column({ space: 18 }) {
      this.headerRow()
      this.monthGrid()
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
      Text('收支热力')
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
  private metricToggleButton(metric: StatisticYearHeatMetricType, label: string) {
    Text(label)
      .fontSize(14)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.selectedMetric === metric ? '#FFFFFF' : '#56BFAF')
      .padding({ left: 18, right: 18, top: 10, bottom: 10 })
      .backgroundColor(this.selectedMetric === metric ? '#56BFAF' : '#FFFFFF')
      .onClick(() => {
        this.selectedMetric = metric
        this.loadSections()
      })
  }

  @Builder
  private monthGrid() {
    Column({ space: 20 }) {
      ForEach(this.monthRows(), (row: StatisticYearHeatMonthSection[]) => {
        Row({ space: this.monthPanelGap }) {
          ForEach(row, (section: StatisticYearHeatMonthSection) => {
            this.monthPanel(section)
          }, (section: StatisticYearHeatMonthSection) => 'month_' + section.month.toString())
        }
        .width('100%')
      }, (_row: StatisticYearHeatMonthSection[], index: number) => 'row_' + index.toString())
    }
    .width('100%')
    .onAreaChange((_oldValue, newValue) => {
      const nextWidth = Number(newValue.width)
      if (nextWidth > 0 && Math.abs(nextWidth - this.gridWidth) > 0.5) {
        this.gridWidth = nextWidth
      }
    })
  }

  @Builder
  private monthPanel(section: StatisticYearHeatMonthSection) {
    Column({ space: 12 }) {
      Text(section.month.toString() + '月')
        .fontSize(16)
        .fontColor('#5C6474')
        .fontWeight(FontWeight.Medium)

      Column({ space: 0 }) {
        ForEach(this.cellRows(section.cells), (row: StatisticYearHeatCell[], rowIndex: number) => {
          Row({ space: 0 }) {
            ForEach(row, (cell: StatisticYearHeatCell) => {
              this.dayDot(cell)
            }, (cell: StatisticYearHeatCell) => cell.id)
          }
          .width(this.monthPanelWidth())
        }, (_row: StatisticYearHeatCell[], rowIndex: number) => section.month.toString() + '_row_' + rowIndex.toString())
      }
    }
    .width(this.monthPanelWidth())
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private dayDot(cell: StatisticYearHeatCell) {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width(this.dotSize())
        .height(this.dotSize())
        .borderRadius(this.dotSize() / 2)
        .backgroundColor(this.dotColor(cell))
        .opacity(cell.visible ? 1 : 0)
    }
    .width(this.dotUnit())
    .height(this.dotUnit())
  }

  private onYearChanged(): void {
    this.loadSections()
  }

  private onBillRefreshChanged(): void {
    this.loadSections()
  }

  private loadSections(): void {
    BillRecordStore.load(getContext(this))
      .then((records: BillRecord[]) => {
        this.monthSections = this.buildMonthSections(records)
      })
      .catch(() => {
        this.monthSections = this.buildMonthSections([])
      })
  }

  private buildMonthSections(records: BillRecord[]): StatisticYearHeatMonthSection[] {
    const monthValues = this.buildMonthValueMap(records)
    const maxValue = this.maxMetricValue(monthValues)
    const sections: StatisticYearHeatMonthSection[] = []

    for (let month = 1; month <= 12; month++) {
      const section: StatisticYearHeatMonthSection = {
        month: month,
        cells: this.buildMonthCells(month, monthValues, maxValue)
      }
      sections.push(section)
    }

    return sections
  }

  private buildMonthValueMap(records: BillRecord[]): StatisticYearHeatDayValue[][] {
    const monthValues: StatisticYearHeatDayValue[][] = []

    for (let month = 0; month < 12; month++) {
      const dayValues: StatisticYearHeatDayValue[] = []
      const daysInMonth = new Date(this.year, month + 1, 0).getDate()
      for (let day = 1; day <= daysInMonth; day++) {
        const value: StatisticYearHeatDayValue = {
          income: 0,
          expense: 0,
          balance: 0
        }
        dayValues.push(value)
      }
      monthValues.push(dayValues)
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

      const monthIndex = parts.month - 1
      const dayIndex = parts.day - 1
      if (monthIndex < 0 || monthIndex >= monthValues.length) {
        continue
      }
      if (dayIndex < 0 || dayIndex >= monthValues[monthIndex].length) {
        continue
      }

      if (record.type === 'expense') {
        monthValues[monthIndex][dayIndex].expense += record.amount
      } else if (record.type === 'income') {
        monthValues[monthIndex][dayIndex].income += record.amount
      }
    }

    for (let monthIndex = 0; monthIndex < monthValues.length; monthIndex++) {
      for (let dayIndex = 0; dayIndex < monthValues[monthIndex].length; dayIndex++) {
        monthValues[monthIndex][dayIndex].balance =
          monthValues[monthIndex][dayIndex].income - monthValues[monthIndex][dayIndex].expense
      }
    }

    return monthValues
  }

  private buildMonthCells(month: number, monthValues: StatisticYearHeatDayValue[][], maxValue: number): StatisticYearHeatCell[] {
    const cells: StatisticYearHeatCell[] = []
    const firstDayOffset = this.monthStartOffset(month)
    const daysInMonth = new Date(this.year, month, 0).getDate()

    for (let index = 0; index < 42; index++) {
      const visible = index >= firstDayOffset && index < firstDayOffset + daysInMonth
      let day = 0
      let metricValue = 0
      let level = 0

      if (visible) {
        day = index - firstDayOffset + 1
        metricValue = this.dayMetricValue(monthValues[month - 1][day - 1])
        level = this.metricLevel(metricValue, maxValue)
      }

      const cell: StatisticYearHeatCell = {
        id: this.year.toString() + '_' + month.toString() + '_' + index.toString(),
        visible: visible,
        month: month,
        day: day,
        metricValue: metricValue,
        level: level
      }
      cells.push(cell)
    }

    return cells
  }

  private monthRows(): StatisticYearHeatMonthSection[][] {
    const rows: StatisticYearHeatMonthSection[][] = []
    let currentRow: StatisticYearHeatMonthSection[] = []

    for (let index = 0; index < this.monthSections.length; index++) {
      currentRow.push(this.monthSections[index])
      if (currentRow.length === 4) {
        rows.push(currentRow)
        currentRow = []
      }
    }

    if (currentRow.length > 0) {
      rows.push(currentRow)
    }

    return rows
  }

  private monthPanelWidth(): number {
    if (!(this.gridWidth > 0)) {
      return 69
    }
    return (this.gridWidth - this.monthPanelGap * 3) / 4
  }

  private dotUnit(): number {
    return (this.monthPanelWidth() - this.monthPanelGap) / 7
  }

  private dotSize(): number {
    return this.dotUnit() * 2 / 3
  }

  private cellRows(cells: StatisticYearHeatCell[]): StatisticYearHeatCell[][] {
    const rows: StatisticYearHeatCell[][] = []

    for (let rowIndex = 0; rowIndex < 6; rowIndex++) {
      const row: StatisticYearHeatCell[] = []
      for (let columnIndex = 0; columnIndex < 7; columnIndex++) {
        row.push(cells[rowIndex * 7 + columnIndex])
      }
      rows.push(row)
    }

    return rows
  }

  private monthStartOffset(month: number): number {
    const firstDay = new Date(this.year, month - 1, 1).getDay()
    return (firstDay + 6) % 7
  }

  private dayMetricValue(value: StatisticYearHeatDayValue): number {
    if (this.selectedMetric === 'income') {
      return value.income
    }
    if (this.selectedMetric === 'balance') {
      return Math.abs(value.balance)
    }
    return value.expense
  }

  private maxMetricValue(monthValues: StatisticYearHeatDayValue[][]): number {
    let maxValue = 0

    for (let monthIndex = 0; monthIndex < monthValues.length; monthIndex++) {
      for (let dayIndex = 0; dayIndex < monthValues[monthIndex].length; dayIndex++) {
        const value = this.dayMetricValue(monthValues[monthIndex][dayIndex])
        if (value > maxValue) {
          maxValue = value
        }
      }
    }

    return maxValue
  }

  private metricLevel(value: number, maxValue: number): number {
    if (!(value > 0) || !(maxValue > 0)) {
      return 0
    }

    const ratio = value / maxValue
    if (ratio >= 0.75) {
      return 4
    }
    if (ratio >= 0.5) {
      return 3
    }
    if (ratio >= 0.25) {
      return 2
    }
    return 1
  }

  private dotColor(cell: StatisticYearHeatCell): string {
    if (!cell.visible) {
      return '#00000000'
    }
    if (cell.level <= 0) {
      return '#ECEDEF'
    }

    if (this.selectedMetric === 'income') {
      return this.incomeColor(cell.level)
    }
    if (this.selectedMetric === 'balance') {
      return this.balanceColor(cell.level)
    }
    return this.expenseColor(cell.level)
  }

  private expenseColor(level: number): string {
    if (level === 4) {
      return '#FF5A5F'
    }
    if (level === 3) {
      return '#FF8F90'
    }
    if (level === 2) {
      return '#F8B7B8'
    }
    return '#FADBDD'
  }

  private incomeColor(level: number): string {
    if (level === 4) {
      return '#56BFAF'
    }
    if (level === 3) {
      return '#83D3C7'
    }
    if (level === 2) {
      return '#B2E6DD'
    }
    return '#DAF3EE'
  }

  private balanceColor(level: number): string {
    if (level === 4) {
      return '#1AA8A9'
    }
    if (level === 3) {
      return '#57C4C2'
    }
    if (level === 2) {
      return '#92DDD9'
    }
    return '#CBEFEC'
  }

  private billDateParts(billDate: string): StatisticYearHeatDateParts | undefined {
    const date = new Date(billDate)
    if (date.getTime() !== date.getTime()) {
      return undefined
    }

    const parts: StatisticYearHeatDateParts = {
      year: date.getFullYear(),
      month: date.getMonth() + 1,
      day: date.getDate()
    }
    return parts
  }
}
