import { TopMessageToast } from '../components/TopMessageToast'
import { AssetAccount } from '../model/AssetAccount'
import { AssetAccountStore } from '../storage/AssetAccountStore'
import { BillDraftPreferenceStore } from '../storage/BillDraftPreferenceStore'
import { BillRecord, BillType } from '../model/BillRecord'
import { BillRecordStore } from '../storage/BillRecordStore'
import { BillDatePicker, BillDatePickerValue } from '../components/bill/BillDatePicker'
import { AssetAccountPicker } from '../components/bill/AssetAccountPicker'

type AddBillMode = 'expense' | 'income' | 'transfer'

const NO_ASSET_ID: string = '__none__'

interface BillCategoryOption {
  icon: string
  title: string
}

const EXPENSE_CATEGORIES: BillCategoryOption[] = [
  { icon: '餐', title: '餐饮' },
  { icon: '购', title: '购物' },
  { icon: '行', title: '交通' },
  { icon: '居', title: '居家' },
  { icon: '娱', title: '娱乐' },
  { icon: '医', title: '医疗' },
  { icon: '学', title: '学习' },
  { icon: '旅', title: '旅行' },
  { icon: '人', title: '人情' },
  { icon: '宠', title: '宠物' },
  { icon: '通', title: '通讯' },
  { icon: '服', title: '服饰' },
  { icon: '运', title: '运动' },
  { icon: '捐', title: '公益' },
  { icon: '其', title: '其他' }
]

const INCOME_CATEGORIES: BillCategoryOption[] = [
  { icon: '资', title: '工资' },
  { icon: '兼', title: '兼职' },
  { icon: '奖', title: '奖金' },
  { icon: '理', title: '理财' },
  { icon: '息', title: '利息' },
  { icon: '租', title: '租金' },
  { icon: '礼', title: '礼金' },
  { icon: '退', title: '退款' },
  { icon: '报', title: '报销' },
  { icon: '补', title: '补贴' },
  { icon: '闲', title: '闲置' },
  { icon: '借', title: '借入' },
  { icon: '生', title: '生活费' },
  { icon: '其', title: '其他' }
]

