import { MonthlyBudget } from '../../model/Budget'
import { BillRecord } from '../../model/BillRecord'
import { BudgetStore } from '../../storage/BudgetStore'
import { BillRecordStore } from '../../storage/BillRecordStore'

@Component
export struct StatisticBudgetRatioCard {
  @Watch('onBillRefreshChanged') @Prop billRefreshVersion: number = 0

  @State private monthBudget: MonthlyBudget = this.emptyBudget()
  @State private budgetUsed: number = 0

  aboutToAppear(): void {
    this.loadBudgetData()
  }

  build() {
    Column({ space: 18 }) {
      this.headerRow()
      this.chartArea()
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
        Text('预算占比')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#18233A')

        Text('⌄')
          .fontSize(18)
          .fontColor('#6B7A99')
      }
      .alignItems(VerticalAlign.Center)

      Blank()

      Text('查看详情>')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#56BFAF')
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private chartArea() {
    Column({ space: 12 }) {
      Stack({ alignContent: Alignment.Center }) {
        DataPanel({
          values: this.panelValues(),
          max: 0,
          type: DataPanelType.Circle
        })
          .width(240)
          .height(240)
          .closeEffect(true)
          .valueColors(this.panelColors())
          .trackBackgroundColor('#F1F3F7')
          .strokeWidth(30)

        if (this.hasBudget()) {
          Column({ space: 6 }) {
            Text(this.usedPercentText())
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.isOverBudget() ? '#E07178' : '#18233A')

            Text('本月已用')
              .fontSize(14)
              .fontColor('#7B879A')

            Text(this.centerDetailText())
              .fontSize(13)
              .fontColor('#98A3B8')
          }
          .alignItems(HorizontalAlign.Center)
        }
      }
      .width('100%')
      .margin({ top: 8, bottom: 8 })

      if (this.hasBudget()) {
        Row() {
          this.summaryBlock('总预算', this.formatMoney(this.monthBudget.totalBudget), '#56BFAF')
          this.summaryBlock('已使用', this.formatMoney(this.budgetUsed), '#FF6368')
          this.summaryBlock('剩余', this.remainingText(), this.isOverBudget() ? '#E07178' : '#18233A')
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
      } else {
        Column({ space: 8 }) {
          Text('当月还没有设置预算')
            .fontSize(15)
            .fontColor('#8A94A6')

          Text('设置总预算后，这里会自动按本月已用和剩余金额展示预算占比。')
            .fontSize(13)
            .fontColor('#A5AFBF')
            .textAlign(TextAlign.Center)
            .lineHeight(20)
        }
        .width('100%')
        .padding({ top: 8, bottom: 6 })
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private summaryBlock(label: string, value: string, color: string) {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(13)
        .fontColor('#8A94A6')

      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
        .maxLines(1)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  private onBillRefreshChanged(): void {
    this.loadBudgetData()
  }

  private loadBudgetData(): void {
    const month = this.currentMonthKey()
    BillRecordStore.load(getContext(this))
      .then((records: BillRecord[]) => {
        return BudgetStore.load(getContext(this))
          .then((budgets: MonthlyBudget[]) => {
            this.monthBudget = BudgetStore.findByMonth(budgets, month)
            this.budgetUsed = this.budgetUsedFromRecords(records, month)
          })
      })
      .catch(() => {
        this.monthBudget = this.emptyBudget()
        this.budgetUsed = 0
      })
  }

  private budgetUsedFromRecords(records: BillRecord[], month: string): number {
    let total = 0
    for (let index = 0; index < records.length; index++) {
      const record = records[index]
      if (!record.isDeleted &&
        record.type === 'expense' &&
        record.includeInBudget !== false &&
        this.recordMonth(record) === month) {
        total += record.amount
      }
    }
    return this.roundMoney(total)
  }

  private panelValues(): number[] {
    if (!this.hasBudget()) {
      return [1]
    }

    const totalBudget = this.monthBudget.totalBudget
    const used = this.budgetUsed > totalBudget ? totalBudget : this.budgetUsed
    const remaining = totalBudget - used
    return [used, remaining > 0 ? remaining : 0]
  }

  private panelColors(): string[] {
    if (!this.hasBudget()) {
      return ['#EAEAEA']
    }
    if (this.isOverBudget()) {
      return ['#FF8A8F', '#F3F4F7']
    }
    return ['#56BFAF', '#E8EEF7']
  }

  private hasBudget(): boolean {
    return this.monthBudget.totalBudget > 0
  }

  private isOverBudget(): boolean {
    return this.hasBudget() && this.budgetUsed > this.monthBudget.totalBudget
  }

  private usedPercentText(): string {
    if (!this.hasBudget()) {
      return '0%'
    }
    const percent = this.budgetUsed / this.monthBudget.totalBudget
    return Math.round(percent * 100).toString() + '%'
  }

  private centerDetailText(): string {
    return this.formatMoney(this.budgetUsed) + ' / ' + this.formatMoney(this.monthBudget.totalBudget)
  }

  private remainingText(): string {
    return this.formatMoney(this.monthBudget.totalBudget - this.budgetUsed)
  }

  private currentMonthKey(): string {
    const now = new Date()
    return now.getFullYear().toString() + '-' + this.pad2(now.getMonth() + 1)
  }

  private recordMonth(record: BillRecord): string {
    if (record.month !== undefined && record.month.length > 0) {
      return record.month
    }
    const date = new Date(record.billDate)
    return date.getFullYear().toString() + '-' + this.pad2(date.getMonth() + 1)
  }

  private emptyBudget(): MonthlyBudget {
    const month = this.currentMonthKey()
    return {
      month: month,
      totalBudget: 0,
      categoryBudgets: [],
      createTime: '',
      updateTime: ''
    }
  }

  private formatMoney(value: number): string {
    return '¥' + this.roundMoney(value).toFixed(2)
  }

  private roundMoney(value: number): number {
    return Math.round(value * 100) / 100
  }

  private pad2(value: number): string {
    return value < 10 ? '0' + value.toString() : value.toString()
  }
}
