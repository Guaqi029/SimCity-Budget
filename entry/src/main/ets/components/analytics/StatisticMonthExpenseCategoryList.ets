import { BillRecord } from '../../model/BillRecord'
import { BillRecordStore } from '../../storage/BillRecordStore'
import { iconResourceById } from '../icon/IconLibraryConfig'

interface StatisticMonthExpenseCategoryItem {
  id: string
  name: string
  iconId: string
  amount: number
  percent: number
  billCount: number
  color: string
}

interface StatisticMonthExpenseCategoryEntry {
  id: string
  name: string
  iconId: string
  amount: number
  billCount: number
}

interface StatisticMonthExpenseDateParts {
  year: number
  month: number
}

const MONTH_EXPENSE_CATEGORY_COLORS: string[] = [
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
export struct StatisticMonthExpenseCategoryList {
  @Watch('onPeriodChanged') @Prop year: number = new Date().getFullYear()
  @Watch('onPeriodChanged') @Prop month: number = new Date().getMonth() + 1
  @Watch('onBillRefreshChanged') @Prop billRefreshVersion: number = 0

  @State private items: StatisticMonthExpenseCategoryItem[] = []
  @State private totalExpense: number = 0

  aboutToAppear(): void {
    this.loadItems()
  }

  build() {
    Column({ space: 0 }) {
      this.headerRow()

      if (this.items.length > 0) {
        Column() {
          ForEach(this.items, (item: StatisticMonthExpenseCategoryItem, index: number) => {
            this.categoryRow(item, index)
          }, (item: StatisticMonthExpenseCategoryItem) => item.id)
        }
        .width('100%')
      } else {
        this.emptyState()
      }
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 10 })
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private headerRow() {
    Row() {
      Text('支出数据')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#18233A')

      Blank()

      Text('当月账单>')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#56BFAF')
    }
    .width('100%')
    .margin({ bottom: 12 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private categoryRow(item: StatisticMonthExpenseCategoryItem, index: number) {
    Column({ space: 14 }) {
      Row() {
        Row({ space: 12 }) {
          Stack({ alignContent: Alignment.Center }) {
            Column()
              .width(46)
              .height(46)
              .borderRadius(23)
              .backgroundColor('#F8FAFD')

            Image(iconResourceById(item.iconId))
              .width(24)
              .height(24)
          }
          .width(46)
          .height(46)

          Column({ space: 8 }) {
            Row({ space: 8 }) {
              Text(item.name)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#18233A')

              Text(item.billCount.toString() + '笔')
                .fontSize(14)
                .fontColor('#8A94A6')

              Text(this.percentText(item.percent))
                .fontSize(14)
                .fontColor('#8A94A6')
            }
            .alignItems(VerticalAlign.Center)

            this.progressBar(item)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)

        Column({ space: 8 }) {
          Text('-' + this.formatMoney(item.amount))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF6368')

          Text(this.amountShareText(item))
            .fontSize(13)
            .fontColor('#FF7A7E')
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      if (index < this.items.length - 1) {
        Column()
          .width('100%')
          .height(1)
          .backgroundColor('#EBEEF4')
      }
    }
    .width('100%')
    .padding({ top: 14, bottom: 14 })
  }

  @Builder
  private progressBar(item: StatisticMonthExpenseCategoryItem) {
    Row() {
      Column()
        .width(this.progressWidth(item.percent))
        .height(8)
        .borderRadius(4)
        .backgroundColor(item.color)

      Blank()
    }
    .width('100%')
    .height(8)
    .backgroundColor('#F2F5FA')
    .borderRadius(4)
  }

  @Builder
  private emptyState() {
    Column({ space: 10 }) {
      Text('当月暂无支出分类数据')
        .fontSize(15)
        .fontColor('#8A94A6')

      Text('记录支出后，这里会自动按分类占比从高到低展示。')
        .fontSize(13)
        .fontColor('#A5AFBF')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding({ top: 34, bottom: 38 })
    .alignItems(HorizontalAlign.Center)
  }

  private onPeriodChanged(): void {
    this.loadItems()
  }

  private onBillRefreshChanged(): void {
    this.loadItems()
  }

  private loadItems(): void {
    BillRecordStore.load(getContext(this))
      .then((records: BillRecord[]) => {
        this.items = this.buildItems(records)
        this.totalExpense = this.sumAmount(this.items)
      })
      .catch(() => {
        this.items = []
        this.totalExpense = 0
      })
  }

  private buildItems(records: BillRecord[]): StatisticMonthExpenseCategoryItem[] {
    const entries: StatisticMonthExpenseCategoryEntry[] = []

    for (let index = 0; index < records.length; index++) {
      const record = records[index]
      const parts = this.billDateParts(record.billDate)
      if (record.isDeleted || parts === undefined) {
        continue
      }
      if (parts.year !== this.year || parts.month !== this.month) {
        continue
      }
      if (record.type !== 'expense') {
        continue
      }

      const categoryId = record.categoryId.length > 0 ? record.categoryId : 'expense_other'
      const categoryName = record.category.name.length > 0 ? record.category.name : record.categoryName
      const iconId = record.category.iconId.length > 0 ? record.category.iconId : 'icon_other'
      const entryIndex = this.findEntryIndex(entries, categoryId)

      if (entryIndex >= 0) {
        entries[entryIndex].amount += record.amount
        entries[entryIndex].billCount += 1
      } else {
        const entry: StatisticMonthExpenseCategoryEntry = {
          id: categoryId,
          name: categoryName,
          iconId: iconId,
          amount: record.amount,
          billCount: 1
        }
        entries.push(entry)
      }
    }

    if (entries.length === 0) {
      return []
    }

    entries.sort((left: StatisticMonthExpenseCategoryEntry, right: StatisticMonthExpenseCategoryEntry) => {
      return right.amount - left.amount
    })

    const totalAmount = this.sumEntryAmount(entries)
    const items: StatisticMonthExpenseCategoryItem[] = []

    for (let index = 0; index < entries.length; index++) {
      const item: StatisticMonthExpenseCategoryItem = {
        id: entries[index].id,
        name: entries[index].name,
        iconId: entries[index].iconId,
        amount: entries[index].amount,
        percent: totalAmount > 0 ? entries[index].amount / totalAmount : 0,
        billCount: entries[index].billCount,
        color: MONTH_EXPENSE_CATEGORY_COLORS[index % MONTH_EXPENSE_CATEGORY_COLORS.length]
      }
      items.push(item)
    }

    return items
  }

  private findEntryIndex(entries: StatisticMonthExpenseCategoryEntry[], id: string): number {
    for (let index = 0; index < entries.length; index++) {
      if (entries[index].id === id) {
        return index
      }
    }
    return -1
  }

  private sumEntryAmount(entries: StatisticMonthExpenseCategoryEntry[]): number {
    let total = 0
    for (let index = 0; index < entries.length; index++) {
      total += entries[index].amount
    }
    return total
  }

  private sumAmount(items: StatisticMonthExpenseCategoryItem[]): number {
    let total = 0
    for (let index = 0; index < items.length; index++) {
      total += items[index].amount
    }
    return total
  }

  private percentText(value: number): string {
    return (value * 100).toFixed(2) + '%'
  }

  private amountShareText(item: StatisticMonthExpenseCategoryItem): string {
    if (!(this.totalExpense > 0)) {
      return ''
    }
    return '占比 ' + this.percentText(item.percent)
  }

  private progressWidth(percent: number): string {
    const width = percent * 100
    if (width < 10) {
      return '10%'
    }
    if (width > 100) {
      return '100%'
    }
    return width.toFixed(2) + '%'
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

  private billDateParts(billDate: string): StatisticMonthExpenseDateParts | undefined {
    const date = new Date(billDate)
    if (date.getTime() !== date.getTime()) {
      return undefined
    }
    const dateParts: StatisticMonthExpenseDateParts = {
      year: date.getFullYear(),
      month: date.getMonth() + 1
    }
    return dateParts
  }
}
