type AddBillMode = 'expense' | 'income' | 'transfer' | 'debt'

interface BillCategoryOption {
  icon: string
  title: string
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
  @State private pendingOperator: string = ''
  @State private remark: string = ''
  onBack: () => void = () => {}

  build() {
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
        // todo：这里应该可以点击出现日期组件，选择日期并返回
        this.metaItem('日', '今天')
        // todo：这里应该可以点击从下往上动画出现一个方框，选择已有的账户，使得账单和资产关联起来，对对应的账户进行扣款、加钱等。
        this.metaItem('￥', this.mode === 'expense' ? '余额宝' : '余额宝')
        if (this.mode === 'expense') {
          this.metaItem('报', '不报销')
        }
        this.metaItem('附', '附件')
        this.metaItem('惠', '优惠')
        this.metaItem('属', '属性')
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
  private metaItem(icon: string, title: string) {
    Row({ space: 5 }) {
      Text(icon)
        .fontSize(15)
        .fontColor('#111111')
      Text(title)
        .fontSize(16)
        .fontColor('#111111')
    }
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
        this.keyboardButton(this.pendingOperator.length > 0 ? '=' : '完成')
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 4, right: 4, top: 6, bottom: 6 })
    .backgroundColor('#F2F2F2')
  }

  @Builder
  private keyboardButton(key: string) {
    Text(key)
      .fontSize(key.length > 1 ? 17 : 24)
      .fontColor('#111111')
      .textAlign(TextAlign.Center)
      .layoutWeight(1)
      .height(58)
      .padding({ top: key.length > 1 ? 18 : 15 })
      .backgroundColor(this.isOperatorKey(key) ? '#E8E8E8' : '#FFFFFF')
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
    return key === '退' || key === '+' || key === '-' || key === '×' || key === '÷' || key === '=' || key === '完成' || key === '再记'
  }

  private handleKey(key: string) {
    if (key === '完成') {
      return
    }
    if (key === '=') {
      this.pendingOperator = ''
      return
    }
    if (key === '+' || key === '-' || key === '×' || key === '÷') {
      this.pendingOperator = key
      return
    }
    if (key === '再记') {
      this.amountText = '0.00'
      this.pendingOperator = ''
      return
    }
    if (key === '退') {
      if (this.amountText.length <= 1 || this.amountText === '0.00') {
        this.amountText = '0.00'
      } else {
        this.amountText = this.amountText.substring(0, this.amountText.length - 1)
      }
      return
    }
    if ((key >= '0' && key <= '9') || key === '.') {
      if (this.amountText === '0.00') {
        this.amountText = key === '.' ? '0.' : key
      } else {
        this.amountText += key
      }
    }
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
