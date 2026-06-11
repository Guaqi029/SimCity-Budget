import { BillRecordTimeline } from '../components/bill/BillRecordTimeline'
import { BillTimelineMapper } from '../components/bill/BillTimelineMapper'
import { BillRecord } from '../model/BillRecord'
import { MonthlyBudget } from '../model/Budget'
import { BillRecordStore } from '../storage/BillRecordStore'
import { BudgetStore } from '../storage/BudgetStore'

@Component
export struct HomePage {
  @Watch('onBillRefreshChanged') @Prop billRefreshVersion: number = 0
  @Watch('onHomeRefreshChanged') @Prop homeRefreshVersion: number = 0
  @State private billRecords: BillRecord[] = []
  @State private todayExpense: number = 0
  @State private monthExpense: number = 0
  @State private viewportHeight: number = 0
  @State private monthBudget: MonthlyBudget = {
    month: '',
    totalBudget: 0,
    categoryBudgets: [],
    createTime: '',
    updateTime: ''
  }
  onAddBill: () => void = () => {}
  onOpenAccount: () => void = () => {}
  onOpenBillDetail: (billId: string) => void = () => {}
  onOpenBudget: () => void = () => {}

  aboutToAppear() {
    this.loadBills()
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Scroll() {
        Column({ space: 16 }) {
          this.homeHeroSection()

          BillRecordTimeline({
            records: this.billRecords,
            filter: { limit: 30 },
            onOpenBill: (billId: string) => {
              this.onOpenBillDetail(billId)
            }
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 104 })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)

      this.addBillButton()
    }
    .width('100%')
    .height('100%')
    .onAreaChange((_, area) => {
      const nextHeight = Number(area.height)
      if (nextHeight > 0 && Math.abs(nextHeight - this.viewportHeight) > 1) {
        this.viewportHeight = nextHeight
      }
    })
  }

  @Builder
  private addBillButton() {
    Stack({ alignContent: Alignment.Center }) {
      Image($r('app.media.add'))
        .width(28)
        .height(28)
    }
    // 首页自己的悬浮入口，按钮本体之外不占点击区域，避免影响底部 TabBar。
    .width(58)
    .height(58)
    .borderRadius(29)
    .backgroundColor('#55B8A7')
    .shadow({ radius: 18, color: '#3355B8A744', offsetY: 8 })
    .margin({ right: 22, bottom: 22 })
    .onClick(() => {
      this.onAddBill()
    })
  }

  @Builder
  private homeHeroSection() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column()
        .width('100%')
        .height(this.heroSectionHeight())
        .linearGradient({
          angle: 180,
          colors: [['#EAF7FF', 0.0], ['#D7F0FF', 0.42], ['#C7E7FF', 1.0]]
        })
        .borderRadius(38)

