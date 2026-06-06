import { PageHeader } from '../components/PageHeader'
import { BillDatePicker, BillDatePickerValue } from '../components/bill/BillDatePicker'
import { BillRecordTimeline } from '../components/bill/BillRecordTimeline'
import { BillRecord } from '../model/BillRecord'
import { BillRecordStore } from '../storage/BillRecordStore'

@Component
export struct BillListPage {
  // 新增：沿用首页已经在使用的刷新版本号机制。
  // 原因：新增账单 / 删除账单后，Index 层已经会递增 billRefreshVersion，
  // 所以账单明细页直接复用这个信号，就能在最小改动下感知本地存储数据变化。
  @Watch('onBillRefreshChanged') @Prop billRefreshVersion: number = 0

  // 新增：账单明细页自己维护当前选中的年月日，
  // 因为顶部筛选 chip 已被替换为可交互日历，需要有页面级状态接收日历回调。
  @State private selectedYear: number = 2026
  @State private selectedMonth: number = 4
  @State private selectedDay: number = 28
  // 这里把原来的“本地演示 records 常量”替换成了页面状态 billRecords。
  // 删除原因：你现在要求直接读取真实本地存储，继续保留演示数组会让页面和真实数据脱节。
  // 新增功能：账单页会像首页一样，从 BillRecordStore.load() 读取真实账单列表。
  @State private billRecords: BillRecord[] = []
  onOpenDetail: () => void = () => {}

  aboutToAppear() {
    this.loadBills()
  }

  build() {
    Column({ space: 16 }) {
      PageHeader({
        eyebrow: 'BILL LIST',
        title: '账单明细',
        subtitle: '按时间流展示当月全部收支记录，并预留详情入口'
      })

      // 这里删除了原来的“月份 / 支出筛选 / 类别筛选”三个占位 chip。
      // 删除原因：当前这一步的目标是优先把“顶部日历显示”复用现有组件做出来，
      // 比起继续保留占位筛选，更需要先让账单页具备真实可见的月历结构。
      // 新增功能：直接复用现有 BillDatePicker 作为内嵌月历，先完成顶部日历展示。
      BillDatePicker({
        embeddedMode: true,
        year: this.selectedYear,
        month: this.selectedMonth,
        day: this.selectedDay,
        hour: 0,
        minute: 0,
        onValueChange: (value: BillDatePickerValue) => {
          // 新增：接收内嵌日历的实时回调，先把用户当前选中的年月日存到页面状态里。
          // 这一轮先只做显示，后续再继续把这个状态真正联动到账单列表筛选。
          this.selectedYear = value.year
          this.selectedMonth = value.month
          this.selectedDay = value.day
        }
      })

      // 这里删除了原来手写的 groups + ForEach 列表渲染。
      // 删除原因：仓库里已经有现成的 BillRecordTimeline / BillTimeline / BillTimelineMapper 这一整套账单时间线组件，
      // 如果继续手写列表，会和已有组件能力重复，后面维护成本更高。
      // 新增功能：直接复用 BillRecordTimeline，并把顶部日历当前选中的年月日转换成 filter.day，
      // 这样用户切换日历日期后，下方账单列表会自动只展示该天的账单。
      BillRecordTimeline({
        records: this.billRecords,
        filter: {
          day: this.selectedDateKey()
        },
        onOpenBill: (_billId: string) => {
          this.onOpenDetail()
        }
      })

    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // 新增：和首页保持一致，收到 Index 层的账单刷新信号后重新读取本地存储。
  private onBillRefreshChanged() {
    this.loadBills()
  }

  // 新增：把读取真实账单存储的逻辑集中在一个函数里。
  // 这样 aboutToAppear 和 Watch 刷新都复用同一入口，避免重复写 BillRecordStore.load()。
  private loadBills() {
    BillRecordStore.load(getContext(this))
      .then((records: BillRecord[]) => {
        this.billRecords = records
      })
      .catch(() => {
        this.billRecords = []
      })
  }

  // 把 BillDatePicker 回传的 year / month / day 组装成 BillTimelineMapper 可识别的 yyyy-MM-dd。
  // 这里单独抽成函数，后面如果账单页还要做“整月筛选 / 日期区间筛选”，可以继续复用。
  private selectedDateKey(): string {
    return this.selectedYear.toString() + '-' + this.pad2(this.selectedMonth + 1) + '-' + this.pad2(this.selectedDay)
  }

  // 本地补一个两位数格式化，避免为了这一处联动额外改动其他工具类。
  private pad2(value: number): string {
    return value < 10 ? '0' + value.toString() : value.toString()
  }
}
