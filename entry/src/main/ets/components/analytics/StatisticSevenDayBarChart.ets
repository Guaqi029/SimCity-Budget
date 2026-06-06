import { BillRecord } from '../../model/BillRecord'
import { BillRecordStore } from '../../storage/BillRecordStore'

interface SevenDayStatisticItem {
  id: string
  label: string
  expense: number
  income: number
}

@Component
export struct StatisticSevenDayBarChart {
  @State private items: SevenDayStatisticItem[] = []
  @State private totalExpense: number = 0
  @State private totalIncome: number = 0
  @State private averageExpense: number = 0
  @State private averageIncome: number = 0
  @State private selectedMetric: 'expense' | 'income' = 'expense'

  aboutToAppear() {
    this.loadChartData()
  }

  build() {
    Column({ space: 18 }) {
      this.headerRow()
      this.chartArea()
      this.summaryArea()
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 18, bottom: 18 })
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private headerRow() {
    Row() {
      Text('近7日统计 ⇄')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#18233A')

      Blank()

      Row({ space: 0 }) {
        Text('支出')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.selectedMetric === 'expense' ? '#FFFFFF' : '#56BFAF')
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor(this.selectedMetric === 'expense' ? '#56BFAF' : '#F8FFFD')
          .border({
            width: {
              left: 1,
              top: 1,
              right: 0.5,
              bottom: 1
            },
            color: '#56BFAF'
          })
          .borderRadius({ topLeft: 12, bottomLeft: 12, topRight: 0, bottomRight: 0 })
          .onClick(() => {
            this.selectedMetric = 'expense'
          })

        Text('收入')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.selectedMetric === 'income' ? '#FFFFFF' : '#56BFAF')
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor(this.selectedMetric === 'income' ? '#56BFAF' : '#F8FFFD')
          .border({
            width: {
              left: 0.5,
              top: 1,
              right: 1,
              bottom: 1
            },
            color: '#56BFAF'
          })
          .borderRadius({ topLeft: 0, bottomLeft: 0, topRight: 12, bottomRight: 12 })
          .onClick(() => {
            this.selectedMetric = 'income'
          })
      }
    }
    .width('100%')
  }

  @Builder
  private chartArea() {
    Column({ space: 12 }) {
      Row() {
        ForEach(this.items, (item: SevenDayStatisticItem) => {
          this.chartBar(item)
        }, (item: SevenDayStatisticItem) => item.id)
      }
      .width('100%')
      .height(210)
      .alignItems(VerticalAlign.Bottom)
      .justifyContent(FlexAlign.SpaceBetween)

      Column()
        .width('100%')
        .height(1)
        .backgroundColor('#D9DEE8')
    }
    .width('100%')
  }

  @Builder
  private chartBar(item: SevenDayStatisticItem) {
    Column({ space: 8 }) {
      Text(this.barValueText(item))
        .fontSize(12)
        .fontColor('#20293A')
        .textAlign(TextAlign.Center)
        .opacity(this.barValue(item) > 0 ? 1 : 0)

      Column()
        .width(35)
        .height(this.barHeight(item))
        .backgroundColor(this.selectedMetric === 'expense' ? '#FF575D' : '#56BFAF')
        .borderRadius({ topLeft: 4, topRight: 4, bottomLeft: 4, bottomRight: 4 })

      Text(item.label)
        .fontSize(13)
        .fontColor('#4F596B')
        .textAlign(TextAlign.Center)
        .width(40)
    }
    .justifyContent(FlexAlign.End)
    .alignItems(HorizontalAlign.Center)
    .height('100%')
  }

  @Builder
  private summaryArea() {
    Row() {
      Column({ space: 12 }) {
        Text('总支出：' + this.formatMoney(this.totalExpense))
          .fontSize(16)
          .fontColor('#18233A')

        Text('总收入：' + this.formatMoney(this.totalIncome))
          .fontSize(16)
          .fontColor('#18233A')
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Column({ space: 12 }) {
        Text('日均支出：' + this.formatMoney(this.averageExpense))
          .fontSize(16)
          .fontColor('#18233A')

        Text('日均收入：' + this.formatMoney(this.averageIncome))
          .fontSize(16)
          .fontColor('#18233A')
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
    .padding({ left: 4, right: 4 })
  }

  // 原因：这样组件初始化时只做一件事，后续如果你要支持刷新、切换统计范围，也可以继续复用这条聚合链路。
  private loadChartData() {
    BillRecordStore.load(getContext(this))
      .then((records: BillRecord[]) => {
        const nextItems = this.createSevenDayItems(records)
        this.items = nextItems
        this.totalExpense = this.sumMetric(nextItems, 'expense')
        this.totalIncome = this.sumMetric(nextItems, 'income')
        this.averageExpense = this.totalExpense / 7
        this.averageIncome = this.totalIncome / 7
      })
      .catch(() => {
        this.items = this.createSevenDayItems([])
        this.totalExpense = 0
        this.totalIncome = 0
        this.averageExpense = 0
        this.averageIncome = 0
      })
  }

  // 原因：组件显示的是“按天汇总后的收入/支出”，不能直接拿原始账单列表渲染，所以需要先统一做一次日期桶聚合。
  private createSevenDayItems(records: BillRecord[]): SevenDayStatisticItem[] {
    const items: SevenDayStatisticItem[] = []

    for (let offset = 6; offset >= 0; offset--) {
      const date = new Date()
      date.setHours(0, 0, 0, 0)
      date.setDate(date.getDate() - offset)
      const key = this.dateKey(date)

      const item: SevenDayStatisticItem = {
        id: key,
        label: offset === 0 ? '今天' : this.weekLabel(date),
        expense: 0,
        income: 0
      }

      for (let index = 0; index < records.length; index++) {
        const record = records[index]
        if (record.isDeleted) {
          continue
        }
        const recordDate = new Date(record.billDate)
        if (this.dateKey(recordDate) !== key) {
          continue
        }
        if (record.type === 'expense') {
          item.expense += record.amount
        } else if (record.type === 'income') {
          item.income += record.amount
        }
      }

      items.push(item)
    }

    return items
  }

  private sumMetric(items: SevenDayStatisticItem[], metric: 'expense' | 'income'): number {
    let total = 0
    for (let index = 0; index < items.length; index++) {
      total += metric === 'expense' ? items[index].expense : items[index].income
    }
    return total
  }

  private barValue(item: SevenDayStatisticItem): number {
    return this.selectedMetric === 'expense' ? item.expense : item.income
  }

  private barValueText(item: SevenDayStatisticItem): string {
    const value = this.barValue(item)
    if (value <= 0) {
      return ''
    }
    return this.trimTrailingZero(value)
  }

  private barHeight(item: SevenDayStatisticItem): number {
    const value = this.barValue(item)
    const maxValue = this.maxBarValue()
    if (value <= 0 || maxValue <= 0) {
      return 8
    }
    const height = value / maxValue * 120
    return height < 8 ? 8 : height
  }

  private maxBarValue(): number {
    let maxValue = 0
    for (let index = 0; index < this.items.length; index++) {
      const value = this.selectedMetric === 'expense' ? this.items[index].expense : this.items[index].income
      if (value > maxValue) {
        maxValue = value
      }
    }
    return maxValue
  }

  private formatMoney(value: number): string {
    return this.trimTrailingZero(Number(value.toFixed(2)))
  }

  private trimTrailingZero(value: number): string {
    const fixed = value.toFixed(2)
    if (fixed.endsWith('00')) {
      return value.toFixed(0)
    }
    if (fixed.endsWith('0')) {
      return value.toFixed(1)
    }
    return fixed
  }

  private weekLabel(date: Date): string {
    const labels: string[] = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
    return labels[date.getDay()]
  }

  private dateKey(date: Date): string {
    return date.getFullYear().toString() + '-' + this.pad2(date.getMonth() + 1) + '-' + this.pad2(date.getDate())
  }

  private pad2(value: number): string {
    return value < 10 ? '0' + value.toString() : value.toString()
  }
}