      Column({ space: 18 }) {
        Row() {
          Text('记账改变生活')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#61738F')
            .padding({ left: 18, right: 18, top: 10, bottom: 10 })
            .backgroundColor('#F6FBFF')
            .borderRadius(24)

          Blank()
        }
        .width('100%')
        .padding({ right: 8 })

        this.buildIslandScene(this.citySceneHeight())
      }
      .width('100%')
      .height(this.heroSectionHeight())
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: 20, right: 20, top: 22, bottom: this.heroCardHeight() + 34 })

      Row({ space: 12 }) {
        // 替换：不再把 layoutWeight 链在 Builder 调用后面，而是由外层容器承接。
        // 删除原因：Builder 调用返回的不是可继续链式设置属性的组件实例，直接接 `.layoutWeight()` 会触发 `Property 'layoutWeight' does not exist on type 'void'`。
        // 新增功能：预算卡和城市级别卡继续保持左右分栏，但由包裹容器安全地控制比例和高度。
        Column() {
          this.budgetInfoCard()
        }
        .layoutWeight(6)
        .height(this.heroCardHeight())

        Column() {
          this.cityLevelCard()
        }
        .layoutWeight(4)
        .height(this.heroCardHeight())
      }
      .width('100%')
      .padding({ left: 18, right: 18, bottom: this.heroCardBottomInset() })
    }
    .width('100%')
    .height(this.heroSectionHeight())
  }

  private onBillRefreshChanged() {
    this.loadBills()
  }

  @Builder
  private budgetInfoCard() {
    Column({ space: 10 }) {
      Text('剩余预算')
        .fontSize(14)
        .fontColor('#6B7A99')

      Text(this.budgetRemainingText())
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.monthBudget.totalBudget > 0 && this.monthBudget.totalBudget - this.budgetUsed() < 0 ? '#E07178' : '#18233A')

      Text('总预算 ' + this.formatMoney(this.monthBudget.totalBudget))
        .fontSize(12)
        .fontColor('#95A2BC')
    }
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .backgroundColor('#F8FBFF')
    .borderRadius(20)
    .onClick(() => {
      this.onOpenBudget()
    })
  }

  @Builder
  private cityLevelCard() {
    Column({ space: 10 }) {
      Text('城市级别')
        .fontSize(14)
        .fontColor('#6B7A99')

      Text(this.cityLevelTitle())
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#18233A')

      Text(this.cityLevelDescription())
        .fontSize(12)
        .fontColor('#95A2BC')
        .maxLines(2)
    }
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .backgroundColor('#F8FBFF')
    .borderRadius(20)
  }

  private onHomeRefreshChanged() {
    this.loadBills()
  }

  private loadBills() {
    BillRecordStore.load(getContext(this))
      .then((records: BillRecord[]) => {
        return BudgetStore.load(getContext(this))
          .then((budgets: MonthlyBudget[]) => {
            this.applyHomeData(records, budgets)
          })
      })
      .catch(() => {
        this.billRecords = []
        this.todayExpense = 0
        this.monthExpense = 0
        this.monthBudget = {
          month: this.monthKey(new Date()),
          totalBudget: 0,
          categoryBudgets: [],
          createTime: '',
          updateTime: ''
        }
      })
  }

  private applyHomeData(records: BillRecord[], budgets: MonthlyBudget[]) {
    const now = new Date()
    const month = this.monthKey(now)
    this.billRecords = records
    this.todayExpense = BillTimelineMapper.calculateExpense(records, {
      day: BillTimelineMapper.dateKey(now)
    })
    this.monthExpense = BillTimelineMapper.calculateExpense(records, {
      startDate: BillTimelineMapper.monthStartKey(now),
      endDate: BillTimelineMapper.monthEndKey(now)
    })
    this.monthBudget = BudgetStore.findByMonth(budgets, month)
  }

  private budgetRemainingText(): string {
    if (this.monthBudget.totalBudget <= 0) {
      return '未设置'
    }
    return this.formatMoney(this.monthBudget.totalBudget - this.budgetUsed())
  }

  private budgetUsed(): number {
    let total = 0
    const month = this.monthKey(new Date())
    for (let index = 0; index < this.billRecords.length; index++) {
      const record = this.billRecords[index]
      if (!record.isDeleted && record.type === 'expense' && record.includeInBudget !== false && this.recordMonth(record) === month) {
        total += record.amount
      }
    }
    return Math.round(total * 100) / 100
  }

  private recordMonth(record: BillRecord): string {
    if (record.month !== undefined && record.month.length > 0) {
      return record.month
    }
    const date = new Date(record.billDate)
    return this.monthKey(date)
  }

  private monthKey(date: Date): string {
    return date.getFullYear().toString() + '-' + this.pad2(date.getMonth() + 1)
  }

  private formatMoney(value: number): string {
    return '¥' + (Math.round(value * 100) / 100).toFixed(2)
  }

  private pad2(value: number): string {
    return value < 10 ? '0' + value.toString() : value.toString()
  }

  @Builder
  private buildIslandScene(sceneHeight: number) {
    Stack({ alignContent: Alignment.Bottom }) {
      Column()
        .width('100%')
        .height(this.skylineHeight(sceneHeight))
        .backgroundColor('#66D9F0')
        .borderRadius(34)

      Column()
        .width('92%')
        .height(this.islandHeight(sceneHeight))
        .margin({ bottom: 18 })
        .linearGradient({
          angle: 180,
          colors: [['#D9FF88', 0.0], ['#A8E78C', 0.55], ['#86DCA0', 1.0]]
        })
        .borderRadius({ topLeft: 160, topRight: 160, bottomLeft: 82, bottomRight: 82 })

      Row({ space: 24 }) {
        this.buildMiniBuilding(sceneHeight * 0.38, '#7CC4FF')
        this.buildMiniBuilding(sceneHeight * 0.56, '#5BA9F0')
        this.buildMiniBuilding(sceneHeight * 0.45, '#8ED0FF')
        this.buildMiniBuilding(sceneHeight * 0.4, '#79B8F2')
      }
      .margin({ bottom: this.buildingBottom(sceneHeight) })

      Row({ space: 18 }) {
        this.buildTinyHouse('#F6C16B')
        this.buildTinyHouse('#7FC2FF')
        this.buildTinyHouse('#8EDC9D')
        this.buildTinyHouse('#7CC4FF')
      }
      .margin({ top: this.villageTop(sceneHeight), left: 26 })
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Text('风车区')
        .fontSize(12)
        .fontColor('#40617A')
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor('#F4FBFF')
        .borderRadius(16)
        .margin({ bottom: this.windAreaBottom(sceneHeight), left: 210 })
        .width('100%')
        .textAlign(TextAlign.Start)

      Text('热气球')
        .fontSize(12)
        .fontColor('#40617A')
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor('#FFF8E4')
        .borderRadius(16)
        .margin({ bottom: this.balloonBottom(sceneHeight), left: 236 })
        .width('100%')
        .textAlign(TextAlign.Start)
    }
    .width('100%')
    .height(sceneHeight)
  }

  @Builder
  private buildMiniBuilding(height: number, tone: string) {
    Column() {
      Column()
        .width(52)
        .height(height)
        .backgroundColor(tone)
        .borderRadius({ topLeft: 18, topRight: 18, bottomLeft: 10, bottomRight: 10 })

      Column()
        .width(64)
        .height(14)
        .backgroundColor('#EDF6FF')
        .borderRadius(10)
        .margin({ top: 4 })
    }
  }

  @Builder
  private buildTinyHouse(tone: string) {
    Column({ space: 4 }) {
      Column()
        .width(34)
        .height(20)
        .backgroundColor(tone)
        .borderRadius({ topLeft: 12, topRight: 12, bottomLeft: 6, bottomRight: 6 })

      Column()
        .width(42)
        .height(8)
        .backgroundColor('#EDF6FF')
        .borderRadius(6)
    }
  }

  private cityLevelTitle(): string {
    const remaining = this.monthBudget.totalBudget - this.budgetUsed()
    if (this.monthBudget.totalBudget <= 0) {
      return '起步'
    }
    if (remaining < 0) {
      return '紧张'
    }
    if (remaining < this.monthBudget.totalBudget * 0.2) {
      return '谨慎'
    }
    return '繁荣'
  }

  private cityLevelDescription(): string {
    const title = this.cityLevelTitle()
    if (title === '紧张') {
      return '本月预算吃紧，城市发展放缓'
    }
    if (title === '谨慎') {
      return '预算接近上限，城市需要稳步运营'
    }
    if (title === '起步') {
      return '先设置预算，城市才能开始建设'
    }
    return '消费克制，小镇持续发展'
  }

  private heroSectionHeight(): number {
    if (this.viewportHeight <= 0) {
      return 700
    }
    return this.viewportHeight - 16
  }

  private heroCardHeight(): number {
    return Math.max(96, Math.min(144, this.heroSectionHeight() * 0.18))
  }

  private heroCardBottomInset(): number {
    return Math.max(72, Math.min(108, this.heroSectionHeight() * 0.1))
  }

  private citySceneHeight(): number {
    return this.heroSectionHeight() - this.heroCardHeight() - 118
  }

  private skylineHeight(sceneHeight: number): number {
    return Math.max(132, sceneHeight * 0.88)
  }

  private islandHeight(sceneHeight: number): number {
    return Math.max(104, sceneHeight * 0.7)
  }

  private buildingBottom(sceneHeight: number): number {
    return Math.max(32, sceneHeight * 0.16)
  }

  private villageTop(sceneHeight: number): number {
    return Math.max(88, sceneHeight * 0.4)
  }

  private windAreaBottom(sceneHeight: number): number {
    return Math.max(80, sceneHeight * 0.3)
  }

  private balloonBottom(sceneHeight: number): number {
    return Math.max(124, sceneHeight * 0.48)
  }
}
