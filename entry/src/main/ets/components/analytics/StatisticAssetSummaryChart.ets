import { AssetAccount } from '../../model/AssetAccount'
import { AssetAccountStore } from '../../storage/AssetAccountStore'

interface AssetAccountSegment {
  id: string
  name: string
  amount: number
  percent: number
  color: string
}

const ASSET_SUMMARY_COLORS: string[] = [
  '#F58A54',
  '#15B5C1',
  '#FFE45E',
  '#8F8CF7',
  '#69C36D',
  '#F26B8A',
  '#56BFAF',
  '#90C4FF',
  '#B7BFD1'
]

@Component
export struct StatisticAssetSummaryChart {
  // 新增：先沿用当前统计页已有的刷新版本号机制。
  // 原因：虽然这个组件现在改成优先读取资产账户，但统计页外层暂时还没有单独的资产刷新信号，
  // 所以这里先复用现有刷新入口，保证页面重新进入或外部触发刷新时，组件能重新装载数据。
  // 新增功能：收到外部刷新信号后重新读取本地账户数据并重画组件。
  @Watch('onBillRefreshChanged') @Prop billRefreshVersion: number = 0

  // 这里把原来按“消费分类占比”命名的状态替换成“资产账户占比”状态。
  // 删除原因：你刚刚明确修正了需求，这里展示的不是分类消费，而应该是资产账户在总资产中的占比。
  // 新增功能：组件内部后续都围绕账户金额占比工作，命名也和真实业务语义保持一致。
  @State private rawSegments: AssetAccountSegment[] = []
  @State private visibleSegments: AssetAccountSegment[] = []
  @State private totalAmount: number = 0
  @State private filterMinorExpense: boolean = false

  aboutToAppear() {
    this.loadSummaryData()
  }

  build() {
    Column({ space: 18 }) {
      this.headerRow()
      this.chartArea()
      this.filterToggleRow()
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
      Text('资产汇总')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#18233A')

      Text('⌄')
        .fontSize(18)
        .fontColor('#6B7A99')
        .margin({ left: 8 })

      Blank()

      Text('总资产')
        .fontSize(16)
        .fontColor('#56BFAF')

      Text('⌄')
        .fontSize(16)
        .fontColor('#6B7A99')
        .margin({ left: 4 })
    }
    .width('100%')
  }

