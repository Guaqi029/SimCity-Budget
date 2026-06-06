import { TopMessageToast } from '../components/TopMessageToast'
import { AssetAccount } from '../model/AssetAccount'
import { AssetAccountStore } from '../storage/AssetAccountStore'
import { BillDraftPreferenceStore } from '../storage/BillDraftPreferenceStore'
import { BillRecord, BillType } from '../model/BillRecord'
import { BillRecordStore } from '../storage/BillRecordStore'
import { BillDatePicker, BillDatePickerValue } from '../components/bill/BillDatePicker'
import { AssetAccountPicker } from '../components/bill/AssetAccountPicker'
import { BillCategory } from '../model/BillCategory'
import { BillCategoryStore } from '../storage/BillCategoryStore'
import { iconResourceById } from '../components/icon/IconLibraryConfig'
import { BillCategoryManagerDialog } from '../components/bill/BillCategoryManagerDialog'

type AddBillMode = 'expense' | 'income' | 'transfer'
type AssetPickerTarget = 'normal' | 'transferFrom' | 'transferTo'
type BottomSheetType = 'asset' | 'transferFee'

const NO_ASSET_ID: string = '__none__'

@Component
export struct AddBillPage {
  @State private mode: AddBillMode = 'expense'
  @State private selectedCategoryIndex: number = 0
  @State private categories: BillCategory[] = []
  @State private amountText: string = '0.00'
  @State private justCalculated: boolean = false
  @State private remark: string = ''
  @State private tagInputMode: boolean = false
  @State private tagDraftText: string = ''
  @State private tags: string[] = []
  @State private toastVisible: boolean = false
  @State private toastMessage: string = ''
  @State private showDateSheet: boolean = false
  @State private showBottomSheet: boolean = false
  @State private activeBottomSheet: BottomSheetType = 'asset'
  @State private assets: AssetAccount[] = []
  @State private selectedAssetId: string = ''
  @State private selectedAssetName: string = '无账户'
  @State private transferFromAssetId: string = ''
  @State private transferFromAssetName: string = '请选择转出账户'
  @State private transferToAssetId: string = ''
  @State private transferToAssetName: string = '请选择转入账户'
  @State private transferFeeAmount: number = 0
  @State private transferFeeDraftText: string = ''
  @State private assetPickerTarget: AssetPickerTarget = 'normal'
  @State private selectedAssetVersion: number = 0
  @State private selectedYear: number = new Date().getFullYear()
  @State private selectedMonth: number = new Date().getMonth()
  @State private selectedDay: number = new Date().getDate()
  @State private selectedHour: number = new Date().getHours()
  @State private selectedMinute: number = new Date().getMinutes()
  @State private dateDisplayLabel: string = '今天'
  @State private dateDisplayVersion: number = 0
  initialMode: AddBillMode = 'expense'
  initialAssetId: string = ''
  initialAssetName: string = ''
  onBack: () => void = () => {}
  onSaved: () => void = () => {}
  private toastTimer: number = -1
  private categoryManagerController: CustomDialogController = new CustomDialogController({
    builder: BillCategoryManagerDialog({
      onChanged: () => {
        this.loadCategories()
      }
    }),
    alignment: DialogAlignment.Center,
    customStyle: true,
    autoCancel: true
  })

  aboutToAppear() {
    this.applyInitialParams()
    this.loadAssets()
    this.loadCategories()
    this.refreshDateDisplayLabel()
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        this.header()
        if (this.mode === 'transfer') {
          this.transferAssetPanel()
        } else {
          this.categoryGrid()
        }
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

      if (this.showDateSheet) {
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

    }
    .width('100%')
    .height('100%')
    .bindSheet($$this.showBottomSheet, this.bottomSheetContent(), {
      height: this.bottomSheetHeight(),
      backgroundColor: '#FFFFFF',
      preferType: SheetType.BOTTOM,
      showClose: false,
      maskColor: '#66000000'
    })
  }

  @Builder
  private bottomSheetContent() {
    if (this.activeBottomSheet === 'transferFee') {
      this.transferFeeSheet()
    } else {
      this.assetPickerSheet()
    }
  }

