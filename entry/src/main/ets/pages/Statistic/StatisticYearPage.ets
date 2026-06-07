import { StatisticYearSummaryCard } from '../../components/analytics/StatisticYearSummaryCard'
import { StatisticYearBarChart } from '../../components/analytics/StatisticYearBarChart'
import { StatisticYearHeatMap } from '../../components/analytics/StatisticYearHeatMap'
import { StatisticYearAssetTrendChart } from '../../components/analytics/StatisticYearAssetTrendChart'
import { StatisticYearRatioChart } from '../../components/analytics/StatisticYearRatioChart'
import { StatisticYearExpenseCategoryList } from '../../components/analytics/StatisticYearExpenseCategoryList'
import { StatisticYearReportTable } from '../../components/analytics/StatisticYearReportTable'
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

      StatisticYearHeatMap({
        year: this.selectedYear,
        billRefreshVersion: this.billRefreshVersion
      })

      StatisticYearAssetTrendChart({
        year: this.selectedYear,
        billRefreshVersion: this.billRefreshVersion
      })

      StatisticYearRatioChart({
        year: this.selectedYear,
        billRefreshVersion: this.billRefreshVersion
      })

      StatisticYearExpenseCategoryList({
        year: this.selectedYear,
        billRefreshVersion: this.billRefreshVersion
      })

      StatisticYearReportTable({
        year: this.selectedYear,
        billRefreshVersion: this.billRefreshVersion
      })

      Column()
        .width('100%')
        .height(60)
        .backgroundColor('#00000000')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
