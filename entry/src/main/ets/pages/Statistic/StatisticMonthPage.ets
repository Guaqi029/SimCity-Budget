import { StatisticMonthWheel } from '../../components/analytics/StatisticMonthWheel'

@Component
export struct StatisticMonthPage {
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

      Column({ space: 10 }) {
        Text('月统计页面骨架')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#24314A')

        // 替换：这里不再只写固定说明文字，而是把当前选中的年月展示出来。
        // 删除原因：原来的静态说明无法验证轮盘切换是否真的影响页面状态。
        // 新增功能：先用当前选中年月做可视化反馈，后面真实统计组件接入后也会基于这个年月刷新。
        Text(this.selectedYear.toString() + '年' + this.selectedMonth.toString() + '月已选中，后续月收入、月支出、月结余和月趋势组件都会基于这个年月刷新。')
          .fontSize(13)
          .fontColor('#7D8CA7')
          .lineHeight(20)
      }
      .width('100%')
      .padding(18)
      .backgroundColor('#FFFFFF')
      .borderRadius(20)
      .alignItems(HorizontalAlign.Start)

      Column()
        .width('100%')
        .height(420)
        .backgroundColor('#00000000')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
