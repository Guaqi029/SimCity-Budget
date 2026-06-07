interface StatisticMonthWheelItem {
  slotIndex: number
  absoluteMonthIndex: number
  year: number
  month: number
  isPlaceholder: boolean
}

@Component
export struct StatisticMonthWheel {
  // 新增：把选中月份变化通过回调透传给父页面。
  // 原因：你要求“选中的月份不同会影响到下面其他组件的数据统计与页面刷新”，
  // 所以这里不能只在组件内部高亮切换，还需要把最新年月通知给月统计页，供下面组件统一刷新。
  onChange: (year: number, month: number) => void = (_year: number, _month: number) => {}

  // 保留：当前选中的年月仍由轮盘组件内部管理。
  // 原因：顶部轮盘本身就是一个强交互组件，滚动停留在哪个月份就要立刻更新年份、高亮和下方统计，
  // 所以先在本组件内部维护状态，交互会更直接，同时再通过 onChange 往外同步即可。
  @State private selectedYear: number = new Date().getFullYear()
  @State private selectedMonth: number = new Date().getMonth() + 1
  @State private selectedIndex: number = 0

  // 新增：保留“当前真实月份”的绝对索引作为轮盘起点。
  // 原因：你希望轮盘始终从本月开始向右逆序排列，所以这里要有一个固定起点，
  // 后续无论往左滑到 5 月、4 月还是跨年到 12 月，都是基于这个起点向后倒推。
  private readonly anchorAbsoluteIndex: number = new Date().getFullYear() * 12 + new Date().getMonth()
  // 替换：这里不再只保留近一年 12 个月，而是扩展为近 5 年 60 个月。
  // 删除原因：你已经重新确认需要更长的时间范围来做月统计切换，12 个月不够覆盖使用场景。
  // 新增功能：月轮盘现在从本月开始，向右可以连续回看近 5 年共 60 个月的数据。
  private readonly itemCount: number = 60
  // 新增：在真实月份后面补几个空白槽位。
  // 原因：如果最右侧没有额外空白，最后几个月无法继续左移到固定三角指示位下面被选中。
  // 新增功能：现在列表末尾会有几个透明占位槽位，保证最右边的真实月份也能被滑到左侧高亮位。
  private readonly trailingPlaceholderCount: number = 5
  private readonly monthItemWidth: number = 44
  private readonly monthItemGap: number = 18
  private readonly monthScroller: Scroller = new Scroller()

  aboutToAppear(): void {
    // 新增：组件首次渲染时先把默认选中的本月同步给父页面。
    // 原因：月统计页下面的组件后续会依赖当前选中的年月做初始化统计，不能等用户手动滑动后才拿到第一份状态。
    this.onChange(this.selectedYear, this.selectedMonth)
  }