const TRANSFER_CATEGORIES: BillCategoryOption[] = [
  { icon: '转', title: '账户转账' },
  { icon: '卡', title: '还信用卡' },
  { icon: '提', title: '提现' },
  { icon: '充', title: '充值' },
  { icon: '换', title: '换卡' },
  { icon: '投', title: '投资转入' },
  { icon: '赎', title: '投资转出' },
  { icon: '借', title: '借款转入' },
  { icon: '还', title: '还款转出' },
  { icon: '调', title: '内部调拨' },
  { icon: '其', title: '其他转账' }
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
  @State private selectedAssetVersion: number = 0
  @State private selectedYear: number = new Date().getFullYear()
  @State private selectedMonth: number = new Date().getMonth()
  @State private selectedDay: number = new Date().getDate()
  @State private selectedHour: number = new Date().getHours()
  @State private selectedMinute: number = new Date().getMinutes()
  @State private dateDisplayLabel: string = '今天'
  @State private dateDisplayVersion: number = 0
  onBack: () => void = () => {}
  onSaved: () => void = () => {}
  private toastTimer: number = -1

  aboutToAppear() {
    this.loadAssets()
    this.refreshDateDisplayLabel()
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
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
      .align(Alignment.Top)

      if (this.showDateSheet || this.showAssetSheet) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#000000')
          .opacity(0.52)
          .onClick(() => {
            if (this.showDateSheet) {
              this.showDateSheet = false
            }
          })
      }

      if (this.showDateSheet) {
        BillDatePicker({
          year: this.selectedYear,
          month: this.selectedMonth,
          day: this.selectedDay,
          hour: this.selectedHour,
          minute: this.selectedMinute,
          onCancel: () => {
            this.showDateSheet = false
          },
          onConfirm: (value: BillDatePickerValue) => {
            this.selectedYear = value.year
            this.selectedMonth = value.month
            this.selectedDay = value.day
            this.selectedHour = value.hour
            this.selectedMinute = value.minute
            this.refreshDateDisplayLabel()
            this.showDateSheet = false
          }
        })
        .align(Alignment.Center)
        .onClick(() => {})
      }

      if (this.showAssetSheet) {
        AssetAccountPicker({
          assets: this.assets,
          selectedAssetId: this.selectedAssetId,
          onSelect: (asset: AssetAccount | undefined) => {
            this.selectAsset(asset)
          }
        })
        .onClick(() => {})
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

        TextInput({ placeholder: '添加备注', text: this.remark })
          .fontSize(16)
          .fontColor('#111111')
          .placeholderColor('#9A9A9A')
          .backgroundColor('#00000000')
          .height(40)
          .padding({ left: 0, right: 0 })
          .margin({ left: 18 })
          .layoutWeight(1)
          .onChange((value: string) => {
            this.remark = value
          })

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
        ForEach([this.dateDisplayVersion], () => {
          this.dateMetaItem()
        }, (version: number) => version.toString())
        ForEach([this.selectedAssetVersion], () => {
          this.assetMetaItem()
        }, (version: number) => version.toString())
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
  private dateMetaItem() {
    Row({ space: 5 }) {
      Image($r('app.media.calendar'))
        .width(17)
        .height(17)
        .objectFit(ImageFit.Contain)
      // 直接读取 @State，避免通过 Builder 参数传入后文案不刷新。
      Text(this.dateDisplayLabel)
        .fontSize(16)
        .fontColor('#111111')
        .maxLines(1)
    }
    .onClick(() => {
      this.showDateSheet = true
    })
  }

  @Builder
  private assetMetaItem() {
    Row({ space: 5 }) {
      Text('￥')
        .fontSize(15)
        .fontColor('#111111')
      // 直接读取 @State，并配合 selectedAssetVersion 强制重建，避免选择后显示旧账户。
      Text(this.selectedAssetName)
        .fontSize(16)
        .fontColor('#111111')
        .maxLines(1)
    }
    .onClick(() => {
      this.showAssetSheet = true
    })
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
    if (this.mode === 'transfer') {
      return TRANSFER_CATEGORIES
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
      this.saveBill()
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

  private saveBill() {
    const amount = Number(this.amountText)
    if (amount !== amount || amount <= 0) {
      this.showToast('请输入有效金额')
      return
    }

    const now = new Date().toISOString()
    const billDate = this.selectedDateIsoString()
    const category = this.selectedCategory()
    const record: BillRecord = {
      id: 'bill_' + now,
      amount: amount,
      type: this.currentBillType(),
      assetId: this.mode === 'transfer' ? '' : this.selectedAssetId,
      assetName: this.mode === 'transfer' ? '' : this.selectedAssetName,
      fromAssetId: this.mode === 'transfer' ? this.selectedAssetId : '',
      fromAssetName: this.mode === 'transfer' ? this.selectedAssetName : '',
      toAssetId: '',
      toAssetName: '',
      transferFee: 0,
      categoryId: category.title,
      categoryName: category.title,
      billDate: billDate,
      month: this.monthKey(this.selectedYear, this.selectedMonth),
      remark: this.remark.trim(),
      createTime: now,
      updateTime: now,
      isDeleted: false
    }

    BillRecordStore.add(getContext(this), record)
      .then(() => {
        return this.updateSelectedAssetBalance(amount)
      })
      .then(() => {
        this.onSaved()
        this.onBack()
      })
      .catch(() => {
        this.showToast('账单保存失败')
      })
  }

  private updateSelectedAssetBalance(amount: number): Promise<void> {
    if (this.selectedAssetId.length === 0 || this.mode === 'transfer') {
      return Promise.resolve()
    }

    const nextAssets: AssetAccount[] = []
    let changed = false
    for (let index = 0; index < this.assets.length; index++) {
      const asset = this.assets[index]
      if (asset.id === this.selectedAssetId) {
        const nextBalance = this.mode === 'income' ? asset.balance + amount : asset.balance - amount
        nextAssets.push({
          id: asset.id,
          type: asset.type,
          group: asset.group,
          name: asset.name,
          balance: Math.round(nextBalance * 100) / 100,
          shortName: asset.shortName,
          icon: asset.icon,
          color: asset.color,
          cardNo: asset.cardNo,
          remark: asset.remark,
          includeInTotal: asset.includeInTotal,
          bookScope: asset.bookScope,
          createTime: asset.createTime,
          updateTime: new Date().toISOString(),
          isDeleted: asset.isDeleted
        })
        changed = true
      } else {
        nextAssets.push(asset)
      }
    }

    if (!changed) {
      return Promise.resolve()
    }
    return AssetAccountStore.save(getContext(this), nextAssets)
      .then(() => {
        this.assets = nextAssets
      })
  }

  private selectedCategory(): BillCategoryOption {
    const categories = this.currentCategories()
    if (this.selectedCategoryIndex < 0 || this.selectedCategoryIndex >= categories.length) {
      return categories[0]
    }
    return categories[this.selectedCategoryIndex]
  }

  private currentBillType(): BillType {
    if (this.mode === 'income') {
      return 'income'
    }
    if (this.mode === 'transfer') {
      return 'transfer'
    }
    return 'expense'
  }

  private selectedDateIsoString(): string {
    const date = new Date(this.selectedYear, this.selectedMonth, this.selectedDay, this.selectedHour, this.selectedMinute, 0)
    return date.toISOString()
  }

  private monthKey(year: number, month: number): string {
    const monthNumber = month + 1
    return year.toString() + '-' + (monthNumber < 10 ? '0' + monthNumber.toString() : monthNumber.toString())
  }

  private loadAssets() {
    AssetAccountStore.load(getContext(this))
      .then((assets: AssetAccount[]) => {
        this.assets = assets
        this.loadLastAsset()
      })
      .catch(() => {
        this.showToast('账户读取失败')
      })
  }

  private loadLastAsset() {
    BillDraftPreferenceStore.loadLastAssetId(getContext(this))
      .then((assetId: string) => {
        if (assetId === NO_ASSET_ID) {
          this.applySelectedAsset(undefined)
          return
        }
        const asset = this.findAsset(assetId)
        if (asset !== undefined) {
          this.applySelectedAsset(asset)
          return
        }
        if (this.assets.length > 0) {
          this.applySelectedAsset(this.assets[0])
          return
        }
        this.applySelectedAsset(undefined)
      })
      .catch(() => {
        if (this.assets.length > 0) {
          this.applySelectedAsset(this.assets[0])
        }
      })
  }

  private selectAsset(asset: AssetAccount | undefined) {
    this.applySelectedAsset(asset)
    BillDraftPreferenceStore.saveLastAssetId(getContext(this), asset === undefined ? NO_ASSET_ID : asset.id)
      .catch(() => {
        this.showToast('默认账户保存失败')
      })
    this.showAssetSheet = false
  }

  private applySelectedAsset(asset: AssetAccount | undefined) {
    if (asset === undefined) {
      this.selectedAssetId = ''
      this.selectedAssetName = '无账户'
    } else {
      this.selectedAssetId = asset.id
      this.selectedAssetName = asset.shortName.length > 0 ? asset.shortName : asset.name
    }
    this.selectedAssetVersion += 1
  }

  private findAsset(assetId: string): AssetAccount | undefined {
    if (assetId.length === 0) {
      return undefined
    }
    for (let index = 0; index < this.assets.length; index++) {
      if (this.assets[index].id === assetId) {
        return this.assets[index]
      }
    }
    return undefined
  }

  private dateLabel(): string {
    const now = new Date()
    if (this.selectedYear === now.getFullYear() && this.selectedMonth === now.getMonth() && this.selectedDay === now.getDate()) {
      return '今天'
    }

    const yesterday = new Date(now.getFullYear(), now.getMonth(), now.getDate() - 1)
    if (this.selectedYear === yesterday.getFullYear() && this.selectedMonth === yesterday.getMonth() && this.selectedDay === yesterday.getDate()) {
      return '昨天'
    }

    return (this.selectedMonth + 1).toString() + '月' + this.selectedDay.toString() + '日'
  }

  private refreshDateDisplayLabel() {
    this.dateDisplayLabel = this.dateLabel()
    this.dateDisplayVersion += 1
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
