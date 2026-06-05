export interface BillDatePickerValue {
  year: number
  month: number
  day: number
  hour: number
  minute: number
}

interface CalendarDayCell {
  day: number
  lunar: string
  selected: boolean
  disabled: boolean
}

@Component
export struct BillDatePicker {
  @Prop year: number = new Date().getFullYear()
  @Prop month: number = new Date().getMonth()
  @Prop day: number = new Date().getDate()
  @Prop hour: number = new Date().getHours()
  @Prop minute: number = new Date().getMinutes()
  @State private pickedYear: number = new Date().getFullYear()
  @State private pickedMonth: number = new Date().getMonth()
  @State private pickedDay: number = new Date().getDate()
  @State private pickedHour: number = new Date().getHours()
  @State private pickedMinute: number = new Date().getMinutes()
  @State private calendarVersion: number = 0
  @State private showYearMonthPicker: boolean = false
  @State private draftYear: number = new Date().getFullYear()
  @State private draftMonth: number = new Date().getMonth()
  @State private yearMonthPickerVersion: number = 0

  onCancel: () => void = () => {}
  onConfirm: (value: BillDatePickerValue) => void = () => {}

  aboutToAppear() {
    this.pickedYear = this.year
    this.pickedMonth = this.month
    this.pickedDay = this.day
    this.pickedHour = this.hour
    this.pickedMinute = this.minute
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column({ space: 14 }) {
        Row() {
          Image($r('app.media.arrow_back'))
            .width(22)
            .height(22)
            .opacity(0.9)
            .onClick(() => {
              this.goPreviousMonth()
            })

          Row({ space: 6 }) {
            Text((this.pickedMonth + 1).toString() + '月')
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor('#111111')
            Text(this.pickedYear.toString())
              .fontSize(10)
              .fontColor('#777777')
              .margin({ top: 8 })
          }
          .margin({ left: 14 })
          .onClick(() => {
            this.openYearMonthPicker()
          })

          Blank()

          Image($r('app.media.arrow_forward'))
            .width(22)
            .height(22)
            .opacity(this.canGoNextMonth() ? 0.9 : 0.25)
            .onClick(() => {
              if (this.canGoNextMonth()) {
                this.goNextMonth()
              }
            })
        }
        .width('100%')

        GridRow({ columns: 7 }) {
          ForEach(['日', '一', '二', '三', '四', '五', '六'], (week: string) => {
            GridCol() {
              Text(week)
                .fontSize(13)
                .fontColor('#111111')
                .textAlign(TextAlign.Center)
                .width('100%')
            }
          }, (week: string) => week)
        }

        Column() {
          GridRow({ columns: 7, gutter: 2 }) {
            ForEach(this.calendarCells(), (cell: CalendarDayCell, index: number) => {
              GridCol() {
                this.calendarDay(cell)
              }
            }, (_cell: CalendarDayCell, index: number) => this.calendarVersion.toString() + '_' + index.toString())
          }
        }
        .width('100%')
        .gesture(
          PanGesture({ direction: PanDirection.Horizontal, distance: 8 })
            .onActionEnd((event: GestureEvent) => {
              this.handleCalendarSwipe(event.offsetX)
            })
        )

        Row() {
          Text('◔')
            .fontSize(17)
            .fontColor('#111111')
          Text('设置时间')
            .fontSize(15)
            .fontColor('#111111')
            .margin({ left: 10 })
          Blank()
          Text('›')
            .fontSize(28)
            .fontColor('#999999')
        }
        .width('100%')
        .height(34)

        Row() {
          Blank()
          TextPicker({ range: this.hourOptions(), selected: this.pickedHour })
            .width(76)
            .height(96)
            .selectedTextStyle({ color: '#111111', font: { size: 22, weight: FontWeight.Bold } })
            .textStyle({ color: '#C8C8C8', font: { size: 15 } })
            .onChange((_value: string | string[], index: number | number[]) => {
              if (typeof index === 'number') {
                this.pickedHour = index
              }
            })
          Text(':')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111111')
            .margin({ left: 16, right: 16 })
          TextPicker({ range: this.minuteOptions(), selected: this.pickedMinute })
            .width(76)
            .height(96)
            .selectedTextStyle({ color: '#111111', font: { size: 22, weight: FontWeight.Bold } })
            .textStyle({ color: '#C8C8C8', font: { size: 15 } })
            .onChange((_value: string | string[], index: number | number[]) => {
              if (typeof index === 'number') {
                this.pickedMinute = index
              }
            })
          Blank()
        }
        .width('100%')
        .height(104)

        Row() {
          Text('取消')
            .fontSize(15)
            .fontColor('#888888')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.onCancel()
            })
          Text('确定')
            .fontSize(15)
            .fontColor('#55B8A7')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.onConfirm({
                year: this.pickedYear,
                month: this.pickedMonth,
                day: this.pickedDay,
                hour: this.pickedHour,
                minute: this.pickedMinute
              })
            })
        }
        .width('100%')
        .height(42)
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 18, bottom: 14 })
      .backgroundColor('#FFFFFF')
      .borderRadius(10)

      if (this.showYearMonthPicker) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#66000000')

        ForEach([this.yearMonthPickerVersion], () => {
          this.yearMonthPicker()
        }, (version: number) => version.toString())
      }
    }
    .width('88%')
  }

  @Builder
  private yearMonthPicker() {
    Column({ space: 12 }) {
      Text('选择年月')
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor('#111111')

      Row() {
        Blank()
        TextPicker({ range: this.yearOptions(), selected: this.draftYear - this.minYear() })
          .width(96)
          .height(116)
          .selectedTextStyle({ color: '#111111', font: { size: 20, weight: FontWeight.Bold } })
          .textStyle({ color: '#BBBBBB', font: { size: 14 } })
          .onChange((_value: string | string[], index: number | number[]) => {
            if (typeof index === 'number') {
              this.draftYear = this.minYear() + index
              this.normalizeDraftMonth()
              this.yearMonthPickerVersion += 1
            }
          })
        Text('年')
          .fontSize(15)
          .fontColor('#555555')
          .margin({ left: 4, right: 14 })
        TextPicker({ range: this.monthOptions(), selected: this.draftMonth })
          .width(82)
          .height(116)
          .selectedTextStyle({ color: '#111111', font: { size: 20, weight: FontWeight.Bold } })
          .textStyle({ color: '#BBBBBB', font: { size: 14 } })
          .onChange((_value: string | string[], index: number | number[]) => {
            if (typeof index === 'number') {
              this.draftMonth = index
              this.normalizeDraftMonth()
            }
          })
        Text('月')
          .fontSize(15)
          .fontColor('#555555')
          .margin({ left: 4 })
        Blank()
      }
      .width('100%')

      Row() {
        Text('取消')
          .fontSize(15)
          .fontColor('#888888')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.showYearMonthPicker = false
          })
        Text('确定')
          .fontSize(15)
          .fontColor('#55B8A7')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.applyDraftYearMonth()
          })
      }
      .width('100%')
      .height(36)
    }
    .width('86%')
    .padding({ left: 18, right: 18, top: 16, bottom: 10 })
    .backgroundColor('#FFFFFF')
    .borderRadius(10)
  }

  @Builder
  private calendarDay(cell: CalendarDayCell) {
    Column({ space: 2 }) {
      Text(cell.day > 0 ? cell.day.toString() : '')
        .fontSize(14)
        .fontColor(this.calendarDayTextColor(cell))
        .fontWeight(cell.selected ? FontWeight.Bold : FontWeight.Regular)
        .textAlign(TextAlign.Center)
      Text(cell.lunar)
        .fontSize(9)
        .fontColor(this.calendarLunarTextColor(cell))
        .textAlign(TextAlign.Center)
    }
    .width(44)
    .height(44)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(cell.selected ? '#55B8A7' : '#FFFFFF')
    .borderRadius(22)
    .onClick(() => {
      if (cell.day > 0 && !cell.disabled) {
        this.pickedDay = cell.day
        this.calendarVersion += 1
      }
    })
  }

  private calendarCells(): CalendarDayCell[] {
    const cells: CalendarDayCell[] = []
    const firstDay = new Date(this.pickedYear, this.pickedMonth, 1).getDay()
    const daysInMonth = new Date(this.pickedYear, this.pickedMonth + 1, 0).getDate()

    for (let index = 0; index < firstDay; index++) {
      cells.push({ day: 0, lunar: '', selected: false, disabled: true })
    }

    for (let day = 1; day <= daysInMonth; day++) {
      const disabled = this.isFutureDate(this.pickedYear, this.pickedMonth, day)
      cells.push({
        day: day,
        lunar: this.lunarText(day),
        selected: day === this.pickedDay && !disabled,
        disabled: disabled
      })
    }

    while (cells.length < 42) {
      cells.push({ day: 0, lunar: '', selected: false, disabled: true })
    }
    return cells
  }

  private calendarDayTextColor(cell: CalendarDayCell): string {
    if (cell.selected) {
      return '#FFFFFF'
    }
    if (cell.disabled) {
      return '#C8C8C8'
    }
    return '#111111'
  }

  private calendarLunarTextColor(cell: CalendarDayCell): string {
    if (cell.selected) {
      return '#FFFFFF'
    }
    if (cell.disabled) {
      return '#D6D6D6'
    }
    return '#999999'
  }

  private goPreviousMonth() {
    if (this.pickedMonth === 0) {
      this.pickedYear -= 1
      this.pickedMonth = 11
    } else {
      this.pickedMonth -= 1
    }
    this.normalizePickedDay()
    this.calendarVersion += 1
  }

  private goNextMonth() {
    if (!this.canGoNextMonth()) {
      return
    }
    if (this.pickedMonth === 11) {
      this.pickedYear += 1
      this.pickedMonth = 0
    } else {
      this.pickedMonth += 1
    }
    this.normalizePickedDay()
    this.calendarVersion += 1
  }

  private handleCalendarSwipe(offsetX: number) {
    if (this.showYearMonthPicker) {
      return
    }
    if (offsetX > 36) {
      this.goPreviousMonth()
    } else if (offsetX < -36 && this.canGoNextMonth()) {
      this.goNextMonth()
    }
  }

  private canGoNextMonth(): boolean {
    const now = new Date()
    if (this.pickedYear > now.getFullYear()) {
      return false
    }
    if (this.pickedYear === now.getFullYear() && this.pickedMonth >= now.getMonth()) {
      return false
    }
    return true
  }

  private normalizePickedDay() {
    const daysInMonth = new Date(this.pickedYear, this.pickedMonth + 1, 0).getDate()
    if (this.pickedDay > daysInMonth) {
      this.pickedDay = daysInMonth
    }

    const now = new Date()
    if (this.pickedYear === now.getFullYear() && this.pickedMonth === now.getMonth() && this.pickedDay > now.getDate()) {
      this.pickedDay = now.getDate()
    }
  }

  private isFutureDate(year: number, month: number, day: number): boolean {
    const now = new Date()
    const target = new Date(year, month, day)
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
    return target.getTime() > today.getTime()
  }

  private openYearMonthPicker() {
    this.draftYear = this.pickedYear
    this.draftMonth = this.pickedMonth
    this.normalizeDraftMonth()
    this.yearMonthPickerVersion += 1
    this.showYearMonthPicker = true
  }

  private applyDraftYearMonth() {
    this.pickedYear = this.draftYear
    this.pickedMonth = this.draftMonth
    this.normalizePickedDay()
    this.calendarVersion += 1
    this.showYearMonthPicker = false
  }

  private minYear(): number {
    return 1970
  }

  private yearOptions(): string[] {
    const options: string[] = []
    const now = new Date()
    for (let year = this.minYear(); year <= now.getFullYear(); year++) {
      options.push(year.toString())
    }
    return options
  }

  private monthOptions(): string[] {
    const options: string[] = []
    const now = new Date()
    const maxMonth = this.draftYear === now.getFullYear() ? now.getMonth() : 11
    for (let month = 0; month <= maxMonth; month++) {
      options.push((month + 1).toString())
    }
    return options
  }

  private normalizeDraftMonth() {
    const now = new Date()
    if (this.draftYear > now.getFullYear()) {
      this.draftYear = now.getFullYear()
    }
    if (this.draftYear === now.getFullYear() && this.draftMonth > now.getMonth()) {
      this.draftMonth = now.getMonth()
    }
    if (this.draftMonth < 0) {
      this.draftMonth = 0
    }
  }

  private lunarText(day: number): string {
    if (day === 5) {
      return '芒种'
    }
    if (day === 21) {
      return '夏至'
    }
    const lunarDays: string[] = ['初一', '初二', '初三', '初四', '初五', '初六', '初七', '初八', '初九', '初十',
      '十一', '十二', '十三', '十四', '十五', '十六', '十七', '十八', '十九', '二十',
      '廿一', '廿二', '廿三', '廿四', '廿五', '廿六', '廿七', '廿八', '廿九', '三十']
    return lunarDays[(day - 1) % lunarDays.length]
  }

  private hourOptions(): string[] {
    const options: string[] = []
    for (let index = 0; index < 24; index++) {
      options.push(index < 10 ? '0' + index.toString() : index.toString())
    }
    return options
  }

  private minuteOptions(): string[] {
    const options: string[] = []
    for (let index = 0; index < 60; index++) {
      options.push(index < 10 ? '0' + index.toString() : index.toString())
    }
    return options
  }
}
