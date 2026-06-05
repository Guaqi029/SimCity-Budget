import { TopMessageToast } from '../components/TopMessageToast'
import { AssetAccount } from '../model/AssetAccount'
import { AssetAccountStore } from '../storage/AssetAccountStore'

type AddBillMode = 'expense' | 'income' | 'transfer' | 'debt'

interface BillCategoryOption {
  icon: string
  title: string
}

interface CalendarDayCell {
  day: number
  lunar: string
  selected: boolean
}

const EXPENSE_CATEGORIES: BillCategoryOption[] = [
  { icon: '其', title: '其他' },
  { icon: '购', title: '购物消费' },
  { icon: '餐', title: '食品餐饮' },
  { icon: '行', title: '出行交通' },
  { icon: '娱', title: '休闲娱乐' },
  { icon: '周', title: '周转' },
  { icon: '罚', title: '罚款赔偿' },
  { icon: '理', title: '理财支出' },
  { icon: '善', title: '慈善捐助' },
  { icon: '+', title: '新增' },
  { icon: '居', title: '居家生活' },
  { icon: '学', title: '文化教育' },
  { icon: '礼', title: '送礼人情' },
  { icon: '医', title: '健康医疗' },
  { icon: '旅', title: '旅游' },
  { icon: '+', title: '编辑' }
]

const INCOME_CATEGORIES: BillCategoryOption[] = [
  { icon: 'AA', title: 'AA' },
  { icon: '生', title: '生活费' },
  { icon: '其', title: '其他' },
  { icon: '奖', title: '中奖' },
  { icon: '理', title: '理财盈利' },
  { icon: '礼', title: '礼金人情' },
  { icon: '借', title: '借入' },
  { icon: '金', title: '奖金' },
  { icon: '兼', title: '兼职外快' },
  { icon: '资', title: '工资' },
  { icon: '闲', title: '二手闲置' },
  { icon: '补', title: '补贴' },
  { icon: '报', title: '报销' },
  { icon: '+', title: '编辑' }
]

@Component
export struct AddBillPage {
  @State private mode: AddBillMode = 'expense'
  @State private selectedCategoryIndex: number = 0
  @State private amountText: string = '0.00'
  @State private justCalculated: boolean = false
  @State private remark: string = ''
  @State private toastVisible: boolean = false
  @State private toastMessage: string = ''
  @State private showDateSheet: boolean = false
  @State private showAssetSheet: boolean = false
  @State private assets: AssetAccount[] = []
  @State private selectedAssetId: string = ''
  @State private selectedAssetName: string = '无账户'
  @State private selectedYear: number = new Date().getFullYear()
  @State private selectedMonth: number = new Date().getMonth()
  @State private selectedDay: number = new Date().getDate()
  @State private selectedHour: number = new Date().getHours()
  @State private selectedMinute: number = new Date().getMinutes()
  onBack: () => void = () => {}
  private toastTimer: number = -1

  aboutToAppear() {
    this.loadAssets()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        this.header()
        this.categoryGrid()
        Blank()
        this.amountPanel()
        this.metaBar()
        this.keyboard()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FFFFFF')

      TopMessageToast({
        visible: this.toastVisible,
        message: this.toastMessage
      })
      .margin({ top: 48 })

      if (this.showDateSheet || this.showAssetSheet) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#000000')
          .opacity(0.52)
          .onClick(() => {
            this.closeSheets()
          })
      }

      if (this.showDateSheet) {
        this.dateSheet()
      }

