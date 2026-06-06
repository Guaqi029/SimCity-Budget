import { InfoCard } from '../components/InfoCard'
import { StatisticSevenDayBarChart } from '../components/analytics/StatisticSevenDayBarChart'
import { StatisticTopTabItem, StatisticTopTabs } from '../components/analytics/StatisticTopTabs'
import { StatisticPanelCard } from '../components/analytics/StatisticPanelCard'

@Builder
function AnalyticsProgressCard(title: string, meta: string, percentText: string, widthPercent: number) {
  Column({ space: 12 }) {
    Row() {
      Column({ space: 4 }) {
        Text(title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#18233A')
        Text(meta)
          .fontSize(13)
          .fontColor('#6B7A99')
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Text('正常')
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1B8F63')
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .backgroundColor('#E6FAF1')
        .borderRadius(16)
    }
    .width('100%')

    Row() {
      Column()
        .width(widthPercent + '%')
        .height(10)
        .backgroundColor('#111B33')
        .borderRadius(8)
    }
    .width('100%')
    .height(10)
    .backgroundColor('#EEF3F9')
    .borderRadius(8)

    Text(percentText)
      .fontSize(12)
      .fontColor('#95A2BC')
  }
  .width('100%')
  .padding(18)
  .backgroundColor('#FFFFFF')
  .borderRadius(24)
  .alignItems(HorizontalAlign.Start)
}

@Builder
function AnalyticsRankRow(rank: string, label: string, value: string, widthPercent: number) {
  Column({ space: 8 }) {
    Row() {
      Text(rank + '. ' + label)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#24314A')
      Blank()
      Text(value)
        .fontSize(14)
        .fontColor('#6B7A99')
    }
    .width('100%')

    Row() {
      Column()
        .width(widthPercent + '%')
        .height(10)
        .backgroundColor('#90C4FF')
        .borderRadius(8)
    }
    .width('100%')
    .height(10)
    .backgroundColor('#EEF3F9')
    .borderRadius(8)
  }
  .width('100%')
  .padding(18)
  .backgroundColor('#FFFFFF')
  .borderRadius(24)
  .alignItems(HorizontalAlign.Start)
}

@Builder
function AnalyticsBudgetBoardContent() {
  Column({ space: 14 }) {
    AnalyticsProgressCard('餐饮', '¥81 / ¥800', '10%', 10)
    AnalyticsProgressCard('娱乐', '¥99 / ¥300', '33%', 33)
    AnalyticsProgressCard('学习', '¥128 / ¥300', '43%', 43)
  }
  .width('100%')
  .alignItems(HorizontalAlign.Start)
}

@Builder
function AnalyticsRankBoardContent() {
  Column({ space: 14 }) {
    AnalyticsRankRow('1', '学习', '¥128.00', 100)
    AnalyticsRankRow('2', '娱乐', '¥99.00', 78)
    AnalyticsRankRow('3', '日用', '¥62.00', 48)
  }
  .width('100%')
  .alignItems(HorizontalAlign.Start)
}

@Component
export struct AnalyticsPage {
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
      StatisticSevenDayBarChart()

      GridRow({ columns: 2, gutter: 12 }) {
        GridCol() {
          InfoCard({ title: '本月总支出', value: '¥388.00', description: '只统计支出' })
        }
        GridCol() {
          InfoCard({ title: '本月总收入', value: '¥1200.00', description: '不抵扣健康度' })
        }
        GridCol() {
          InfoCard({ title: '日均预算', value: '¥64.52', description: '月预算 / 月天数' })
        }
        GridCol() {
          InfoCard({ title: '剩余预算', value: '¥1612.00', description: '合理线 ¥1806.45' })
        }
      }

      StatisticPanelCard({
        title: '分类预算看板',
        actionText: '',
        content: AnalyticsBudgetBoardContent
      })

    
      StatisticPanelCard({
        title: '分类支出排行',
        actionText: '查看全部',
        content: AnalyticsRankBoardContent
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
