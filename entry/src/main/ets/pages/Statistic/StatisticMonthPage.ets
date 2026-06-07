import { StatisticMonthWheel } from '../../components/analytics/StatisticMonthWheel'
import { StatisticMonthBarChart } from '../../components/analytics/StatisticMonthBarChart'
import { StatisticMonthExpenseCategoryList } from '../../components/analytics/StatisticMonthExpenseCategoryList'
import { StatisticMonthRatioChart } from '../../components/analytics/StatisticMonthRatioChart'
import { StatisticMonthSummaryCard } from '../../components/analytics/StatisticMonthSummaryCard'

@Component
export struct StatisticMonthPage {
  // 新增：接收来自统计主页的账单刷新版本。
  // 原因：月统计页里的真实统计组件已经开始读取本地账单数据，
  // 所以新增或删除账单后，这里也需要收到统一的刷新信号来触发重算。
  @Prop billRefreshVersion: number = 0

  // 新增：在月统计页保存当前顶部轮盘选中的年月。
  // 原因：你要求“选中的月份不同会影响到下面其他组件的数据统计与页面刷新”，
  // 所以后续月支出卡、月趋势图、月报表等组件都应该统一读取这里的年月状态，而不是各自维护一套。
  @State private selectedYear: number = new Date().getFullYear()
  @State private selectedMonth: number = new Date().getMonth() + 1

  build() {
    // 这里把原来的纯文字占位页替换成“顶部年月轮盘 + 下方占位卡”的结构。
    // 删除原因：你现在要先实现月统计页最关键的顶部交互，继续只放静态标题已经不够支撑后续月统计开发。
    // 新增功能：月统计页顶部先具备年月选择能力，后面真实月统计图表可以直接挂在这个选择条下面。
    Column({ space: 14 }) {
      // 新增：把顶部轮盘选中的年月同步到当前页面状态。
      // 原因：这样下面的月统计组件不需要再自己感知轮盘点击，只要依赖 selectedYear / selectedMonth 就能自动重算数据。
      // 新增功能：月份一切换，当前页面内部依赖这个年月的组件都会有统一刷新入口。
      StatisticMonthWheel({
        onChange: (year: number, month: number) => {
          this.selectedYear = year
          this.selectedMonth = month
        }
      })

      // 替换：这里把原来的“月统计页面骨架说明卡”删除，换成真实的月汇总折叠卡。
      // 删除原因：原说明卡只用于验证轮盘年月是否变化，现在月统计已经进入组件逐步落地阶段，这块位置应该交给真实统计组件。
      // 新增功能：绿色月汇总卡会根据当前选中的年月和本地账单数据展示月支出、月收入、月结余等信息，并支持折叠展开。
      StatisticMonthSummaryCard({
        year: this.selectedYear,
        month: this.selectedMonth,
        billRefreshVersion: this.billRefreshVersion
      })

      // 新增：这里把月统计的第三个真实组件接到页面里。
      // 原因：你现在要开始逐个完成月统计页的主体内容，所以在月汇总卡之后，紧接着挂上“按当月天数动态渲染”的收支条形图。
      // 新增功能：图表会随着当前选中年月、账单刷新信号以及“支出 / 收入”切换实时重算。
      StatisticMonthBarChart({
        year: this.selectedYear,
        month: this.selectedMonth,
        billRefreshVersion: this.billRefreshVersion
      })

      StatisticMonthRatioChart({
        year: this.selectedYear,
        month: this.selectedMonth,
        billRefreshVersion: this.billRefreshVersion
      })

      StatisticMonthExpenseCategoryList({
        year: this.selectedYear,
        month: this.selectedMonth,
        billRefreshVersion: this.billRefreshVersion
      })

      Column()
        .width('100%')
        .height(80)
        .backgroundColor('#00000000')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
