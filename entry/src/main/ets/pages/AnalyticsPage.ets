import { StatisticAssetSummaryChart } from '../components/analytics/StatisticAssetSummaryChart'
import { StatisticSevenDayBarChart } from '../components/analytics/StatisticSevenDayBarChart'
import { StatisticTopTabItem, StatisticTopTabs } from '../components/analytics/StatisticTopTabs'

@Component
export struct AnalyticsPage {
  // 新增：统计页也接入账单刷新版本号。
  // 原因：统计页里的图表组件都直接依赖本地账单数据，如果不接这条刷新信号，
  // 新增/删除账单后重新切回统计页时，图表可能还是旧数据。
  // 新增功能：AnalyticsPage 把刷新信号继续透传给内部统计组件，保证图表可以自动重载本地数据。
  @Prop billRefreshVersion: number = 0
  @State private selectedTabId: string = 'daily'
  private readonly tabs: StatisticTopTabItem[] = [
    { id: 'daily', label: '日常' },
    { id: 'month', label: '月统计' },
    { id: 'year', label: '年统计' },
    { id: 'custom', label: '自定义' }
  ]

  build() {
    Column({ space: 14 }) {
      StatisticTopTabs({
        items: this.tabs,
        selectedId: this.selectedTabId,
        onChange: (id: string) => {
          this.selectedTabId = id
        }
      })

      // 新增：这里把近 7 日条形图组件挂到统计页顶部。
      // 原因：你现在希望优先看到“来源于本地数据”的统计图表，而不是先继续堆静态说明卡片，
      // 所以先把条形图作为统计页的第一块核心内容区域渲染出来。
      // 新增功能：组件会自行读取本地 BillRecordStore，并把近 7 天收入/支出渲染成可切换的条形图。
      StatisticSevenDayBarChart({
        billRefreshVersion: this.billRefreshVersion
      })

      // 新增：这里把“分类消费占比”的资产汇总组件挂到统计页中部。
      // 原因：你希望统计页下一个核心内容是各分类消费占总分类百分比的环图，
      // 所以先把它作为独立模块接进来，后续你只需要微调组件内部样式即可。
      // 新增功能：组件会按本地账单里的支出分类占比画图，并支持右下角过滤小于 1% 的分类。
      StatisticAssetSummaryChart({
        billRefreshVersion: this.billRefreshVersion
      })

      // 这里删除了资产汇总组件下面原本所有的占位统计卡、预算看板和排行面板。
      // 删除原因：你已经明确这些内容在当前阶段都是无用的，占着页面位置只会干扰统计页的真实主线开发。
      // 新增功能：统计页当前只保留“近7日统计”和“资产汇总”两块核心组件，页面结构更聚焦，后续继续扩展也更清晰。
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
