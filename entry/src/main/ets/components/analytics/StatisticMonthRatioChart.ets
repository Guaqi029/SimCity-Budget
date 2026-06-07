import { BillRecord } from '../../model/BillRecord'
import { BillRecordStore } from '../../storage/BillRecordStore'
import { iconResourceById } from '../icon/IconLibraryConfig'

interface StatisticMonthRatioSegment {
  id: string
  name: string
  iconId: string
  amount: number
  percent: number
  color: string
}

interface StatisticMonthRatioEntry {
  key: string
  name: string
  iconId: string
  amount: number
}

interface StatisticMonthRatioDateParts {
  year: number
  month: number
}

type StatisticMonthRatioMetricType = 'expense' | 'income'
type StatisticMonthRatioCategoryMode = 'primary' | 'all'

const MONTH_RATIO_COLORS: string[] = [
  '#18AEB7',
  '#F58653',
  '#FFE867',
  '#7FC4FF',
  '#8C8AF4',
  '#6FCD79',
  '#F26C92',
  '#B3BDD0'
]

@Component
export struct StatisticMonthRatioChart {
  @Watch('onPeriodChanged') @Prop year: number = new Date().getFullYear()
  @Watch('onPeriodChanged') @Prop month: number = new Date().getMonth() + 1
  @Watch('onBillRefreshChanged') @Prop billRefreshVersion: number = 0

  @State private selectedMetric: StatisticMonthRatioMetricType = 'expense'
  @State private categoryMode: StatisticMonthRatioCategoryMode = 'all'
  @State private segments: StatisticMonthRatioSegment[] = []
  @State private totalAmount: number = 0
  @State private showAmount: boolean = false

  aboutToAppear(): void {
    this.loadSegments()
  }

  build() {
    Column({ space: 18 }) {
      this.headerRow()
      this.chartArea()
      this.footerToggle()
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
        Text(this.selectedMetric === 'expense' ? '支出占比' : '收入占比')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#18233A')

        Text('⇄')
          .fontSize(18)
          .fontColor('#737D92')
      }
      .alignItems(VerticalAlign.Center)

      Blank()

      Row({ space: 0 }) {
        this.categoryToggleButton('primary', '一级分类')
        this.categoryToggleButton('all', '全部')
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
  private categoryToggleButton(mode: StatisticMonthRatioCategoryMode, label: string) {
    Text(label)
      .fontSize(14)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.categoryMode === mode ? '#FFFFFF' : '#56BFAF')
      .padding({ left: 22, right: 22, top: 10, bottom: 10 })
      .backgroundColor(this.categoryMode === mode ? '#56BFAF' : '#FFFFFF')
      .onClick(() => {
        this.categoryMode = mode
        this.loadSegments()
      })
  }

  @Builder
  private chartArea() {
    if (this.segments.length > 0) {
      Column({ space: 8 }) {
        Stack({ alignContent: Alignment.Center }) {
          DataPanel({
            values: this.panelValues(),
            max: 0,
            type: DataPanelType.Circle
          })
            .width(238)
            .height(238)
            .closeEffect(true)
            .valueColors(this.panelColors())
            .trackBackgroundColor('#EEF3F9')
            .strokeWidth(28)

          Column({ space: 6 }) {
            Text('⇄')
              .fontSize(26)
              .fontColor('#18233A')

            Text(this.selectedMetric === 'expense' ? '切换到收入' : '切换到支出')
              .fontSize(16)
              .fontColor('#18233A')
          }
          .width(138)
          .height(138)
          .backgroundColor('#FFFFFF')
          .borderRadius(69)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            this.toggleMetric()
          })
        }
        .width('100%')
        .margin({ top: 4 })

        if (this.topSegments().length > 0) {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
            ForEach(this.topSegments(), (segment: StatisticMonthRatioSegment) => {
              this.legendItem(segment)
            }, (segment: StatisticMonthRatioSegment) => segment.id + '_legend')
          }
          .width('100%')
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    } else {
      Column({ space: 12 }) {
        Stack({ alignContent: Alignment.Center }) {
          DataPanel({
            values: [1],
            max: 0,
            type: DataPanelType.Circle
          })
            .width(238)
            .height(238)
            .closeEffect(true)
            .valueColors(['#DDE5F0'])
            .trackBackgroundColor('#EEF3F9')
            .strokeWidth(28)

          Column({ space: 6 }) {
            Text('⇄')
              .fontSize(26)
              .fontColor('#18233A')

            Text(this.selectedMetric === 'expense' ? '切换到收入' : '切换到支出')
              .fontSize(16)
              .fontColor('#18233A')
          }
          .width(138)
          .height(138)
          .backgroundColor('#FFFFFF')
          .borderRadius(69)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            this.toggleMetric()
          })
        }

        Text(this.selectedMetric === 'expense' ? '当月暂无支出数据' : '当月暂无收入数据')
          .fontSize(14)
          .fontColor('#8A94A6')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
  }

