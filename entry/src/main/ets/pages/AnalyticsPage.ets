import { PageHeader } from '../components/PageHeader'
import { InfoCard } from '../components/InfoCard'
import { SectionCard } from '../components/SectionCard'

@Component
export struct AnalyticsPage {
  build() {
    Column({ space: 16 }) {
      PageHeader({
        eyebrow: 'ANALYTICS',
        title: '统计分析',
        subtitle: '看板与统计合并页，承接预算进度、排行与趋势图'
      })

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

      SectionCard({ title: '分类预算看板', description: '后续放置餐饮、娱乐、学习、日用等分类预算进度条和超支状态标签。' })

      this.buildProgressCard('餐饮', '¥81 / ¥800', '10%', 10)
      this.buildProgressCard('娱乐', '¥99 / ¥300', '33%', 33)
      this.buildProgressCard('学习', '¥128 / ¥300', '43%', 43)

      SectionCard({ title: '分类支出排行', description: '后续接入排行榜、趋势条形图、消费占比和时间维度分析。' })
      this.buildRankRow('1', '学习', '¥128.00', 100)
      this.buildRankRow('2', '娱乐', '¥99.00', 78)
      this.buildRankRow('3', '日用', '¥62.00', 48)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildProgressCard(title: string, meta: string, percentText: string, widthPercent: number) {
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
  private buildRankRow(rank: string, label: string, value: string, widthPercent: number) {
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
}
