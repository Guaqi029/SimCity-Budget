import { AssetAccount } from '../../model/AssetAccount'
import { BillRecord } from '../../model/BillRecord'
import { AssetAccountStore } from '../../storage/AssetAccountStore'
import { BillRecordStore } from '../../storage/BillRecordStore'

interface StatisticYearAssetTrendItem {
  id: string
  month: number
  totalAsset: number
}

interface StatisticYearAssetTrendDateParts {
  year: number
  month: number
  day: number
  time: number
}

@Component
export struct StatisticYearAssetTrendChart {
  @Watch('onYearChanged') @Prop year: number = new Date().getFullYear()
  @Watch('onBillRefreshChanged') @Prop billRefreshVersion: number = 0

  @State private items: StatisticYearAssetTrendItem[] = []
  @State private chartWidth: number = 0

  private readonly axisWidth: number = 56
  private readonly plotHeight: number = 220

  aboutToAppear(): void {
    this.loadTrendData()
  }

  build() {
    Column({ space: 18 }) {
      this.headerRow()
      this.chartCard()
    }
    .width('100%')
    .padding(18)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private headerRow() {
    Row() {
      Row({ space: 8 }) {
        Text('资产走势')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#18233A')

        Text('⌄')
          .fontSize(18)
          .fontColor('#6B7A99')
      }
      .alignItems(VerticalAlign.Center)

      Blank()
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private chartCard() {
    Column({ space: 10 }) {
      Row({ space: 0 }) {
        this.axisLabelColumn()
        this.plotArea()
      }
      .width('100%')
      .alignItems(VerticalAlign.Bottom)

      Row({ space: 0 }) {
        Column()
          .width(this.axisWidth)
          .height(1)
          .opacity(0)

        Row({ space: 0 }) {
          ForEach(this.items, (item: StatisticYearAssetTrendItem) => {
            this.monthLabelSlot(item)
          }, (item: StatisticYearAssetTrendItem) => item.id + '_label')
        }
        .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 6, right: 10, top: 18, bottom: 12 })
    .backgroundColor('#FCFCFC')
    .borderRadius(22)
  }

  @Builder
  private axisLabelColumn() {
    Column() {
      ForEach(this.axisLabels(), (label: string) => {
        Text(label)
          .fontSize(11)
          .fontColor('#737D92')
          .width('100%')
          .textAlign(TextAlign.Start)
      }, (label: string, index: number) => label + '_' + index.toString())
    }
    .width(this.axisWidth)
    .height(this.plotHeight)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ right: 6 })
  }

  @Builder
  private plotArea() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width(1)
        .height(this.plotHeight)
        .backgroundColor('#BFE8DF')

      Column()
        .width('100%')
        .height(1)
        .backgroundColor('#D6DDE8')
        .margin({ top: this.plotHeight })

      ForEach(this.items, (item: StatisticYearAssetTrendItem, index: number) => {
        this.horizontalSegment(index)
      }, (item: StatisticYearAssetTrendItem) => item.id + '_h')

      ForEach(this.items, (item: StatisticYearAssetTrendItem, index: number) => {
        this.verticalSegment(index)
      }, (item: StatisticYearAssetTrendItem) => item.id + '_v')

      ForEach(this.items, (item: StatisticYearAssetTrendItem, index: number) => {
        this.pointDot(index)
      }, (item: StatisticYearAssetTrendItem) => item.id + '_p')
    }
    .layoutWeight(1)
    .height(this.plotHeight + 1)
    .onAreaChange((_oldValue, newValue) => {
      const nextWidth = Number(newValue.width)
      if (nextWidth > 0 && Math.abs(nextWidth - this.chartWidth) > 0.5) {
        this.chartWidth = nextWidth
      }
    })
  }

  @Builder
  private horizontalSegment(index: number) {
    if (index >= this.items.length - 1) {
      Column()
        .width(0)
        .height(0)
    } else {
      Column()
        .width(this.segmentWidth())
        .height(4)
        .borderRadius(2)
        .backgroundColor('#1F978D')
        .margin({ left: this.pointX(index), top: this.pointY(index) })
    }
  }

  @Builder
  private verticalSegment(index: number) {
    if (index >= this.items.length - 1) {
      Column()
        .width(0)
        .height(0)
    } else {
      Column()
        .width(4)
        .height(this.verticalSegmentHeight(index))
        .borderRadius(2)
        .backgroundColor('#1F978D')
        .margin({ left: this.pointX(index + 1) - 2, top: this.verticalSegmentTop(index) })
    }
  }

  @Builder
  private pointDot(index: number) {
    Column()
      .width(10)
      .height(10)
      .borderRadius(5)
      .backgroundColor('#1F978D')
      .margin({ left: this.pointX(index) - 5, top: this.pointY(index) - 3 })
  }

  @Builder
  private monthLabelSlot(item: StatisticYearAssetTrendItem) {
    Column() {
      Text(item.month.toString())
        .fontSize(12)
        .fontColor('#737D92')
        .textAlign(TextAlign.Center)
        .maxLines(1)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  private onYearChanged(): void {
    this.loadTrendData()
  }

  private onBillRefreshChanged(): void {
    this.loadTrendData()
  }

  private loadTrendData(): void {
    AssetAccountStore.load(getContext(this))
      .then((assets: AssetAccount[]) => {
        return BillRecordStore.load(getContext(this))
          .then((records: BillRecord[]) => {
            this.items = this.buildTrendItems(assets, records)
          })
      })
      .catch(() => {
        this.items = this.buildTrendItems([], [])
      })
  }

  private buildTrendItems(assets: AssetAccount[], records: BillRecord[]): StatisticYearAssetTrendItem[] {
    const currentTotal = this.currentTotalAsset(assets)
    const items: StatisticYearAssetTrendItem[] = []

    for (let month = 1; month <= 12; month++) {
      const monthEndTime = new Date(this.year, month, 0, 23, 59, 59, 999).getTime()
      let totalAfterMonth = 0

      for (let index = 0; index < records.length; index++) {
        const record = records[index]
        const parts = this.billDateParts(record.billDate)
        if (record.isDeleted || parts === undefined || parts.time <= monthEndTime) {
          continue
        }
        totalAfterMonth += this.assetImpact(record, assets)
      }

      const item: StatisticYearAssetTrendItem = {
        id: this.year.toString() + '_' + month.toString(),
        month: month,
        totalAsset: this.roundMoney(currentTotal - totalAfterMonth)
      }
      items.push(item)
    }

    return items
  }

  private currentTotalAsset(assets: AssetAccount[]): number {
    let total = 0
    for (let index = 0; index < assets.length; index++) {
      const asset = assets[index]
      const balance = Number(asset.balance)
      if (asset.isDeleted || !asset.includeInTotal || !(balance === balance)) {
        continue
      }
      total += balance
    }
    return total
  }

  private assetImpact(record: BillRecord, assets: AssetAccount[]): number {
    if (record.type === 'income') {
      return this.isIncludedAsset(record.assetId === undefined ? '' : record.assetId, assets) ? record.amount : 0
    }

    if (record.type === 'expense') {
      return this.isIncludedAsset(record.assetId === undefined ? '' : record.assetId, assets) ? -record.amount : 0
    }

    if (record.type === 'transfer') {
      const fromIncluded = this.isIncludedAsset(record.fromAssetId === undefined ? '' : record.fromAssetId, assets)
      const toIncluded = this.isIncludedAsset(record.toAssetId === undefined ? '' : record.toAssetId, assets)
      const fee = record.transferFee === undefined ? 0 : record.transferFee
      let impact = 0

      if (fromIncluded && !toIncluded) {
        impact -= record.amount
      } else if (!fromIncluded && toIncluded) {
        impact += record.amount
      }

      if (fromIncluded && fee > 0) {
        impact -= fee
      }

      return impact
    }

    return 0
  }

  private isIncludedAsset(assetId: string, assets: AssetAccount[]): boolean {
    if (assetId.length === 0) {
      return false
    }
    for (let index = 0; index < assets.length; index++) {
      if (assets[index].id === assetId) {
        return assets[index].includeInTotal && !assets[index].isDeleted
      }
    }
    return false
  }

  private axisLabels(): string[] {
    const labels: string[] = []
    const maxValue = this.maxAssetValue()
    const minValue = this.minAssetValue()
    const range = maxValue - minValue
    const step = range > 0 ? range / 4 : 0

    for (let index = 4; index >= 0; index--) {
      labels.push(this.formatAxisValue(minValue + step * index))
    }
    return labels
  }

  private maxAssetValue(): number {
    if (this.items.length === 0) {
      return 0
    }
    let maxValue = this.items[0].totalAsset
    for (let index = 1; index < this.items.length; index++) {
      if (this.items[index].totalAsset > maxValue) {
        maxValue = this.items[index].totalAsset
      }
    }
    return maxValue
  }

  private minAssetValue(): number {
    if (this.items.length === 0) {
      return 0
    }
    let minValue = this.items[0].totalAsset
    for (let index = 1; index < this.items.length; index++) {
      if (this.items[index].totalAsset < minValue) {
        minValue = this.items[index].totalAsset
      }
    }
    return minValue
  }

  private assetRange(): number {
    const maxValue = this.maxAssetValue()
    const minValue = this.minAssetValue()
    const range = maxValue - minValue
    return range > 0 ? range : 1
  }

  private monthSlotWidth(): number {
    if (this.chartWidth <= 0) {
      return 26
    }
    return this.chartWidth / 12
  }

  private segmentWidth(): number {
    const width = this.monthSlotWidth()
    return width > 4 ? width : 4
  }

  private pointX(index: number): number {
    return this.monthSlotWidth() * index + this.monthSlotWidth() / 2
  }

  private pointY(index: number): number {
    if (index < 0 || index >= this.items.length) {
      return this.plotHeight
    }
    const maxValue = this.maxAssetValue()
    const value = this.items[index].totalAsset
    const ratio = (maxValue - value) / this.assetRange()
    return ratio * (this.plotHeight - 24) + 8
  }

  private verticalSegmentTop(index: number): number {
    const currentY = this.pointY(index)
    const nextY = this.pointY(index + 1)
    return currentY < nextY ? currentY : nextY
  }

  private verticalSegmentHeight(index: number): number {
    return Math.abs(this.pointY(index + 1) - this.pointY(index))
  }

  private formatAxisValue(value: number): string {
    const rounded = Math.round(value)
    return this.formatThousands(rounded)
  }

  private formatThousands(value: number): string {
    const text = Math.abs(value).toString()
    let result = ''
    let count = 0

    for (let index = text.length - 1; index >= 0; index--) {
      result = text[index] + result
      count += 1
      if (count % 3 === 0 && index > 0) {
        result = ',' + result
      }
    }

    return value < 0 ? '-' + result : result
  }

  private roundMoney(value: number): number {
    return Math.round(value * 100) / 100
  }

  private billDateParts(billDate: string): StatisticYearAssetTrendDateParts | undefined {
    const date = new Date(billDate)
    if (date.getTime() !== date.getTime()) {
      return undefined
    }

    const parts: StatisticYearAssetTrendDateParts = {
      year: date.getFullYear(),
      month: date.getMonth() + 1,
      day: date.getDate(),
      time: date.getTime()
    }
    return parts
  }
}