  @Builder
  private legendItem(segment: StatisticMonthRatioSegment) {
    Row({ space: 10 }) {
      Column()
        .width(8)
        .height(36)
        .borderRadius(4)
        .backgroundColor(segment.color)

      Stack({ alignContent: Alignment.Center }) {
        Column()
          .width(30)
          .height(30)
          .borderRadius(15)
          .backgroundColor('#F8FAFD')
          .border({
            width: 1.5,
            color: segment.color
          })

        Image(iconResourceById(segment.iconId))
          .width(16)
          .height(16)
      }
      .width(30)
      .height(30)

      Column({ space: 3 }) {
        Row({ space: 6 }) {
          Column()
            .width(8)
            .height(8)
            .borderRadius(4)
            .backgroundColor(segment.color)

          Text(segment.name)
            .fontSize(13)
            .fontColor('#18233A')
            .maxLines(1)
        }
        .alignItems(VerticalAlign.Center)

        Text(this.legendDetailText(segment))
          .fontSize(12)
          .fontColor('#6B7A99')
          .maxLines(1)
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('48%')
    .margin({ bottom: 10 })
  }

  @Builder
  private footerToggle() {
    Row() {
      Blank()

      Row({ space: 8 }) {
        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width(22)
            .height(22)
            .borderRadius(5)
            .border({
              width: 1,
              color: '#56BFAF'
            })
            .backgroundColor(this.showAmount ? '#56BFAF' : '#FFFFFF')

          if (this.showAmount) {
            Text('✓')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
        }
        .width(22)
        .height(22)

        Text('显示收支金额')
          .fontSize(14)
          .fontColor('#5C6474')
      }
      .onClick(() => {
        this.showAmount = !this.showAmount
      })
    }
    .width('100%')
  }

  private onPeriodChanged(): void {
    this.loadSegments()
  }

  private onBillRefreshChanged(): void {
    this.loadSegments()
  }

  private toggleMetric(): void {
    this.selectedMetric = this.selectedMetric === 'expense' ? 'income' : 'expense'
    this.loadSegments()
  }

  private loadSegments(): void {
    BillRecordStore.load(getContext(this))
      .then((records: BillRecord[]) => {
        this.segments = this.buildSegments(records)
        this.totalAmount = this.sumAmount(this.segments)
      })
      .catch(() => {
        this.segments = []
        this.totalAmount = 0
      })
  }

  private buildSegments(records: BillRecord[]): StatisticMonthRatioSegment[] {
    const entries: StatisticMonthRatioEntry[] = []

    for (let index = 0; index < records.length; index++) {
      const record = records[index]
      const parts = this.billDateParts(record.billDate)
      if (record.isDeleted || parts === undefined) {
        continue
      }
      if (parts.year !== this.year || parts.month !== this.month) {
        continue
      }
      if (record.type !== this.selectedMetric) {
        continue
      }

      const sourceName = record.category.name.length > 0 ? record.category.name : record.categoryName
      const displayName = this.categoryDisplayName(sourceName)
      const iconId = record.category.iconId.length > 0 ? record.category.iconId : 'icon_other'
      const key = this.categoryMode === 'primary' ? 'primary_' + displayName : record.categoryId
      const entryIndex = this.findEntryIndex(entries, key)

      if (entryIndex >= 0) {
        entries[entryIndex].amount += record.amount
      } else {
        const entry: StatisticMonthRatioEntry = {
          key: key,
          name: displayName,
          iconId: iconId,
          amount: record.amount
        }
        entries.push(entry)
      }
    }

    if (entries.length === 0) {
      return []
    }

    entries.sort((left: StatisticMonthRatioEntry, right: StatisticMonthRatioEntry) => right.amount - left.amount)
    const totalAmount = this.sumEntryAmount(entries)
    const segments: StatisticMonthRatioSegment[] = []

    for (let index = 0; index < entries.length; index++) {
      const segment: StatisticMonthRatioSegment = {
        id: entries[index].key,
        name: entries[index].name,
        iconId: entries[index].iconId,
        amount: entries[index].amount,
        percent: totalAmount > 0 ? entries[index].amount / totalAmount : 0,
        color: MONTH_RATIO_COLORS[index % MONTH_RATIO_COLORS.length]
      }
      segments.push(segment)
    }

    return this.limitSegments(segments)
  }

  private limitSegments(segments: StatisticMonthRatioSegment[]): StatisticMonthRatioSegment[] {
    if (segments.length <= 6) {
      return segments
    }

    const visible: StatisticMonthRatioSegment[] = segments.slice(0, 5)
    let otherAmount = 0

    for (let index = 5; index < segments.length; index++) {
      otherAmount += segments[index].amount
    }

    const totalAmount = this.sumAmount(segments)
    const otherSegment: StatisticMonthRatioSegment = {
      id: 'other_segment',
      name: '其他',
      iconId: 'icon_other',
      amount: otherAmount,
      percent: totalAmount > 0 ? otherAmount / totalAmount : 0,
      color: MONTH_RATIO_COLORS[5]
    }
    visible.push(otherSegment)
    return visible
  }

  private topSegments(): StatisticMonthRatioSegment[] {
    if (this.segments.length <= 4) {
      return this.segments
    }
    return this.segments.slice(0, 4)
  }

  private panelValues(): number[] {
    const values: number[] = []
    for (let index = 0; index < this.segments.length; index++) {
      values.push(this.segments[index].amount)
    }
    return values
  }

  private panelColors(): string[] {
    const colors: string[] = []
    for (let index = 0; index < this.segments.length; index++) {
      colors.push(this.segments[index].color)
    }
    return colors
  }

  private legendDetailText(segment: StatisticMonthRatioSegment): string {
    if (this.showAmount) {
      return this.formatMoney(segment.amount) + ' · ' + this.percentText(segment.percent)
    }
    return this.percentText(segment.percent)
  }

  private percentText(value: number): string {
    return (value * 100).toFixed(2) + '%'
  }

  private formatMoney(value: number): string {
    const fixed = value.toFixed(2)
    if (fixed.endsWith('00')) {
      return value.toFixed(0)
    }
    if (fixed.endsWith('0')) {
      return value.toFixed(1)
    }
    return fixed
  }

  private categoryDisplayName(sourceName: string): string {
    if (this.categoryMode === 'all') {
      return sourceName
    }

    const slashIndex = sourceName.indexOf('/')
    if (slashIndex > 0) {
      return sourceName.substring(0, slashIndex)
    }

    const arrowIndex = sourceName.indexOf('>')
    if (arrowIndex > 0) {
      return sourceName.substring(0, arrowIndex)
    }

    return sourceName
  }

  private findEntryIndex(entries: StatisticMonthRatioEntry[], key: string): number {
    for (let index = 0; index < entries.length; index++) {
      if (entries[index].key === key) {
        return index
      }
    }
    return -1
  }

  private sumEntryAmount(entries: StatisticMonthRatioEntry[]): number {
    let total = 0
    for (let index = 0; index < entries.length; index++) {
      total += entries[index].amount
    }
    return total
  }

  private sumAmount(segments: StatisticMonthRatioSegment[]): number {
    let total = 0
    for (let index = 0; index < segments.length; index++) {
      total += segments[index].amount
    }
    return total
  }

  private billDateParts(billDate: string): StatisticMonthRatioDateParts | undefined {
    const date = new Date(billDate)
    if (date.getTime() !== date.getTime()) {
      return undefined
    }
    const dateParts: StatisticMonthRatioDateParts = {
      year: date.getFullYear(),
      month: date.getMonth() + 1
    }
    return dateParts
  }
}
