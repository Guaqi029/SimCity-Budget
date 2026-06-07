import { StatisticAssetSummaryChart } from '../../components/analytics/StatisticAssetSummaryChart'
import { StatisticBudgetRatioCard } from '../../components/analytics/StatisticBudgetRatioCard'
import { StatisticSevenDayBarChart } from '../../components/analytics/StatisticSevenDayBarChart'
import { StatisticTopTabItem, StatisticTopTabs } from '../../components/analytics/StatisticTopTabs'
import { StatisticMonthPage } from './StatisticMonthPage'
import { StatisticYearPage } from './StatisticYearPage'

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
    { id: 'year', label: '年统计' }
  ]

  build() {
    Column({ space: 14 }) {
      // 这里保留顶部 tab 的 selectedId 与 selectedTabId 直接绑定。
      // 原因：顶部绿色高亮和页面内容切换必须共用同一个状态源，否则就会出现“页面切了，但高亮还停在日常”的错位。
      // 新增功能：点击顶部按钮后，内容区域和绿色高亮都会同步切换到对应页面。
      StatisticTopTabs({
        items: this.tabs,
        selectedId: this.selectedTabId,
        onChange: (id: string) => {
          this.selectedTabId = id
        }
      })

      // 这里把统计页主体内容绑定到顶部 tab 的三个真实子页面。
      // 新增功能：顶部按钮点击后会在“日常 / 月统计 / 年统计”之间同步切换内容。
      this.renderSelectedPage()
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private renderSelectedPage() {
    if (this.selectedTabId === 'daily') {
      // 日常页继续保留当前已经完成的两个核心统计组件。
      StatisticSevenDayBarChart({
        billRefreshVersion: this.billRefreshVersion
      })

      StatisticAssetSummaryChart({
        billRefreshVersion: this.billRefreshVersion
      })

      StatisticBudgetRatioCard({
        billRefreshVersion: this.billRefreshVersion
      })
    } else if (this.selectedTabId === 'month') {
      // 新增：把账单刷新版本继续透传给月统计页。
      // 原因：月统计页里的月汇总卡已经开始直接读取本地账单数据，
      // 所以新增/删除账单后，月统计页也需要跟日常统计页一样收到统一刷新信号。
      StatisticMonthPage({
        billRefreshVersion: this.billRefreshVersion
      })
    } else if (this.selectedTabId === 'year') {
      StatisticYearPage({
        billRefreshVersion: this.billRefreshVersion
      })
    }
  }
}
