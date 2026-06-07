import { StatisticYearSummaryCard } from '../../components/analytics/StatisticYearSummaryCard'
import { StatisticYearBarChart } from '../../components/analytics/StatisticYearBarChart'
import { StatisticYearWheel } from '../../components/analytics/StatisticYearWheel'

@Component
export struct StatisticYearPage {
  @Prop billRefreshVersion: number = 0
  @State private selectedYear: number = new Date().getFullYear()

  build() {
    Column({ space: 14 }) {
      StatisticYearWheel({
        onChange: (year: number) => {
          this.selectedYear = year
        }
      })

      StatisticYearSummaryCard({
        year: this.selectedYear,
        billRefreshVersion: this.billRefreshVersion
      })

      StatisticYearBarChart({
        year: this.selectedYear,
        billRefreshVersion: this.billRefreshVersion
      })

      Column()
        .width('100%')
        .height(180)
        .backgroundColor('#00000000')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