      if (this.showAssetSheet) {
        this.assetSheet()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private header() {
    Row() {
      Image($r('app.media.arrow_back'))
        .width(30)
        .height(30)
        .onClick(() => {
          this.onBack()
        })

      Row({ space: 26 }) {
        this.modeTab('expense', '支出')
        this.modeTab('income', '收入')
        this.modeTab('transfer', '转账')
        this.modeTab('debt', '债务')
      }
      .margin({ left: 24 })
      .layoutWeight(1)
    }
    .width('100%')
    .height(68)
    .padding({ left: 14, right: 18, top: 8 })
  }

  @Builder
  private modeTab(mode: AddBillMode, title: string) {
    Column({ space: 7 }) {
      Text(title)
        .fontSize(20)
        .fontWeight(this.mode === mode ? FontWeight.Bold : FontWeight.Regular)
        .fontColor(this.mode === mode ? '#111111' : '#999999')

      Column()
        .width(54)
        .height(4)
        .backgroundColor(this.mode === mode ? '#55B8A7' : '#FFFFFF')
        .borderRadius(2)
    }
    .onClick(() => {
      this.mode = mode
      this.selectedCategoryIndex = 0
    })
  }

  @Builder
  private categoryGrid() {
    GridRow({ columns: 5, gutter: 4 }) {
      ForEach(this.currentCategories(), (category: BillCategoryOption, index: number) => {
        GridCol() {
          BillCategoryCell({
            category: category,
            selected: this.selectedCategoryIndex === index,
            onSelect: () => {
              this.selectedCategoryIndex = index
            }
          })
        }
      }, (category: BillCategoryOption, index: number) => category.title + index.toString())
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 8 })
  }

  @Builder
  private amountPanel() {
    Column() {
      Column()
        .width('100%')
        .height(1)
        .backgroundColor('#ECECEC')

      Row() {
        Text('◇')
          .fontSize(20)
          .fontColor('#111111')
        Text('标签')
          .fontSize(17)
          .fontColor('#111111')
          .margin({ left: 6 })
        Text(this.remark.length > 0 ? this.remark : '添加备注')
          .fontSize(16)
          .fontColor('#9A9A9A')
          .margin({ left: 26 })
          .layoutWeight(1)

        Text(this.amountText)
          .fontSize(30)
          .fontColor(this.mode === 'expense' ? '#E07178' : '#55B8A7')
      }
      .width('100%')
      .height(62)
      .padding({ left: 18, right: 16 })

      Column()
        .width('100%')
        .height(1)
        .backgroundColor('#ECECEC')
    }
    .width('100%')
    .height(64)
  }

  @Builder
  private metaBar() {
    Column() {
      Row({ space: 18 }) {
        this.metaItem('日', this.dateLabel(), () => {
          this.showDateSheet = true
        })
        this.metaItem('￥', this.selectedAssetName, () => {
          this.showAssetSheet = true
        })
      }
      .width('100%')
      .height(47)
      .padding({ left: 18, right: 18 })

      Column()
        .width('100%')
        .height(1)
        .backgroundColor('#ECECEC')
    }
    .width('100%')
    .height(48)
  }

  @Builder
  private metaItem(icon: string, title: string, onTap: () => void) {
    Row({ space: 5 }) {
      Text(icon)
        .fontSize(15)
        .fontColor('#111111')
      Text(title)
        .fontSize(16)
        .fontColor('#111111')
        .maxLines(1)
    }
    .onClick(() => {
      onTap()
    })
  }

  @Builder
  private keyboard() {
    Column({ space: 4 }) {
      Row({ space: 4 }) {
        this.keyboardButton('1')
        this.keyboardButton('2')
        this.keyboardButton('3')
        this.keyboardButton('退')
      }
      .width('100%')
      Row({ space: 4 }) {
        this.keyboardButton('4')
        this.keyboardButton('5')
        this.keyboardButton('6')
        this.splitKeyboardButton('+', '-')
      }
      .width('100%')
      Row({ space: 4 }) {
        this.keyboardButton('7')
        this.keyboardButton('8')
        this.keyboardButton('9')
        this.splitKeyboardButton('×', '÷')
      }
      .width('100%')
      Row({ space: 4 }) {
        this.keyboardButton('再记')
        this.keyboardButton('0')
        this.keyboardButton('.')
        this.primaryActionButton()
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 4, right: 4, top: 6, bottom: 6 })
    .backgroundColor('#F2F2F2')
  }

  @Builder
  private primaryActionButton() {
    // 主操作按钮依赖当前金额/表达式状态，显式分支能确保 ArkUI 在输入时重新构建按钮文案。
    if (this.hasOperator(this.amountText)) {
      this.keyboardButton('=')
    } else if (this.isZeroAmount(this.amountText)) {
      this.keyboardButton('取消')
    } else {
      this.keyboardButton('完成')
    }
  }