  @Builder
  private assetPickerSheet() {
    AssetAccountPicker({
      assets: this.assets,
      selectedAssetId: this.sheetSelectedAssetId(),
      allowNoAccount: this.assetPickerTarget === 'normal',
      onSelect: (asset: AssetAccount | undefined) => {
        this.selectAsset(asset)
      }
    })
  }

  @Builder
  private transferFeeSheet() {
    Column({ space: 14 }) {
      Row() {
        Text('手续费')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111111')
        Blank()
        Text('保存')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#55B8A7')
          .onClick(() => {
            this.confirmTransferFee()
          })
      }
      .width('100%')
      .height(32)

      TextInput({ placeholder: '手续费只从转出账户扣除，最多两位小数', text: this.transferFeeDraftText })
        .type(InputType.Normal)
        .fontSize(22)
        .fontColor('#111111')
        .placeholderColor('#AAAAAA')
        .backgroundColor('#F5F6F7')
        .height(52)
        .borderRadius(8)
        .padding({ left: 12, right: 12 })
        .defaultFocus(true)
        .onChange((value: string) => {
          this.updateTransferFeeDraft(value)
        })
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 12, bottom: 18 })
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
      if (mode === 'transfer') {
        this.ensureTransferAssets()
      }
    })
  }

  @Builder
  private categoryGrid() {
    GridRow({ columns: 5, gutter: 4 }) {
      ForEach(this.currentCategories(), (category: BillCategory, index: number) => {
        GridCol() {
          BillCategoryCell({
            category: category,
            selected: this.selectedCategoryIndex === index,
            onSelect: () => {
              this.selectedCategoryIndex = index
            }
          })
        }
      }, (category: BillCategory, index: number) => category.id + index.toString())

      GridCol() {
        BillCategoryManageCell({
          onSelect: () => {
            this.categoryManagerController.open()
          }
        })
      }
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 8 })
  }

  @Builder
  private transferAssetPanel() {
    Column({ space: 10 }) {
      ForEach([this.selectedAssetVersion], () => {
        Row({ space: 10 }) {
          this.transferAssetCard('转出账户', true)
          this.transferAssetCard('转入账户', false)
        }
        .width('100%')
      }, (version: number) => version.toString())

      Row({ space: 8 }) {
        Text('类型')
          .fontSize(12)
          .fontColor('#9A9A9A')
        Text('转账')
          .fontSize(13)
          .fontColor('#55B8A7')
      }
      .width('100%')
      .padding({ left: 4 })
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 10 })
  }

  @Builder
  private transferAssetCard(title: string, isFrom: boolean) {
    Column({ space: 7 }) {
      Text(title)
        .fontSize(12)
        .fontColor('#888888')
        .width('100%')

      Row() {
        Text(isFrom ? '出' : '入')
          .fontSize(12)
          .fontColor('#FFFFFF')
          .textAlign(TextAlign.Center)
          .width(24)
          .height(24)
          .padding({ top: 4 })
          .backgroundColor(isFrom ? '#E07178' : '#55B8A7')
          .borderRadius(12)

        Text(this.transferAssetDisplayName(isFrom))
          .fontSize(15)
          .fontColor('#111111')
          .maxLines(1)
          .margin({ left: 9 })
          .layoutWeight(1)
      }
      .width('100%')
    }
    .layoutWeight(1)
    .height(76)
    .padding({ left: 12, right: 12, top: 10 })
    .backgroundColor('#F7F8F8')
    .borderRadius(10)
    .onClick(() => {
      this.assetPickerTarget = isFrom ? 'transferFrom' : 'transferTo'
      this.openAssetSheet()
    })
  }

  @Builder
  private amountPanel() {
    Column() {
      Column()
        .width('100%')
        .height(1)
        .backgroundColor('#ECECEC')

      if (this.tags.length > 0) {
        this.tagListRow()
      }

      Row() {
        this.tagModeButton()

        if (this.tagInputMode) {
          TextInput({ placeholder: '输入标签，空格确认', text: this.tagDraftText })
            .fontSize(16)
            .fontColor('#111111')
            .placeholderColor('#9A9A9A')
            .backgroundColor('#00000000')
            .height(40)
            .padding({ left: 0, right: 0 })
            .margin({ left: 18 })
            .layoutWeight(1)
            .onChange((value: string) => {
              this.handleTagInput(value)
            })
        } else {
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
        }

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
    .height(this.amountPanelHeight())
  }

  @Builder
  private tagModeButton() {
    Row({ space: 4 }) {
      Text('◇')
        .fontSize(16)
        .fontColor(this.tagInputMode ? '#FFFFFF' : '#111111')
      Text('标签')
        .fontSize(13)
        .fontColor(this.tagInputMode ? '#FFFFFF' : '#111111')
    }
    .height(30)
    .padding({ left: 8, right: 8, top: 5 })
    .backgroundColor(this.tagInputMode ? '#55B8A7' : '#F2F4F5')
    .borderRadius(15)
    .onClick(() => {
      this.tagInputMode = !this.tagInputMode
    })
  }

  @Builder
  private tagListRow() {
    Scroll() {
      Row({ space: 6 }) {
        ForEach(this.tags, (tag: string, index: number) => {
          Text(tag)
            .fontSize(11)
            .fontColor('#3E6F66')
            .maxLines(1)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor('#E6F5F1')
            .borderRadius(10)
            .onClick(() => {
              this.removeTagAt(index)
            })
        }, (tag: string, index: number) => tag + index.toString())
      }
      .height(28)
      .padding({ left: 18, right: 18, top: 6 })
    }
    .width('100%')
    .height(34)
    .scrollBar(BarState.Off)
  }

  @Builder
  private metaBar() {
    Column() {
      Row({ space: 18 }) {
        ForEach([this.dateDisplayVersion], () => {
          this.dateMetaItem()
        }, (version: number) => version.toString())
        if (this.mode !== 'transfer') {
          ForEach([this.selectedAssetVersion], () => {
            this.assetMetaItem()
          }, (version: number) => version.toString())
        } else {
          this.transferFeeMetaItem()
        }
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
      this.assetPickerTarget = 'normal'
      this.openAssetSheet()
    })
  }

  @Builder
  private transferFeeMetaItem() {
    Row({ space: 5 }) {
      Text('费')
        .fontSize(15)
        .fontColor('#111111')
      Text(this.transferFeeMetaText())
        .fontSize(16)
        .fontColor(this.transferFeeAmount > 0 ? '#E07178' : '#111111')
        .maxLines(1)
    }
    .onClick(() => {
      this.transferFeeDraftText = this.transferFeeAmount > 0 ? this.formatAmount(this.transferFeeAmount) : ''
      this.openTransferFeeSheet()
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

  private currentCategories(): BillCategory[] {
    return BillCategoryStore.activeByType(this.categories, this.currentBillType())
  }

  private amountPanelHeight(): number {
    return this.tags.length > 0 ? 98 : 64
  }

  private handleTagInput(value: string) {
    if (value.indexOf(' ') >= 0 || value.indexOf('　') >= 0) {
      let normalized = value
      while (normalized.indexOf('　') >= 0) {
        normalized = normalized.replace('　', ' ')
      }
      const parts = normalized.split(' ')
      for (let index = 0; index < parts.length; index++) {
        this.addTag(parts[index])
      }
      this.tagDraftText = ''
      return
    }
    this.tagDraftText = value
  }

  private commitTagDraft() {
    if (this.tagDraftText.trim().length > 0) {
      this.addTag(this.tagDraftText)
      this.tagDraftText = ''
    }
  }

  private addTag(value: string) {
    const tag = value.trim()
    if (tag.length === 0 || this.hasTag(tag)) {
      return
    }
    this.tags = this.tags.concat([tag])
  }

  private hasTag(tag: string): boolean {
    for (let index = 0; index < this.tags.length; index++) {
      if (this.tags[index] === tag) {
        return true
      }
    }
    return false
  }

  private removeTagAt(removeIndex: number) {
    const nextTags: string[] = []
    for (let index = 0; index < this.tags.length; index++) {
      if (index !== removeIndex) {
        nextTags.push(this.tags[index])
      }
    }
    this.tags = nextTags
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
    if (this.mode === 'transfer' && !this.validateTransferAssets()) {
      return
    }

    const now = new Date().toISOString()
    const billDate = this.selectedDateIsoString()
    const category = this.selectedCategory()
    this.commitTagDraft()
    const record: BillRecord = {
      id: 'bill_' + now,
      amount: amount,
      type: this.currentBillType(),
      assetId: this.mode === 'transfer' ? '' : this.selectedAssetId,
      assetName: this.mode === 'transfer' ? '' : this.selectedAssetName,
      fromAssetId: this.mode === 'transfer' ? this.transferFromAssetId : '',
      fromAssetName: this.mode === 'transfer' ? this.transferFromAssetName : '',
      toAssetId: this.mode === 'transfer' ? this.transferToAssetId : '',
      toAssetName: this.mode === 'transfer' ? this.transferToAssetName : '',
      transferFee: this.mode === 'transfer' ? this.transferFeeAmount : 0,
      category: category,
      categoryId: category.id,
      categoryName: category.name,
      billDate: billDate,
      month: this.monthKey(this.selectedYear, this.selectedMonth),
      remark: this.remark.trim(),
      tags: this.tags.concat([]),
      createTime: now,
      updateTime: now,
      isDeleted: false
    }

    BillRecordStore.add(getContext(this), record)
      .then(() => {
        return this.updateAssetBalanceAfterSave(amount)
      })
      .then(() => {
        this.onSaved()
        this.onBack()
      })
      .catch(() => {
        this.showToast('账单保存失败')
      })
  }

  private updateAssetBalanceAfterSave(amount: number): Promise<void> {
    if (this.mode === 'transfer') {
      return this.updateTransferAssetBalance(amount)
    }
    return this.updateSelectedAssetBalance(amount)
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
        nextAssets.push(this.copyAssetWithBalance(asset, this.roundMoney(nextBalance)))
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

  private updateTransferAssetBalance(amount: number): Promise<void> {
    const nextAssets: AssetAccount[] = []
    let changed = false
    for (let index = 0; index < this.assets.length; index++) {
      const asset = this.assets[index]
      if (asset.id === this.transferFromAssetId) {
        nextAssets.push(this.copyAssetWithBalance(asset, this.roundMoney(asset.balance - amount - this.transferFeeAmount)))
        changed = true
      } else if (asset.id === this.transferToAssetId) {
        nextAssets.push(this.copyAssetWithBalance(asset, this.roundMoney(asset.balance + amount)))
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

  private copyAssetWithBalance(asset: AssetAccount, balance: number): AssetAccount {
    return {
      id: asset.id,
      type: asset.type,
      group: asset.group,
      name: asset.name,
      balance: balance,
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
    }
  }

  private roundMoney(value: number): number {
    return Math.round(value * 100) / 100
  }

  private validateTransferAssets(): boolean {
    if (this.transferFromAssetId.length === 0) {
      this.showToast('请选择转出账户')
      return false
    }
    if (this.transferToAssetId.length === 0) {
      this.showToast('请选择转入账户')
      return false
    }
    if (this.transferFromAssetId === this.transferToAssetId) {
      this.showToast('转出和转入账户不能相同')
      return false
    }
    return true
  }

  private updateTransferFeeDraft(value: string) {
    const normalized = this.normalizeMoneyInput(value)
    if (normalized !== value) {
      this.showToast('手续费最多只能输入两位小数')
    }
    this.transferFeeDraftText = normalized
  }

  private confirmTransferFee() {
    if (this.transferFeeDraftText.length === 0 || this.transferFeeDraftText === '.') {
      this.transferFeeAmount = 0
      this.transferFeeDraftText = ''
      this.closeBottomSheet()
      return
    }

    const fee = Number(this.transferFeeDraftText)
    if (fee !== fee || fee < 0) {
      this.showToast('请输入有效手续费')
      return
    }
    this.transferFeeAmount = this.roundMoney(fee)
    this.transferFeeDraftText = this.formatAmount(this.transferFeeAmount)
    this.closeBottomSheet()
  }

  private normalizeMoneyInput(value: string): string {
    let result = ''
    let hasDot = false
    let decimalCount = 0
    for (let index = 0; index < value.length; index++) {
      const char = value.substring(index, index + 1)
      if (char >= '0' && char <= '9') {
        if (hasDot) {
          if (decimalCount >= 2) {
            continue
          }
          decimalCount += 1
        }
        result += char
      } else if (char === '.' && !hasDot) {
        hasDot = true
        result += char
      }
    }
    if (result.length > 1 && result.substring(0, 1) === '0' && result.substring(1, 2) !== '.') {
      while (result.length > 1 && result.substring(0, 1) === '0' && result.substring(1, 2) !== '.') {
        result = result.substring(1)
      }
    }
    return result
  }

  private transferFeeMetaText(): string {
    if (this.transferFeeAmount <= 0) {
      return '手续费'
    }
    return '手续费 ' + this.formatAmount(this.transferFeeAmount)
  }

  private selectedCategory(): BillCategory {
    if (this.mode === 'transfer') {
      return this.transferCategory()
    }
    const categories = this.currentCategories()
    if (this.selectedCategoryIndex < 0 || this.selectedCategoryIndex >= categories.length) {
      return this.fallbackCategory()
    }
    return categories[this.selectedCategoryIndex]
  }

  private transferCategory(): BillCategory {
    const now = new Date().toISOString()
    return {
      id: 'transfer_account',
      name: '转账',
      type: 'transfer',
      iconId: 'wallet',
      createTime: now,
      updateTime: now,
      isSystem: true,
      isDeleted: false
    }
  }

  private fallbackCategory(): BillCategory {
    const now = new Date().toISOString()
    return {
      id: 'fallback_other_' + this.currentBillType(),
      name: '其他',
      type: this.currentBillType(),
      iconId: 'icon_other',
      createTime: now,
      updateTime: now,
      isSystem: true,
      isDeleted: false
    }
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
        this.ensureTransferAssets()
        this.loadLastAsset()
      })
      .catch(() => {
        this.showToast('账户读取失败')
      })
  }

  private loadCategories() {
    BillCategoryStore.load(getContext(this))
      .then((categories: BillCategory[]) => {
        this.categories = categories
      })
      .catch(() => {
        this.categories = []
      })
  }

  private loadLastAsset() {
    if (this.initialAssetId.length > 0 && this.mode !== 'transfer') {
      const initialAsset = this.findAsset(this.initialAssetId)
      if (initialAsset !== undefined) {
        this.applySelectedAsset(initialAsset)
      } else {
        this.selectedAssetId = this.initialAssetId
        this.selectedAssetName = this.initialAssetName.length > 0 ? this.initialAssetName : '无账户'
        this.selectedAssetVersion += 1
      }
      return
    }

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

  private applyInitialParams() {
    this.mode = this.initialMode
    if (this.initialAssetId.length === 0) {
      return
    }
    if (this.initialMode === 'transfer') {
      this.transferFromAssetId = this.initialAssetId
      this.transferFromAssetName = this.initialAssetName.length > 0 ? this.initialAssetName : '请选择转出账户'
      return
    }
    this.selectedAssetId = this.initialAssetId
    this.selectedAssetName = this.initialAssetName.length > 0 ? this.initialAssetName : '无账户'
    this.selectedAssetVersion += 1
  }

  private selectAsset(asset: AssetAccount | undefined) {
    if (this.assetPickerTarget === 'transferFrom') {
      this.applyTransferFromAsset(asset)
      this.closeBottomSheet()
      return
    }
    if (this.assetPickerTarget === 'transferTo') {
      this.applyTransferToAsset(asset)
      this.closeBottomSheet()
      return
    }

    this.applySelectedAsset(asset)
    BillDraftPreferenceStore.saveLastAssetId(getContext(this), asset === undefined ? NO_ASSET_ID : asset.id)
      .catch(() => {
        this.showToast('默认账户保存失败')
      })
    this.closeBottomSheet()
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

  private applyTransferFromAsset(asset: AssetAccount | undefined) {
    if (asset === undefined) {
      this.transferFromAssetId = ''
      this.transferFromAssetName = '请选择转出账户'
    } else {
      this.transferFromAssetId = asset.id
      this.transferFromAssetName = this.assetShortDisplayName(asset)
      if (this.transferToAssetId === asset.id) {
        this.applyTransferToAsset(this.firstDifferentAsset(asset.id))
      }
    }
    this.selectedAssetVersion += 1
  }

  private applyTransferToAsset(asset: AssetAccount | undefined) {
    if (asset === undefined) {
      this.transferToAssetId = ''
      this.transferToAssetName = '请选择转入账户'
    } else {
      this.transferToAssetId = asset.id
      this.transferToAssetName = this.assetShortDisplayName(asset)
      if (this.transferFromAssetId === asset.id) {
        this.applyTransferFromAsset(this.firstDifferentAsset(asset.id))
      }
    }
    this.selectedAssetVersion += 1
  }

  private ensureTransferAssets() {
    if (this.assets.length === 0) {
      this.applyTransferFromAsset(undefined)
      this.applyTransferToAsset(undefined)
      return
    }

    const fromAsset = this.findAsset(this.transferFromAssetId)
    if (fromAsset === undefined) {
      this.applyTransferFromAsset(this.assets[0])
    } else {
      this.applyTransferFromAsset(fromAsset)
    }

    const toAsset = this.findAsset(this.transferToAssetId)
    if (toAsset === undefined || toAsset.id === this.transferFromAssetId) {
      this.applyTransferToAsset(this.firstDifferentAsset(this.transferFromAssetId))
    } else {
      this.applyTransferToAsset(toAsset)
    }
  }

  private firstDifferentAsset(assetId: string): AssetAccount | undefined {
    for (let index = 0; index < this.assets.length; index++) {
      if (this.assets[index].id !== assetId) {
        return this.assets[index]
      }
    }
    return undefined
  }

  private sheetSelectedAssetId(): string {
    if (this.assetPickerTarget === 'transferFrom') {
      return this.transferFromAssetId
    }
    if (this.assetPickerTarget === 'transferTo') {
      return this.transferToAssetId
    }
    return this.selectedAssetId
  }

  private assetShortDisplayName(asset: AssetAccount): string {
    return asset.shortName.length > 0 ? asset.shortName : asset.name
  }

  private openAssetSheet() {
    this.activeBottomSheet = 'asset'
    this.showBottomSheet = true
  }

  private openTransferFeeSheet() {
    this.activeBottomSheet = 'transferFee'
    this.showBottomSheet = true
  }

  private closeBottomSheet() {
    this.showBottomSheet = false
  }

  private bottomSheetHeight(): number {
    if (this.activeBottomSheet === 'transferFee') {
      return 170
    }
    return 520
  }

  private transferAssetDisplayName(isFrom: boolean): string {
    if (isFrom) {
      return this.transferFromAssetName
    }
    return this.transferToAssetName
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
  @Prop category: BillCategory = {
    id: '',
    name: '',
    type: 'expense',
    iconId: 'icon_other',
    createTime: '',
    updateTime: '',
    isSystem: false,
    isDeleted: false
  }
  @Prop selected: boolean = false
  onSelect: () => void = () => {}

  build() {
    Column({ space: 5 }) {
      Stack({ alignContent: Alignment.Center }) {
        Image(iconResourceById(this.category.iconId))
          .width(22)
          .height(22)
          .objectFit(ImageFit.Contain)
      }
      .width(44)
      .height(44)
      .backgroundColor(this.selected ? '#BFE9DE' : '#F5F5F5')
      .borderRadius(22)

      Text(this.category.name)
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

@Component
struct BillCategoryManageCell {
  onSelect: () => void = () => {}

  build() {
    Column({ space: 5 }) {
      Stack({ alignContent: Alignment.Center }) {
        Text('+')
          .fontSize(25)
          .fontColor('#111111')
      }
      .width(44)
      .height(44)
      .backgroundColor('#F5F5F5')
      .borderRadius(22)

      Text('编辑')
        .fontSize(13)
        .fontColor('#111111')
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
