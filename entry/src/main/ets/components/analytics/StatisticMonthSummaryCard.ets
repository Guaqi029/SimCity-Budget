import { BillRecord } from '../../model/BillRecord'
import { BillRecordStore } from '../../storage/BillRecordStore'

interface StatisticMonthMetricItem {
  label: string
  value: number
}

interface StatisticMonthSummaryData {
  monthExpense: number
  monthIncome: number
  monthBalance: number
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

function createEmptyMonthSummaryData(): StatisticMonthSummaryData {
  return {
    monthExpense: 0,
    monthIncome: 0,
    monthBalance: 0,
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
export struct StatisticMonthSummaryCard {
  @Watch('onPeriodChanged') @Prop year: number = new Date().getFullYear()
  @Watch('onPeriodChanged') @Prop month: number = new Date().getMonth() + 1
  @Watch('onBillRefreshChanged') @Prop billRefreshVersion: number = 0

  @State private expanded: boolean = false
  @State private summary: StatisticMonthSummaryData = createEmptyMonthSummaryData()

  aboutToAppear(): void {
    this.loadSummary()
  }

  build() {
    // 新增：用独立绿色卡片承载月汇总数据，并根据 expanded 状态控制显示行数。
    // 原因：这块后续会成为月统计页的核心总览区，单独做成组件后，样式和数据都能高内聚管理。
    Column({ space: this.expanded ? 28 : 18 }) {
      // 替换：顶部第一行不再走 ForEach 渲染，而是改成 3 个显式单元格。
      // 删除原因：前面已经验证过，首行在异步加载本地账单后存在节点复用导致的不刷新问题，
      // 继续让它走通用列表渲染不够稳，所以这里直接拆成固定的 3 个单元格，彻底绕开复用干扰。
      // 新增功能：月支出、月收入、月结余会直接绑定当前 summary 状态，账单统计值变化后首行能稳定刷新。
      this.topMetricRow()

      if (this.expanded) {
        this.metricRow(this.averageMetrics())
        this.metricRow(this.transferMetrics())
        this.metricRow(this.adjustmentMetrics())
      }

      // 新增：底部只保留一个统一的折叠/展开入口。
      // 原因：折叠后只展示第一行，所以用户需要一个稳定且低干扰的控制点来展开更多明细。
      // 新增功能：点击底部箭头即可在“仅显示第一行”和“显示完整月汇总”之间切换。
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
  private metricRow(items: StatisticMonthMetricItem[]) {
    Row() {
      ForEach(items, (item: StatisticMonthMetricItem) => {
        this.metricCell(item)
      // 替换：这里不再只用固定 label 作为 ForEach key，而是改成“label + 当前值”的组合 key。
      // 删除原因：顶部第一行会先以 0.00 渲染出来，后面本地账单异步加载后，如果 key 仍然只是固定 label，
      // ArkUI 可能会直接复用旧节点，导致月支出 / 月收入 / 月结余看起来一直停在初始值不刷新。
      // 新增功能：当统计值变化时，对应格子的 key 也会变化，组件会按最新存储数据重新渲染。
      }, (item: StatisticMonthMetricItem) => item.label + '_' + this.formatMetricValue(item.value))
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  private topMetricRow() {
    // 替换：顶部第一行不再复用通用 metricCell()，而是直接手写 3 个独立单元。
    // 删除原因：前面已经排除了统计公式本身的问题，现在更需要把首行从通用 Builder/参数传递链路里完全拆出来，
    // 这样可以最大限度避免首行被节点复用、Builder 参数缓存或通用单元复用影响。
    // 新增功能：月支出、月收入、月结余现在各自直接绑定 summary 当前值，首行渲染路径最短，也最容易验证是否还存在显示冲突。
    Row() {
      Column({ space: 10 }) {
        Text('月支出')
          .fontSize(14)
          .fontColor('#F4FFFD')
          .fontWeight(FontWeight.Regular)
          .textAlign(TextAlign.Center)

        Text(this.formatMetricValue(this.summary.monthExpense))
          .fontSize(19)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
      }
      .width('31%')
      .alignItems(HorizontalAlign.Center)

      Column({ space: 10 }) {
        Text('月收入')
          .fontSize(14)
          .fontColor('#F4FFFD')
          .fontWeight(FontWeight.Regular)
          .textAlign(TextAlign.Center)

        Text(this.formatMetricValue(this.summary.monthIncome))
          .fontSize(19)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
      }
      .width('31%')
      .alignItems(HorizontalAlign.Center)

      Column({ space: 10 }) {
        Text('月结余')
          .fontSize(14)
          .fontColor('#F4FFFD')
          .fontWeight(FontWeight.Regular)
          .textAlign(TextAlign.Center)

        Text(this.formatMetricValue(this.summary.monthBalance))
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
  private metricCell(item: StatisticMonthMetricItem) {
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

  private onPeriodChanged(): void {
    this.loadSummary()
  }

  private onBillRefreshChanged(): void {
    this.loadSummary()
  }

  // 新增：从本地账单仓储读取当前月份数据并完成聚合。
  // 原因：这张卡不再是纯样式占位，必须真的响应本地账单数据变化；
  // 所以这里直接复用 BillRecordStore，按当前选中年月过滤，再生成月汇总结果。
  private loadSummary(): void {
    BillRecordStore.load(getContext(this))
      .then((records: BillRecord[]) => {
        this.summary = this.buildSummary(records)
      })
      .catch(() => {
        this.summary = createEmptyMonthSummaryData()
      })
  }

  private buildSummary(records: BillRecord[]): StatisticMonthSummaryData {
    let monthExpense = 0
    let monthIncome = 0
    let transferAmount = 0
    let repayAmount = 0
    let topUpAmount = 0
    let transferFeeAmount = 0
    let reimburseIncomeAmount = 0
    let refundIncomeAmount = 0

    for (let index = 0; index < records.length; index++) {
      const record = records[index]
      // 替换：这里不再依赖 record.month 这个冗余字段判断“是否属于当前月”，而是直接按账单真实日期 billDate 计算。
      // 删除原因：month 字段本质上是冗余缓存，一旦历史数据或编辑逻辑里没有同步更新，就会出现“明明是本月账单，却没被算进月支出/月收入”的错位。
      // 新增功能：月支出和月收入现在严格按 billDate 落在当前选中年月内的所有账单逐条累加，月结余固定等于 月收入 - 月支出。
      if (record.isDeleted || !this.isInSelectedMonth(record.billDate)) {
        continue
      }

      if (record.type === 'expense') {
        monthExpense += record.amount
      } else if (record.type === 'income') {
        monthIncome += record.amount
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

      // 替换：这里不再继续统计“报销到账 / 待报销 / 退款支出 / 优惠”等当前模型里没有真实来源的占位项，
      // 而是只保留本地账单里能够直接识别出来的收入类报销和退款数据。
      // 删除原因：这些字段之前虽然能显示为 0，但本质上是初始化占位，不是基于存储数据计算出来的真实统计。
      // 新增功能：月汇总卡现在只展示真正能从 BillRecordStore 里聚合出来的统计项。
      if (record.type === 'income' && record.categoryId === 'income_reimburse') {
        reimburseIncomeAmount += record.amount
      }

      if (record.type === 'income' && record.categoryId === 'income_refund') {
        refundIncomeAmount += record.amount
      }
    }

    const daysInMonth = new Date(this.year, this.month, 0).getDate()
    const monthBalance = monthIncome - monthExpense
    const summary: StatisticMonthSummaryData = {
      monthExpense: monthExpense,
      monthIncome: monthIncome,
      monthBalance: monthBalance,
      averageExpense: daysInMonth > 0 ? monthExpense / daysInMonth : 0,
      averageIncome: daysInMonth > 0 ? monthIncome / daysInMonth : 0,
      averageBalance: daysInMonth > 0 ? monthBalance / daysInMonth : 0,
      transferAmount: transferAmount,
      repayAmount: repayAmount,
      topUpAmount: topUpAmount,
      transferFeeAmount: transferFeeAmount,
      reimburseIncomeAmount: reimburseIncomeAmount,
      refundIncomeAmount: refundIncomeAmount
    }
    return summary
  }

  private averageMetrics(): StatisticMonthMetricItem[] {
    const items: StatisticMonthMetricItem[] = []
    const expenseItem: StatisticMonthMetricItem = { label: '日均支出', value: this.summary.averageExpense }
    const incomeItem: StatisticMonthMetricItem = { label: '日均收入', value: this.summary.averageIncome }
    const balanceItem: StatisticMonthMetricItem = { label: '日均结余', value: this.summary.averageBalance }
    items.push(expenseItem)
    items.push(incomeItem)
    items.push(balanceItem)
    return items
  }

  private transferMetrics(): StatisticMonthMetricItem[] {
    const items: StatisticMonthMetricItem[] = []
    const transferItem: StatisticMonthMetricItem = { label: '转账', value: this.summary.transferAmount }
    const repayItem: StatisticMonthMetricItem = { label: '还款', value: this.summary.repayAmount }
    const topUpItem: StatisticMonthMetricItem = { label: '充值', value: this.summary.topUpAmount }
    items.push(transferItem)
    items.push(repayItem)
    items.push(topUpItem)
    return items
  }

  // 替换：这里把几组当前没有真实存储来源的占位统计行，合并成一组完全基于本地账单可计算的“调整项”统计。
  // 删除原因：原来的“应付/借入、应收/借出、待报销、退款支出、优惠”等字段目前没有对应数据模型支撑，继续展示只会产生初始化占位内容。
  // 新增功能：现在展开区只保留“报销收入、退款收入、手续费”这三项，都能直接从本地账单中聚合得到。
  private adjustmentMetrics(): StatisticMonthMetricItem[] {
    const items: StatisticMonthMetricItem[] = []
    const reimburseItem: StatisticMonthMetricItem = { label: '报销收入', value: this.summary.reimburseIncomeAmount }
    const refundItem: StatisticMonthMetricItem = { label: '退款收入', value: this.summary.refundIncomeAmount }
    const feeItem: StatisticMonthMetricItem = { label: '手续费', value: this.summary.transferFeeAmount }
    items.push(reimburseItem)
    items.push(refundItem)
    items.push(feeItem)
    return items
  }

  private isInSelectedMonth(billDate: string): boolean {
    const date = new Date(billDate)
    if (date.getTime() !== date.getTime()) {
      return false
    }
    return date.getFullYear() === this.year && date.getMonth() + 1 === this.month
  }

  private formatMetricValue(value: number): string {
    const rounded = Math.round(value * 100) / 100
    if (Math.abs(rounded) < 0.005) {
      return '0.00'
    }
    return rounded.toFixed(2)
  }
}