  @Builder
  private chartArea() {
    Row() {
      Blank()

      Stack({ alignContent: Alignment.Center }) {
        // 这里把原来的“分类支出占比环图”改成“资产账户占比环图”。
        // 原因：这个组件天然适合做多段比例环图，比手工拼接弧线更稳定，也更方便在过滤后重新刷新。
        // 新增功能：visibleSegments 每次变化时，DataPanel 会自动按新的账户占比重绘。
        DataPanel({
          values: this.panelValues(),
          max: 0,
          type: DataPanelType.Circle
        })
          .width(220)
          .height(220)
          .closeEffect(true)
          .valueColors(this.panelColors())
          .trackBackgroundColor('#EEF3F9')
          .strokeWidth(26)

        Column({ space: 4 }) {
          Text('⇄')
            .fontSize(28)
            .fontColor('#5C6474')

          Text('资产金额')
            .fontSize(16)
            .fontColor('#4F596B')
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width(220)
      .height(220)

      Blank()
    }
    .width('100%')

    if (this.visibleSegments.length > 0) {
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(this.visibleSegments, (segment: AssetAccountSegment) => {
          this.legendItem(segment)
        }, (segment: AssetAccountSegment) => segment.id)
      }
      .width('100%')
    } else {
      Text('暂无可统计的资产账户数据')
        .fontSize(14)
        .fontColor('#8A94A6')
        .width('100%')
        .textAlign(TextAlign.Center)
    }
  }

  @Builder
  private legendItem(segment: AssetAccountSegment) {
    Row({ space: 8 }) {
      Column()
        .width(10)
        .height(10)
        .borderRadius(5)
        .backgroundColor(segment.color)

      Column({ space: 2 }) {
        Text(segment.name)
          .fontSize(13)
          .fontColor('#18233A')
          .maxLines(1)

        Text(this.formatMoney(segment.amount) + ' · ' + this.percentText(segment.percent))
          .fontSize(12)
          .fontColor('#6B7A99')
          .maxLines(1)
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('48%')
    .margin({ bottom: 10 })
  }

  @Builder
  private filterToggleRow() {
    Row() {
      Blank()

      Row({ space: 8 }) {
        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width(22)
            .height(22)
            .borderRadius(5)
            .backgroundColor(this.filterMinorExpense ? '#56BFAF' : '#E8EEF7')

          if (this.filterMinorExpense) {
            Text('✓')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
        }
        .width(22)
        .height(22)

        Text('过滤占比小于1%的资产')
          .fontSize(14)
          .fontColor('#5C6474')
      }
      .onClick(() => {
        // 这里不只是切换一个布尔值，而是切换后立刻重新构建 visibleSegments。
        // 原因：你要求“每次点击都需要刷新组件”，所以这里在点击后会马上重新计算过滤后的环图数据。
        // 新增功能：右下角过滤开关每点一次，环图和图例都会立即刷新。
        this.filterMinorExpense = !this.filterMinorExpense
        this.rebuildVisibleSegments()
      })
    }
    .width('100%')
  }

  private onBillRefreshChanged() {
    this.loadSummaryData()
  }

  // 这里把原来“从账单里聚合分类支出”的读取逻辑替换成“优先读取资产账户，读不到就用占位账户”。
  // 删除原因：需求已更正，这里不应该再依赖账单分类，而应该展示资产账户本身的金额占比。
  // 新增功能：当真实资产账户已经录入时，组件展示真实账户；当前还没完全接入时，则回退到占位账户保证页面能先跑通。
  private loadSummaryData() {
    AssetAccountStore.load(getContext(this))
      .then((assets: AssetAccount[]) => {
        this.rawSegments = this.buildSegments(assets)
        this.totalAmount = this.sumAmount(this.rawSegments)
        this.rebuildVisibleSegments()
      })
      .catch(() => {
        this.rawSegments = this.buildPlaceholderSegments()
        this.totalAmount = this.sumAmount(this.rawSegments)
        this.rebuildVisibleSegments()
      })
  }

  private rebuildVisibleSegments() {
    let nextSegments = this.rawSegments

    if (this.filterMinorExpense) {
      nextSegments = this.filterMinorSegments(nextSegments)
    }

    this.visibleSegments = this.limitSegments(nextSegments)
  }

  // 新增：把资产账户列表聚合成账户占比片段。
  // 原因：这里关心的是账户余额或资产金额，不再是账单流水，所以直接按 AssetAccount 统计更贴近最终业务。
  private buildSegments(assets: AssetAccount[]): AssetAccountSegment[] {
    const entries: AssetAccountSegment[] = []
    let totalAmount = 0

    for (let index = 0; index < assets.length; index++) {
      const asset = assets[index]
      const amount = Math.abs(Number(asset.balance))
      if (asset.isDeleted || !asset.includeInTotal || !(amount > 0)) {
        continue
      }
      totalAmount += amount
    }

    let colorIndex = 0
    for (let index = 0; index < assets.length; index++) {
      const asset = assets[index]
      const amount = Math.abs(Number(asset.balance))
      if (asset.isDeleted || !asset.includeInTotal || !(amount > 0)) {
        continue
      }
      const segment: AssetAccountSegment = {
        id: asset.id,
        name: asset.name,
        amount: amount,
        percent: totalAmount <= 0 ? 0 : amount / totalAmount,
        color: ASSET_SUMMARY_COLORS[colorIndex % ASSET_SUMMARY_COLORS.length]
      }
      entries.push(segment)
      colorIndex += 1
    }

    if (entries.length === 0) {
      return this.buildPlaceholderSegments()
    }

    entries.sort((left: AssetAccountSegment, right: AssetAccountSegment) => right.amount - left.amount)
    return entries
  }

  // 新增：当前资产账户体系还没有完全扩展时，先给组件一组占位账户。
  // 原因：你明确说目前只处于占位阶段，如果没有任何真实账户就直接空白，会影响统计页继续联调。
  // 新增功能：没有真实账户数据时，仍然能看到环图、图例和 1% 过滤效果。
  private buildPlaceholderSegments(): AssetAccountSegment[] {
    const placeholders: AssetAccountSegment[] = [
      { id: 'placeholder_none', name: '无账户', amount: 10000, percent: 0, color: ASSET_SUMMARY_COLORS[0] },
      { id: 'placeholder_yuebao', name: '余额宝', amount: 1330.75, percent: 0, color: ASSET_SUMMARY_COLORS[1] },
      { id: 'placeholder_reimburse', name: '报销', amount: 495.71, percent: 0, color: ASSET_SUMMARY_COLORS[2] },
      { id: 'placeholder_small', name: '小额账户', amount: 50, percent: 0, color: ASSET_SUMMARY_COLORS[3] }
    ]
    const totalAmount = this.sumAmount(placeholders)
    for (let index = 0; index < placeholders.length; index++) {
      placeholders[index].percent = totalAmount <= 0 ? 0 : placeholders[index].amount / totalAmount
    }
    return placeholders
  }

  private filterMinorSegments(segments: AssetAccountSegment[]): AssetAccountSegment[] {
    const filtered: AssetAccountSegment[] = []
    for (let index = 0; index < segments.length; index++) {
      if (segments[index].percent >= 0.01) {
        filtered.push(segments[index])
      }
    }
    return filtered.length > 0 ? filtered : segments
  }

  private limitSegments(segments: AssetAccountSegment[]): AssetAccountSegment[] {
    if (segments.length <= 9) {
      return segments
    }

    const visible: AssetAccountSegment[] = segments.slice(0, 8)
    let otherAmount = 0
    let otherPercent = 0
    for (let index = 8; index < segments.length; index++) {
      otherAmount += segments[index].amount
      otherPercent += segments[index].percent
    }

    const otherSegment: AssetAccountSegment = {
      id: 'other_segments',
      name: '其他',
      amount: otherAmount,
      percent: otherPercent,
      color: ASSET_SUMMARY_COLORS[8]
    }
    visible.push(otherSegment)
    return visible
  }

  private panelValues(): number[] {
    const values: number[] = []
    for (let index = 0; index < this.visibleSegments.length; index++) {
      values.push(this.visibleSegments[index].amount)
    }
    if (values.length === 0) {
      values.push(1)
    }
    return values
  }

  private panelColors(): string[] {
    const colors: string[] = []
    for (let index = 0; index < this.visibleSegments.length; index++) {
      colors.push(this.visibleSegments[index].color)
    }
    if (colors.length === 0) {
      colors.push('#DDE5F0')
    }
    return colors
  }

  private sumAmount(segments: AssetAccountSegment[]): number {
    let total = 0
    for (let index = 0; index < segments.length; index++) {
      total += segments[index].amount
    }
    return total
  }

  private formatMoney(value: number): string {
    const fixed = value.toFixed(2)
    if (fixed.endsWith('00')) {
      return value.toFixed(0)
    }
    if (fixed.endsWith('0')) {
      return value.toFixed(1)
    }
    return fixed
  }

  private percentText(percent: number): string {
    const value = percent * 100
    if (value >= 10) {
      return value.toFixed(0) + '%'
    }
    return value.toFixed(1) + '%'
  }
}