  build() {
    Row({ space: 18 }) {
      this.yearBlock()
      this.monthWheel()
    }
    .width('100%')
    .padding({ left: 4, right: 4, top: 2, bottom: 2 })
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  private yearBlock() {
    // 新增：左侧年份作为固定显示区，只显示当前选中的年份。
    // 原因：你希望“左侧黑色数字代表年份，固定”，所以年份不跟着月份一起铺成一排，而是单独做一个固定块。
    // 新增功能：当月份跨过 1 月/12 月时，这里会自动显示前一年或后一年。
    Text(this.selectedYear.toString())
      .fontSize(24)
      .fontWeight(FontWeight.Bold)
      .fontColor('#18233A')
      .width(68)
      .textAlign(TextAlign.Start)
  }

  @Builder
  private monthWheel() {
    // 替换：这里不再使用 Scroll + 偏移量推算月份，而是改成“水平 List + 显式月份槽位”。
    // 删除原因：上一版虽然已经是连续滚动，但吸附时仍然依赖偏移量换算，月份槽位不是离散单元，所以容易出现“视觉停在 2 月，逻辑却吸回 6 月”的错位。
    // 新增功能：现在每个月份都是明确的 ListItem 槽位，滚动停下后直接吸附到最近索引，高亮与三角形指示位会严格对应同一个月份单元。
    Stack({ alignContent: Alignment.TopStart }) {
      // 新增：给 List 绑定 Scroller，并通过 onScrollIndex 获取当前左侧第一个可见月份索引。
      // 原因：你要求“高亮槽位固定在左边第一个月份位置”，所以最稳的做法就是直接以 List 当前起始索引作为选中月份。
      // 新增功能：滚动过程中左边第一个可见槽位变化时，年份、高亮和下方统计月份会同步变化。
      List({ space: this.monthItemGap, initialIndex: 0, scroller: this.monthScroller }) {
        ForEach(this.monthItems(), (item: StatisticMonthWheelItem) => {
          ListItem() {
            this.monthItem(item, this.isSelected(item))
          }
        }, (item: StatisticMonthWheelItem) => item.absoluteMonthIndex.toString())
      }
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .onScrollIndex((start: number, _end: number) => {
        this.syncSelectedByIndex(start)
      })
      .onScrollStop(() => {
        // 新增：用户停止滑动时，把当前位置吸附到当前命中的月份槽位起点。
        // 原因：List 的滚动过程是连续的，但月份选择应该落在明确的独立槽位上，
        // 所以停止时统一 scrollToIndex 到当前 selectedIndex，保证高亮月份和视觉停靠位置完全对齐。
        this.monthScroller.scrollToIndex(this.selectedIndex, true, ScrollAlign.START)
      })

      // 新增：把三角形指示器独立从月份项里拆出来，并固定在左侧高亮槽位。
      // 原因：你明确要求“三角形位置不变，高亮和三角形分开”，所以三角形不能再跟着某个具体月份文本一起移动。
      // 新增功能：无论内容怎么滚动，三角形始终固定；停在三角形下方的月份会自动变成绿色高亮。
      Text('▲')
        .width(this.monthItemWidth)
        .fontSize(10)
        .fontColor('#56BFAF')
        .textAlign(TextAlign.Center)
        .margin({ top: 24 })
    }
    .width('100%')
    .height(40)
  }

  @Builder
  private monthItem(item: StatisticMonthWheelItem, selected: boolean) {
    Column() {
      Text(this.monthLabel(item))
        .width(this.monthItemWidth)
        .fontSize(18)
        .fontWeight(selected ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(selected ? '#56BFAF' : '#9CA6BA')
        .textAlign(TextAlign.Center)
        .lineHeight(24)
    }
    .opacity(item.isPlaceholder ? 0 : 1)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
  }

  // 替换：这里不再只生成真实月份项，而是追加右侧空白占位槽位。
  // 删除原因：旧数据结构在最后一个真实月份之后没有可滚动空间，所以最右边月份无法被推到左侧三角形位置来选中。
  // 新增功能：现在月份序列由“60 个真实月份槽位 + 若干空白槽位”组成，末尾月份也能完整吸附到高亮位。
  private monthItems(): StatisticMonthWheelItem[] {
    const items: StatisticMonthWheelItem[] = []

    for (let offset = 0; offset < this.itemCount; offset++) {
      const absoluteMonthIndex = this.anchorAbsoluteIndex - offset
      const year = Math.floor(absoluteMonthIndex / 12)
      const month = absoluteMonthIndex % 12 + 1
      const item: StatisticMonthWheelItem = {
        slotIndex: offset,
        absoluteMonthIndex: absoluteMonthIndex,
        year: year,
        month: month,
        isPlaceholder: false
      }
      items.push(item)
    }

    for (let placeholderIndex = 0; placeholderIndex < this.trailingPlaceholderCount; placeholderIndex++) {
      const placeholderItem: StatisticMonthWheelItem = {
        slotIndex: this.itemCount + placeholderIndex,
        absoluteMonthIndex: -(placeholderIndex + 1),
        year: 0,
        month: 0,
        isPlaceholder: true
      }
      items.push(placeholderItem)
    }

    return items
  }

  private isSelected(item: StatisticMonthWheelItem): boolean {
    return !item.isPlaceholder && item.slotIndex === this.selectedIndex
  }

  // 新增：根据 List 当前起始索引同步选中的年月。
  // 原因：现在每个月份都已经是独立槽位，最左边第一个可见槽位就是当前高亮月份，
  // 所以不再需要通过偏移量推算，直接用索引映射年月会更稳定。
  private syncSelectedByIndex(index: number): void {
    let normalizedIndex = index

    if (normalizedIndex < 0) {
      normalizedIndex = 0
    }

    if (normalizedIndex > this.itemCount - 1) {
      normalizedIndex = this.itemCount - 1
    }

    const absoluteMonthIndex = this.anchorAbsoluteIndex - normalizedIndex
    const year = Math.floor(absoluteMonthIndex / 12)
    const month = absoluteMonthIndex % 12 + 1

    if (normalizedIndex !== this.selectedIndex || year !== this.selectedYear || month !== this.selectedMonth) {
      this.selectedIndex = normalizedIndex
      this.selectedYear = year
      this.selectedMonth = month
      this.onChange(year, month)
    }
  }

  // 替换：这里在真实月份之外，额外支持空白占位槽位的渲染。
  // 删除原因：旧逻辑默认每个槽位都对应真实月份文案，无法为列表末尾制造可滚动的空白空间。
  // 新增功能：占位槽位会显示为空文本，视觉上是空白块，但依然占据一个固定月份槽宽。
  private monthLabel(item: StatisticMonthWheelItem): string {
    if (item.isPlaceholder) {
      return ''
    }
    return item.month.toString() + '月'
  }
}