  @Builder
  private keyboardButton(key: string) {
    Text(key)
      .fontSize(key.length > 1 ? 17 : 24)
      .fontColor(this.keyboardButtonFontColor(key))
      .textAlign(TextAlign.Center)
      .layoutWeight(1)
      .height(58)
      .padding({ top: key.length > 1 ? 18 : 15 })
      .backgroundColor(this.keyboardButtonColor(key))
      .borderRadius(4)
      .onClick(() => {
        this.handleKey(key)
      })
  }

  @Builder
  private splitKeyboardButton(leftKey: string, rightKey: string) {
    // 第 2、3 行最后一格拆成两个半宽运算按钮，保持键盘总高度为 4 行。
    Row({ space: 2 }) {
      this.halfKeyboardButton(leftKey)
      this.halfKeyboardButton(rightKey)
    }
      .layoutWeight(1)
      .height(58)
  }

  @Builder
  private halfKeyboardButton(key: string) {
    Text(key)
      .fontSize(22)
      .fontColor('#111111')
      .textAlign(TextAlign.Center)
      .layoutWeight(1)
      .height(58)
      .padding({ top: 15 })
      .backgroundColor('#E8E8E8')
      .borderRadius(4)
      .onClick(() => {
        this.handleKey(key)
      })
  }

  private currentCategories(): BillCategoryOption[] {
    if (this.mode === 'income') {
      return INCOME_CATEGORIES
    }
    return EXPENSE_CATEGORIES
  }

  private isOperatorKey(key: string): boolean {
    return key === '退' || key === '+' || key === '-' || key === '×' || key === '÷' || key === '=' || key === '完成' || key === '取消' || key === '再记'
  }

  private keyboardButtonColor(key: string): string {
    if (key === '=' || key === '完成') {
      return '#55B8A7'
    }
    if (key === '取消') {
      return '#E8E8E8'
    }
    if (this.isOperatorKey(key)) {
      return '#E8E8E8'
    }
    return '#FFFFFF'
  }

  private keyboardButtonFontColor(key: string): string {
    if (key === '=' || key === '完成') {
      return '#FFFFFF'
    }
    return '#111111'
  }

  private handleKey(key: string) {
    if (key === '取消') {
      this.onBack()
      return
    }
    if (key === '完成') {
      return
    }
    if (key === '=') {
      this.calculateResult()
      return
    }
    if (key === '+' || key === '-' || key === '×' || key === '÷') {
      this.inputOperator(key)
      return
    }
    if (key === '再记') {
      this.clearCalculator()
      return
    }
    if (key === '退') {
      this.backspaceAmount()
      return
    }
    if ((key >= '0' && key <= '9') || key === '.') {
      this.inputAmountKey(key)
    }
  }

  private inputOperator(operator: string) {
    if (this.amountText === '0.00') {
      this.amountText = '0'
    }

    if (this.endsWithOperator(this.amountText)) {
      this.amountText = this.amountText.substring(0, this.amountText.length - 1) + operator
    } else {
      this.amountText += operator
    }
    this.justCalculated = false
  }

  private calculateResult() {
    if (!this.hasOperator(this.amountText)) {
      return
    }

    if (this.endsWithOperator(this.amountText)) {
      this.showToast('请输入完整算式')
      return
    }

    const tokens = this.expressionTokens(this.amountText)
    if (tokens.length === 0) {
      return
    }

    const numbers: number[] = [Number(tokens[0])]
    const operators: string[] = []
    for (let index = 1; index < tokens.length; index += 2) {
      const operator = tokens[index]
      const right = Number(tokens[index + 1])

      if (operator === '×') {
        numbers[numbers.length - 1] = numbers[numbers.length - 1] * right
      } else if (operator === '÷') {
        if (right === 0) {
          this.showToast('除数不能为 0')
          return
        }
        numbers[numbers.length - 1] = numbers[numbers.length - 1] / right
      } else {
        operators.push(operator)
        numbers.push(right)
      }
    }

    let result = numbers[0]
    for (let index = 0; index < operators.length; index++) {
      if (operators[index] === '+') {
        result += numbers[index + 1]
      } else if (operators[index] === '-') {
        result -= numbers[index + 1]
      }
    }

    this.amountText = this.formatAmount(result)
    this.justCalculated = true
  }

