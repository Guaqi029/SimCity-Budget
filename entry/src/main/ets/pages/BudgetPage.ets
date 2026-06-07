import { BillRecord } from '../model/BillRecord'
import { BillCategory } from '../model/BillCategory'
import { CategoryBudget, MonthlyBudget } from '../model/Budget'
import { BillCategoryStore } from '../storage/BillCategoryStore'
import { BillRecordStore } from '../storage/BillRecordStore'
import { BudgetStore } from '../storage/BudgetStore'
import { TopMessageToast } from '../components/TopMessageToast'
import { iconResourceById } from '../components/icon/IconLibraryConfig'

interface CategoryBudgetView {
  category: BillCategory
  amountText: string
  used: number
}

type BudgetSheetTarget = 'total' | 'category'

@Component
export struct BudgetPage {
  @State private month: string = ''
  @State private totalBudgetText: string = ''
  @State private categories: BillCategory[] = []
  @State private records: BillRecord[] = []
  @State private categoryViews: CategoryBudgetView[] = []
  @State private totalUsedAmount: number = 0
  @State private totalRemainingAmount: number = 0
  @State private toastVisible: boolean = false
  @State private toastMessage: string = ''
  @State private toastVersion: number = 0
  @State private showBudgetSheet: boolean = false
  @State private budgetSheetTarget: BudgetSheetTarget = 'total'
  @State private editingCategoryIndex: number = -1
  @State private amountDraftText: string = ''
  onBack: () => void = () => {}
  onChanged: () => void = () => {}

