interface StatisticYearWheelItem {
  slotIndex: number
  year: number
  isPlaceholder: boolean
}

@Component
export struct StatisticYearWheel {
  onChange: (year: number) => void = (_year: number) => {}

  @State private selectedYear: number = new Date().getFullYear()
  @State private selectedIndex: number = 0

  private readonly anchorYear: number = new Date().getFullYear()
  private readonly itemCount: number = 12
  private readonly trailingPlaceholderCount: number = 4
  private readonly yearItemWidth: number = 84
  private readonly yearItemGap: number = 18
  private readonly yearScroller: Scroller = new Scroller()

  aboutToAppear(): void {
    this.onChange(this.selectedYear)
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      List({ space: this.yearItemGap, initialIndex: 0, scroller: this.yearScroller }) {
        ForEach(this.yearItems(), (item: StatisticYearWheelItem) => {
          ListItem() {
            this.yearItem(item, this.isSelected(item))
          }
        }, (item: StatisticYearWheelItem) => item.year.toString() + '_' + item.slotIndex.toString())
      }
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .onScrollIndex((start: number, _end: number) => {
        this.syncSelectedByIndex(start)
      })
      .onScrollStop(() => {
        this.yearScroller.scrollToIndex(this.selectedIndex, true, ScrollAlign.START)
      })

      Text('▲')
        .width(this.yearItemWidth)
        .fontSize(10)
        .fontColor('#56BFAF')
        .textAlign(TextAlign.Center)
        .margin({ top: 32 })
    }
    .width('100%')
    .height(48)
  }

  @Builder
  private yearItem(item: StatisticYearWheelItem, selected: boolean) {
    Column() {
      Text(this.yearLabel(item))
        .width(this.yearItemWidth)
        .fontSize(18)
        .fontWeight(selected ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(selected ? '#56BFAF' : '#9CA6BA')
        .textAlign(TextAlign.Center)
        .lineHeight(26)
    }
    .opacity(item.isPlaceholder ? 0 : 1)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
  }

  private yearItems(): StatisticYearWheelItem[] {
    const items: StatisticYearWheelItem[] = []

    for (let offset = 0; offset < this.itemCount; offset++) {
      const item: StatisticYearWheelItem = {
        slotIndex: offset,
        year: this.anchorYear - offset,
        isPlaceholder: false
      }
      items.push(item)
    }

    for (let placeholderIndex = 0; placeholderIndex < this.trailingPlaceholderCount; placeholderIndex++) {
      const placeholderItem: StatisticYearWheelItem = {
        slotIndex: this.itemCount + placeholderIndex,
        year: -(placeholderIndex + 1),
        isPlaceholder: true
      }
      items.push(placeholderItem)
    }

    return items
  }

  private isSelected(item: StatisticYearWheelItem): boolean {
    return !item.isPlaceholder && item.slotIndex === this.selectedIndex
  }

  private syncSelectedByIndex(index: number): void {
    let normalizedIndex = index

    if (normalizedIndex < 0) {
      normalizedIndex = 0
    }

    if (normalizedIndex > this.itemCount - 1) {
      normalizedIndex = this.itemCount - 1
    }

    const year = this.anchorYear - normalizedIndex
    if (normalizedIndex !== this.selectedIndex || year !== this.selectedYear) {
      this.selectedIndex = normalizedIndex
      this.selectedYear = year
      this.onChange(year)
    }
  }

  private yearLabel(item: StatisticYearWheelItem): string {
    if (item.isPlaceholder) {
      return ''
    }

    if (item.year === this.anchorYear) {
      return '今年'
    }

    if (item.year === this.anchorYear - 1) {
      return '去年'
    }

    return item.year.toString() + '年'
  }
}