  private inputAmountKey(key: string) {
    let nextText = this.amountText

    if (this.justCalculated) {
      nextText = key === '.' ? '0.' : key
      this.justCalculated = false
    } else if (this.amountText === '0.00') {
      nextText = key === '.' ? '0.' : key
    } else if (this.endsWithOperator(this.amountText)) {
      nextText = this.amountText + (key === '.' ? '0.' : key)
    } else if (key === '.') {
      if (this.currentOperand(this.amountText).indexOf('.') >= 0) {
        this.showToast('金额只能输入一个小数点')
        return
      }
      nextText = this.amountText + '.'
    } else {
      if (!this.canAppendDecimalDigit(this.amountText)) {
        this.showToast('金额最多只能输入两位小数')
        return
      }
      nextText = this.amountText + key
    }

    if (!this.isValidMoneyInput(nextText)) {
      this.showToast('金额最多只能输入两位小数')
      return
    }
    this.amountText = nextText
  }

  private backspaceAmount() {
    if (this.amountText.length <= 1 || this.amountText === '0.00') {
      this.amountText = '0.00'
      this.justCalculated = false
      return
    }

    const nextText = this.amountText.substring(0, this.amountText.length - 1)
    this.amountText = nextText.length === 0 || nextText === '0.' ? '0.00' : nextText
    this.justCalculated = false
  }

  private clearCalculator() {
    this.amountText = '0.00'
    this.justCalculated = false
  }

  private canAppendDecimalDigit(currentText: string): boolean {
    const operand = this.currentOperand(currentText)
    const dotIndex = operand.indexOf('.')
    if (dotIndex < 0) {
      return true
    }
    return operand.length - dotIndex - 1 < 2
  }

  private isValidMoneyInput(text: string): boolean {
    const operand = this.currentOperand(text)
    const dotIndex = operand.indexOf('.')
    if (dotIndex < 0) {
      return true
    }
    return operand.length - dotIndex - 1 <= 2
  }

  private isZeroAmount(text: string): boolean {
    if (this.hasOperator(text)) {
      return false
    }
    const amount = Number(text)
    return amount === 0 || amount !== amount
  }

  private hasOperator(text: string): boolean {
    return text.indexOf('+') >= 0 || text.indexOf('-') >= 0 || text.indexOf('×') >= 0 || text.indexOf('÷') >= 0
  }

  private endsWithOperator(text: string): boolean {
    if (text.length === 0) {
      return false
    }
    const last = text.substring(text.length - 1)
    return last === '+' || last === '-' || last === '×' || last === '÷'
  }

  private currentOperand(text: string): string {
    let lastOperatorIndex = -1
    for (let index = 0; index < text.length; index++) {
      const char = text.substring(index, index + 1)
      if (char === '+' || char === '-' || char === '×' || char === '÷') {
        lastOperatorIndex = index
      }
    }
    return text.substring(lastOperatorIndex + 1)
  }

  private expressionTokens(text: string): string[] {
    const tokens: string[] = []
    let current = ''
    for (let index = 0; index < text.length; index++) {
      const char = text.substring(index, index + 1)
      if (char === '+' || char === '-' || char === '×' || char === '÷') {
        if (current.length === 0) {
          return []
        }
        tokens.push(current)
        tokens.push(char)
        current = ''
      } else {
        current += char
      }
    }

    if (current.length > 0) {
      tokens.push(current)
    }
    return tokens
  }

  private formatAmount(amount: number): string {
    const fixed = Math.round(amount * 100) / 100
    return fixed.toFixed(2)
  }

  private showToast(message: string) {
    this.toastMessage = message
    this.toastVisible = true
    if (this.toastTimer >= 0) {
      clearTimeout(this.toastTimer)
    }
    this.toastTimer = setTimeout(() => {
      this.toastVisible = false
    }, 1600)
  }