  aboutToAppear() {
    this.month = this.currentMonthKey()
    this.loadData()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        this.topBar()
        Scroll() {
          Column({ space: 14 }) {
            this.summaryCard()
            this.categoryBudgetCard()
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 14, bottom: 26 })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FFFFFF')

      TopMessageToast({
        visible: this.toastVisible,
        message: this.toastMessage
      })
      .margin({ top: 10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .bindSheet($$this.showBudgetSheet, this.budgetAmountSheet(), {
      height: 170,
      backgroundColor: '#FFFFFF',
      preferType: SheetType.BOTTOM,
      showClose: false,
      maskColor: '#66000000'
    })
  }

  @Builder
  private budgetAmountSheet() {
    Column({ space: 14 }) {
      Row() {
        Text(this.budgetSheetTitle())
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111111')
        Blank()
        Text('保存')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#55B8A7')
          .onClick(() => {
            this.confirmBudgetAmount()
          })
      }
      .width('100%')
      .height(32)

      TextInput({ placeholder: '请输入预算金额，最多两位小数', text: this.amountDraftText })
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
          this.amountDraftText = this.sanitizeMoney(value)
        })
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 12, bottom: 18 })
  }

  @Builder
  private topBar() {
    Row() {
      Image($r('app.media.arrow_back'))
        .width(28)
        .height(28)
        .objectFit(ImageFit.Contain)
        .onClick(() => {
          this.onBack()
        })

      Text('预算')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor('#111111')
        .margin({ left: 18 })

      Blank()

      Text('保存')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#55B8A7')
        .onClick(() => {
          this.saveBudget()
        })
    }
    .width('100%')
    .height(54)
    .padding({ left: 18, right: 18 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  private summaryCard() {
    Column({ space: 14 }) {
      Row() {
        Column({ space: 5 }) {
          Text(this.monthLabel())
            .fontSize(14)
            .fontColor('#6B7280')
          Text('总预算')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111111')
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
        Text(this.totalBudgetText.length > 0 ? this.formatMoney(this.moneyValue(this.totalBudgetText)) : '点击设置')
          .fontSize(24)
          .fontColor(this.totalBudgetText.length > 0 ? '#55B8A7' : '#9A9A9A')
          .textAlign(TextAlign.End)
          .width(150)
          .height(44)
          .padding({ top: 6 })
          .onClick(() => {
            this.openTotalBudgetSheet()
          })
      }
      .width('100%')

      Row() {
        Column({ space: 6 }) {
          Text('已用')
            .fontSize(12)
            .fontColor('#8A8A8A')
          Text(this.formatMoney(this.totalUsedAmount))
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#E07178')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 6 }) {
          Text('剩余')
            .fontSize(12)
            .fontColor('#8A8A8A')
          Text(this.formatMoney(this.totalRemainingAmount))
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.totalRemainingAmount < 0 ? '#E07178' : '#55B8A7')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .backgroundColor('#F4FBFA')
    .borderRadius(12)
  }

  @Builder
  private categoryBudgetCard() {
    Column({ space: 0 }) {
      Text('分类预算')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor('#111111')
        .width('100%')
        .margin({ bottom: 6 })

      ForEach(this.categoryViews, (view: CategoryBudgetView, index: number) => {
        this.categoryBudgetRow(view, index)
      }, (view: CategoryBudgetView) => view.category.id)
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 18, bottom: 12 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({ width: 1, color: '#F0F0F0' })
  }

  @Builder
  private categoryBudgetRow(view: CategoryBudgetView, index: number) {
    Row({ space: 10 }) {
      Image(iconResourceById(view.category.iconId))
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)

      Column({ space: 4 }) {
        Text(view.category.name)
          .fontSize(15)
          .fontColor('#111111')
        Text('已用 ' + this.formatMoney(view.used) + '  剩余 ' + this.formatMoney(this.categoryRemaining(view)))
          .fontSize(11)
          .fontColor(this.categoryRemaining(view) < 0 ? '#E07178' : '#8A8A8A')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text(view.amountText.length > 0 ? this.formatMoney(this.moneyValue(view.amountText)) : '设置')
        .fontSize(15)
        .fontColor(view.amountText.length > 0 ? '#111111' : '#9A9A9A')
        .textAlign(TextAlign.End)
        .backgroundColor('#F7F8F8')
        .width(96)
        .height(38)
        .padding({ top: 10, right: 10 })
        .borderRadius(8)
        .onClick(() => {
          this.openCategoryBudgetSheet(index)
        })
    }
    .width('100%')
    .height(58)
  }

  private loadData() {
    BudgetStore.load(getContext(this))
      .then((budgets: MonthlyBudget[]) => {
        return BillCategoryStore.load(getContext(this))
          .then((categories: BillCategory[]) => {
            return BillRecordStore.load(getContext(this))
              .then((records: BillRecord[]) => {
                this.applyBudgetData(budgets, categories, records)
              })
          })
      })
      .catch(() => {
        this.showToast('预算数据读取失败')
      })
  }

  private applyBudgetData(budgets: MonthlyBudget[], categories: BillCategory[], records: BillRecord[]) {
    const budget = BudgetStore.findByMonth(budgets, this.month)
    this.categories = BillCategoryStore.activeByType(categories, 'expense')
    this.records = records
    // @State 赋值会参与 ArkUI 的响应式调度，不能依赖上一行 this.records 立刻同步可读。
    // 因此总已用和分类已用都用本次 loadData 拿到的 records 直接计算，避免显示为 0。
    const totalUsed = this.budgetExpenseUsedFromRecords(records, '')
    const totalRemaining = this.calculateTotalRemaining(budget.totalBudget, totalUsed)
    this.totalUsedAmount = totalUsed
    this.totalRemainingAmount = totalRemaining
    this.totalBudgetText = budget.totalBudget > 0 ? this.formatAmount(budget.totalBudget) : ''
    this.categoryViews = this.buildCategoryViews(budget, records)
    console.info('[BudgetDebug] applyBudgetData month=' + this.month +
      ', totalBudget=' + budget.totalBudget.toString() +
      ', totalUsed=' + totalUsed.toString() +
      ', totalRemaining=' + totalRemaining.toString() +
      ', records=' + records.length.toString() +
      ', categories=' + this.categories.length.toString())
  }

  private buildCategoryViews(budget: MonthlyBudget, records: BillRecord[]): CategoryBudgetView[] {
    const views: CategoryBudgetView[] = []
    for (let index = 0; index < this.categories.length; index++) {
      const category = this.categories[index]
      const amount = this.categoryBudgetAmount(budget, category.id)
      views.push({
        category: category,
        amountText: amount > 0 ? this.formatAmount(amount) : '',
        used: this.budgetExpenseUsedFromRecords(records, category.id)
      })
    }
    return views
  }

  private saveBudget() {
    this.persistBudget(this.totalBudgetText, this.categoryViews)
  }

  private persistBudget(totalBudgetText: string, categoryViews: CategoryBudgetView[]) {
    const categoryBudgets: CategoryBudget[] = []
    for (let index = 0; index < categoryViews.length; index++) {
      const amount = this.moneyValue(categoryViews[index].amountText)
      if (amount > 0) {
        categoryBudgets.push({
          categoryId: categoryViews[index].category.id,
          categoryName: categoryViews[index].category.name,
          amount: amount
        })
      }
    }

    BudgetStore.load(getContext(this))
      .then((budgets: MonthlyBudget[]) => {
        const oldBudget = BudgetStore.findByMonth(budgets, this.month)
        const now = new Date().toISOString()
        const nextBudget: MonthlyBudget = {
          month: this.month,
          totalBudget: this.moneyValue(totalBudgetText),
          categoryBudgets: categoryBudgets,
          createTime: oldBudget.createTime,
          updateTime: now
        }
        return BudgetStore.save(getContext(this), BudgetStore.upsert(budgets, nextBudget))
      })
      .then(() => {
        this.showToast('预算已保存')
        this.onChanged()
        this.loadData()
      })
      .catch(() => {
        this.showToast('预算保存失败')
      })
  }

  private openTotalBudgetSheet() {
    this.budgetSheetTarget = 'total'
    this.editingCategoryIndex = -1
    this.amountDraftText = this.totalBudgetText
    this.showBudgetSheet = true
  }

  private openCategoryBudgetSheet(index: number) {
    this.budgetSheetTarget = 'category'
    this.editingCategoryIndex = index
    this.amountDraftText = this.categoryViews[index].amountText
    this.showBudgetSheet = true
  }

  private confirmBudgetAmount() {
    const nextAmount = this.sanitizeMoney(this.amountDraftText)
    if (this.budgetSheetTarget === 'total') {
      this.totalBudgetText = nextAmount
      this.totalRemainingAmount = this.calculateTotalRemaining(this.moneyValue(nextAmount), this.totalUsedAmount)
      this.showBudgetSheet = false
      this.persistBudget(nextAmount, this.categoryViews)
      return
    }

    if (this.editingCategoryIndex < 0 || this.editingCategoryIndex >= this.categoryViews.length) {
      this.showBudgetSheet = false
      return
    }

    const nextViews = this.categoryViewsWithAmount(this.editingCategoryIndex, nextAmount)
    this.categoryViews = nextViews
    this.showBudgetSheet = false
    this.persistBudget(this.totalBudgetText, nextViews)
  }

  private budgetSheetTitle(): string {
    if (this.budgetSheetTarget === 'total') {
      return '总预算'
    }
    if (this.editingCategoryIndex >= 0 && this.editingCategoryIndex < this.categoryViews.length) {
      return this.categoryViews[this.editingCategoryIndex].category.name + '预算'
    }
    return '分类预算'
  }

  private updateCategoryAmount(index: number, value: string) {
    this.categoryViews = this.categoryViewsWithAmount(index, this.sanitizeMoney(value))
  }

  private categoryViewsWithAmount(index: number, amountText: string): CategoryBudgetView[] {
    const nextViews: CategoryBudgetView[] = []
    for (let itemIndex = 0; itemIndex < this.categoryViews.length; itemIndex++) {
      if (itemIndex === index) {
        nextViews.push({
          category: this.categoryViews[itemIndex].category,
          amountText: amountText,
          used: this.categoryViews[itemIndex].used
        })
      } else {
        nextViews.push(this.categoryViews[itemIndex])
      }
    }
    return nextViews
  }

  private calculateTotalRemaining(totalBudget: number, totalUsed: number): number {
    if (totalBudget <= 0) {
      return 0
    }
    return this.roundMoney(totalBudget - totalUsed)
  }

  private categoryUsed(categoryId: string): number {
    return this.budgetExpenseUsedFromRecords(this.records, categoryId)
  }

  private budgetExpenseUsedFromRecords(records: BillRecord[], categoryId: string): number {
    let total = 0
    for (let index = 0; index < records.length; index++) {
      if (this.isBudgetExpense(records[index]) &&
        (categoryId.length === 0 || this.recordCategoryId(records[index]) === categoryId)) {
        total += records[index].amount
      }
    }
    return this.roundMoney(total)
  }

  private categoryRemaining(view: CategoryBudgetView): number {
    const amount = this.moneyValue(view.amountText)
    if (amount <= 0) {
      return 0
    }
    return this.roundMoney(amount - view.used)
  }

  private isBudgetExpense(record: BillRecord): boolean {
    if (record.isDeleted || record.type !== 'expense') {
      return false
    }
    if (record.includeInBudget === false) {
      return false
    }
    return this.recordMonth(record) === this.month
  }

  private categoryBudgetAmount(budget: MonthlyBudget, categoryId: string): number {
    for (let index = 0; index < budget.categoryBudgets.length; index++) {
      if (budget.categoryBudgets[index].categoryId === categoryId) {
        return budget.categoryBudgets[index].amount
      }
    }
    return 0
  }

  private recordMonth(record: BillRecord): string {
    if (record.month !== undefined && record.month.length > 0) {
      return record.month
    }
    const date = new Date(record.billDate)
    return date.getFullYear().toString() + '-' + this.pad2(date.getMonth() + 1)
  }

  private recordCategoryId(record: BillRecord): string {
    if (record.categoryId !== undefined && record.categoryId.length > 0) {
      return record.categoryId
    }
    if (record.category !== undefined && record.category.id.length > 0) {
      return record.category.id
    }
    return ''
  }

  private currentMonthKey(): string {
    const now = new Date()
    return now.getFullYear().toString() + '-' + this.pad2(now.getMonth() + 1)
  }

  private monthLabel(): string {
    const parts = this.month.split('-')
    if (parts.length < 2) {
      return this.month
    }
    return parts[0] + '年' + parts[1] + '月'
  }

  private sanitizeMoney(value: string): string {
    let result = ''
    let hasDot = false
    for (let index = 0; index < value.length; index++) {
      const char = value.charAt(index)
      if (char >= '0' && char <= '9') {
        result += char
      } else if (char === '.' && !hasDot) {
        result += char
        hasDot = true
      }
    }
    const dotIndex = result.indexOf('.')
    if (dotIndex >= 0 && result.length > dotIndex + 3) {
      return result.substring(0, dotIndex + 3)
    }
    return result
  }

  private moneyValue(value: string): number {
    const amount = Number(value)
    return amount === amount ? this.roundMoney(amount) : 0
  }

  private roundMoney(value: number): number {
    return Math.round(value * 100) / 100
  }

  private formatMoney(value: number): string {
    return '¥' + this.formatAmount(value)
  }

  private formatAmount(value: number): string {
    return this.roundMoney(value).toFixed(2)
  }

  private pad2(value: number): string {
    return value < 10 ? '0' + value.toString() : value.toString()
  }

  private showToast(message: string) {
    this.toastVersion += 1
    const currentVersion = this.toastVersion
    this.toastMessage = message
    this.toastVisible = true
    setTimeout(() => {
      if (this.toastVersion === currentVersion) {
        this.toastVisible = false
      }
    }, 1600)
  }
}