  @Builder
  private dateSheet() {
    Column() {
      Column({ space: 14 }) {
        Row({ space: 6 }) {
          Text((this.selectedMonth + 1).toString() + '月')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111111')
          Text(this.selectedYear.toString())
            .fontSize(10)
            .fontColor('#777777')
            .margin({ top: 8 })
          Blank()
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

        GridRow({ columns: 7, gutter: 2 }) {
          ForEach(this.calendarCells(), (cell: CalendarDayCell, index: number) => {
            GridCol() {
              this.calendarDay(cell)
            }
          }, (_cell: CalendarDayCell, index: number) => index.toString())
        }

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
          this.timeText((this.selectedHour + 23) % 24, false)
          this.timeText(this.selectedHour, true)
          Text(':')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111111')
            .margin({ left: 16, right: 16 })
          this.timeText((this.selectedMinute + 59) % 60, false)
          this.timeText(this.selectedMinute, true)
          Blank()
        }
        .width('100%')
        .height(68)

        Row() {
          Text('取消')
            .fontSize(15)
            .fontColor('#888888')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.showDateSheet = false
            })
          Text('确定')
            .fontSize(15)
            .fontColor('#55B8A7')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.showDateSheet = false
            })
        }
        .width('100%')
        .height(42)
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 18, bottom: 14 })
      .backgroundColor('#FFFFFF')
      .borderRadius({ topLeft: 8, topRight: 8 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.End)
  }

  @Builder
  private calendarDay(cell: CalendarDayCell) {
    Column({ space: 2 }) {
      Text(cell.day > 0 ? cell.day.toString() : '')
        .fontSize(14)
        .fontColor(cell.selected ? '#FFFFFF' : (cell.day > 0 ? '#111111' : '#AAAAAA'))
        .fontWeight(cell.selected ? FontWeight.Bold : FontWeight.Regular)
        .textAlign(TextAlign.Center)
      Text(cell.lunar)
        .fontSize(9)
        .fontColor(cell.selected ? '#FFFFFF' : '#999999')
        .textAlign(TextAlign.Center)
    }
    .width(44)
    .height(44)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(cell.selected ? '#55B8A7' : '#FFFFFF')
    .borderRadius(22)
    .onClick(() => {
      if (cell.day > 0) {
        this.selectedDay = cell.day
      }
    })
  }

  @Builder
  private timeText(value: number, active: boolean) {
    Text(value < 10 ? '0' + value.toString() : value.toString())
      .fontSize(active ? 22 : 15)
      .fontColor(active ? '#111111' : '#C8C8C8')
      .width(44)
      .textAlign(TextAlign.Center)
  }

  @Builder
  private assetSheet() {
    Column() {
      Column() {
        Row() {
          Column({ space: 4 }) {
            Text('选择账户')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#111111')
            Text('长按拖动可进行排序')
              .fontSize(12)
              .fontColor('#9A9A9A')
          }
          .alignItems(HorizontalAlign.Start)
          Blank()
          Text('组合支付')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#55B8A7')
          Text('≡')
            .fontSize(24)
            .fontColor('#111111')
            .margin({ left: 18 })
          Text('+')
            .fontSize(27)
            .fontColor('#111111')
            .margin({ left: 16 })
        }
        .width('100%')
        .height(52)
        .padding({ left: 16, right: 16 })

        Scroll() {
          Column() {
            ForEach(this.assets, (asset: AssetAccount) => {
              this.assetSelectRow(asset)
            }, (asset: AssetAccount) => asset.id)

            Row() {
              Text('无')
                .fontSize(13)
                .fontColor('#111111')
                .textAlign(TextAlign.Center)
                .width(22)
                .height(22)
                .borderRadius(11)
                .backgroundColor('#F2F2F2')
              Text('无账户')
                .fontSize(15)
                .fontColor('#111111')
                .margin({ left: 12 })
              Blank()
            }
            .width('100%')
            .height(50)
            .padding({ left: 16, right: 16 })
            .onClick(() => {
              this.selectedAssetId = ''
              this.selectedAssetName = '无账户'
              this.showAssetSheet = false
            })
          }
          .width('100%')
        }
        .height(430)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius({ topLeft: 8, topRight: 8 })
      .padding({ top: 8, bottom: 10 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.End)
  }

  @Builder
  private assetSelectRow(asset: AssetAccount) {
    Row() {
      Text(asset.icon.length > 0 ? asset.icon : '账')
        .fontSize(12)
        .fontColor('#FFFFFF')
        .textAlign(TextAlign.Center)
        .width(22)
        .height(22)
        .padding({ top: 4 })
        .borderRadius(11)
        .backgroundColor(asset.color)

      Column({ space: 3 }) {
        Text(this.assetDisplayName(asset))
          .fontSize(15)
          .fontColor('#111111')
          .maxLines(1)
        if (asset.remark !== undefined && asset.remark.length > 0) {
          Text(asset.remark)
            .fontSize(12)
            .fontColor('#777777')
            .maxLines(1)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })

      Blank()

      Text(this.formatAmount(asset.balance))
        .fontSize(14)
        .fontColor(asset.balance > 0 ? '#55B8A7' : (asset.balance < 0 ? '#D95F6A' : '#222222'))
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.selectedAssetId === asset.id ? '#F2FBF8' : '#FFFFFF')
    .onClick(() => {
      this.selectedAssetId = asset.id
      this.selectedAssetName = asset.shortName.length > 0 ? asset.shortName : asset.name
      this.showAssetSheet = false
    })
  }

  private closeSheets() {
    this.showDateSheet = false
    this.showAssetSheet = false
  }

  private loadAssets() {
    AssetAccountStore.load(getContext(this))
      .then((assets: AssetAccount[]) => {
        this.assets = assets
        if (assets.length > 0 && this.selectedAssetId.length === 0 && this.selectedAssetName === '无账户') {
          this.selectedAssetId = assets[0].id
          this.selectedAssetName = assets[0].shortName.length > 0 ? assets[0].shortName : assets[0].name
        }
      })
      .catch(() => {
        this.showToast('账户读取失败')
      })
  }

  private dateLabel(): string {
    const now = new Date()
    if (this.selectedYear === now.getFullYear() && this.selectedMonth === now.getMonth() && this.selectedDay === now.getDate()) {
      return '今天'
    }
    return (this.selectedMonth + 1).toString() + '月' + this.selectedDay.toString() + '日'
  }

  private calendarCells(): CalendarDayCell[] {
    const cells: CalendarDayCell[] = []
    const firstDay = new Date(this.selectedYear, this.selectedMonth, 1).getDay()
    const daysInMonth = new Date(this.selectedYear, this.selectedMonth + 1, 0).getDate()

    for (let index = 0; index < firstDay; index++) {
      cells.push({ day: 0, lunar: '', selected: false })
    }

    for (let day = 1; day <= daysInMonth; day++) {
      cells.push({
        day: day,
        lunar: this.lunarText(day),
        selected: day === this.selectedDay
      })
    }

    while (cells.length < 42) {
      cells.push({ day: 0, lunar: '', selected: false })
    }
    return cells
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

  private assetDisplayName(asset: AssetAccount): string {
    if (asset.shortName.length > 0) {
      return asset.name + '(' + asset.shortName + ')'
    }
    return asset.name
  }
}

@Component
struct BillCategoryCell {
  @Prop category: BillCategoryOption = { icon: '', title: '' }
  @Prop selected: boolean = false
  onSelect: () => void = () => {}

  build() {
    Column({ space: 5 }) {
      Text(this.category.icon)
        .fontSize(this.category.icon.length > 1 ? 13 : 15)
        .fontColor(this.selected ? '#55B8A7' : '#3B4A48')
        .textAlign(TextAlign.Center)
        .width(44)
        .height(44)
        .padding({ top: this.category.icon.length > 1 ? 13 : 12 })
        .backgroundColor(this.selected ? '#BFE9DE' : '#F5F5F5')
        .borderRadius(22)

      Text(this.category.title)
        .fontSize(13)
        .fontColor(this.selected ? '#55B8A7' : '#111111')
        .maxLines(1)
    }
    .width('100%')
    .height(76)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.onSelect()
    })
  }
}
