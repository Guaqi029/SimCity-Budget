import { BillRecord } from '../model/BillRecord'
import { AssetAccount } from '../model/AssetAccount'
import { AssetAccountStore } from '../storage/AssetAccountStore'
import { BillRecordStore } from '../storage/BillRecordStore'
import { BillDatePicker, BillDatePickerValue } from '../components/bill/BillDatePicker'
import { AssetAccountPicker } from '../components/bill/AssetAccountPicker'
import { iconResourceById } from '../components/icon/IconLibraryConfig'

const EMPTY_BILL_RECORD: BillRecord = {
  id: '',
  amount: 0,
  type: 'expense',
  assetId: '',
  assetName: '',
  fromAssetId: '',
  fromAssetName: '',
  toAssetId: '',
  toAssetName: '',
  transferFee: 0,
  category: {
    id: '',
    name: '其他',
    type: 'expense',
    iconId: 'icon_other',
    createTime: '',
    updateTime: '',
    isSystem: false,
    isDeleted: false
  },
  categoryId: '',
  categoryName: '',
  billDate: '',
  month: '',
  remark: '',
  createTime: '',
  updateTime: '',
  isDeleted: false
}

@Component
export struct BillDetailPage {
  @Prop billId: string = ''
  @State private bill: BillRecord = EMPTY_BILL_RECORD
  @State private hasBill: boolean = false
  @State private showMenu: boolean = false
  @State private showDeleteConfirm: boolean = false
  @State private showDatePicker: boolean = false
  @State private showAssetPicker: boolean = false
  @State private assets: AssetAccount[] = []
  onBack: () => void = () => {}
  onDeleted: () => void = () => {}
  onUpdated: () => void = () => {}

  aboutToAppear() {
    this.loadBill()
    this.loadAssets()
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column() {
        this.topBar()

        if (!this.hasBill) {
          this.emptyState()
        } else {
          this.detailScrollContent()
          this.bottomActions()
        }
      }
      .width('100%')
      .height('100%')

      if (this.showMenu) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#00000000')
          .onClick(() => {
            this.showMenu = false
          })

        this.optionMenu()
      }

      if (this.showDeleteConfirm) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#000000')
          .opacity(0.42)
          .onClick(() => {
            this.showDeleteConfirm = false
          })

        Stack({ alignContent: Alignment.Center }) {
          this.deleteConfirmDialog()
        }
        .width('100%')
        .height('100%')
      }

      if (this.showDatePicker && this.hasBill) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#000000')
          .opacity(0.42)
          .onClick(() => {
            this.showDatePicker = false
          })

        Stack({ alignContent: Alignment.Center }) {
          BillDatePicker({
            year: this.billDate().getFullYear(),
            month: this.billDate().getMonth(),
            day: this.billDate().getDate(),
            hour: this.billDate().getHours(),
            minute: this.billDate().getMinutes(),
            onCancel: () => {
              this.showDatePicker = false
            },
            onConfirm: (value: BillDatePickerValue) => {
              this.updateBillDate(value)
            }
          })
        }
        .width('100%')
        .height('100%')
      }
      
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .bindSheet($$this.showAssetPicker, this.assetPickerSheet(), {
      height: 520,
      backgroundColor: '#FFFFFF',
      preferType: SheetType.BOTTOM,
      maskColor: '#66000000'
    })
  }

  @Builder
  private assetPickerSheet() {
    if (this.hasBill) {
      AssetAccountPicker({
        assets: this.assets,
        selectedAssetId: this.bill.assetId === undefined ? '' : this.bill.assetId,
        onSelect: (asset: AssetAccount | undefined) => {
          this.updateBillAsset(asset)
        }
      })
    }
  }

  @Builder
  private topBar() {
    Column() {
      Row() {
        Image($r('app.media.arrow_back'))
          .width(28)
          .height(28)
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            this.onBack()
          })

        Text('账单详情')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111111')
          .margin({ left: 22 })

        Blank()

        Image($r('app.media.more_col'))
          .width(28)
          .height(28)
          .objectFit(ImageFit.Fill)
          .onClick(() => {
            this.showMenu = !this.showMenu
          })
      }
      .width('100%')
      .height(50)
      .padding({ left: 20, right: 20 })
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .height(50)
    .backgroundColor('#FFFFFF')
  }

  @Builder
  private emptyState() {
    Column({ space: 14 }) {
      Text('未找到账单')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#111111')
      Text('当前账单可能已被删除，或还没有从列表选择具体账单。')
        .fontSize(13)
        .fontColor('#8A8A8A')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .padding({ left: 32, right: 32 })
    .backgroundColor('#F3F3F3')
  }

  @Builder
  private detailScrollContent() {
    Scroll() {
      Column({ space: 12 }) {
        this.summaryCard()
        this.detailCard()
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('#F3F3F3')
    .scrollBar(BarState.Off)
  }

  @Builder
  private summaryCard() {
    Row({ space: 18 }) {
      Stack({ alignContent: Alignment.Center }) {
        Image(iconResourceById(this.bill.category.iconId))
          .width(24)
          .height(24)
          .objectFit(ImageFit.Contain)
      }
        .width(36)
        .height(36)
        .border({ width: 1, color: '#DDE7E4' })
        .borderRadius(4)

      Text(this.billCategoryName())
        .fontSize(22)
        .fontWeight(FontWeight.Medium)
        .fontColor('#111111')

      Blank()

      Text(this.amountText())
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.amountColor())
    }
    .width('100%')
    .height(84)
    .padding({ left: 22, right: 22 })
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }

  @Builder
  private detailCard() {
    Column({ space: 0 }) {
      this.dateRow()
      this.accountRow()
      this.infoRow('备注', this.remarkText(), '#999999')
      this.infoRow('标签', '点击添加', '#999999')
      this.infoRow('附件', '点击添加', '#999999')
      this.switchRow('不计入收支')
      this.switchRow('不计入预算')
      // this.infoRow('地点信息', '无', '#999999')
      this.infoRow('记录时间', this.createTimeText())
      // this.infoRow('记录方式', '手动记账')
      // this.linkRow('关联账单')
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 20, bottom: 10 })
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }

  @Builder
  private dateRow() {
    Row() {
      Text('账单日期')
        .fontSize(17)
        .fontColor('#111111')
      Blank()
      Text(this.billDateText())
        .fontSize(17)
        .fontColor('#111111')
        .maxLines(1)
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .height(62)
    .onClick(() => {
      this.showDatePicker = true
    })
  }

  @Builder
  private infoRow(label: string, value: string, valueColor: string = '#111111') {
    Row() {
      Text(label)
        .fontSize(17)
        .fontColor('#111111')
      Blank()
      Text(value)
        .fontSize(17)
        .fontColor(valueColor)
        .maxLines(1)
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .height(62)
  }

  @Builder
  private accountRow() {
    Row() {
      Text(this.billAccountLabel())
        .fontSize(17)
        .fontColor('#111111')
      Blank()
      Row({ space: 10 }) {
        Text(this.accountIcon())
          .width(24)
          .height(24)
          .fontSize(13)
          .fontColor('#FFFFFF')
          .textAlign(TextAlign.Center)
          .padding({ top: 5 })
          .backgroundColor(this.billTypeColor())
          .borderRadius(12)

        Text(this.accountText())
          .fontSize(17)
          .fontColor('#111111')
          .maxLines(1)
      }
    }
    .width('100%')
    .height(62)
    .onClick(() => {
      if (this.bill.type !== 'transfer') {
        this.showAssetPicker = true
      }
    })
  }

  @Builder
  private switchRow(label: string) {
    Row() {
      Text(label)
        .fontSize(17)
        .fontColor('#111111')
      Blank()
      Toggle({ type: ToggleType.Switch, isOn: false })
        .width(52)
        .height(30)
        .enabled(false)
    }
    .width('100%')
    .height(62)
  }

  @Builder
  private linkRow(label: string) {
    Row() {
      Text(label)
        .fontSize(17)
        .fontColor('#111111')
      Blank()
      Image($r('app.media.arrow_forward'))
        .width(22)
        .height(22)
        .objectFit(ImageFit.Contain)
        .opacity(0.45)
    }
    .width('100%')
    .height(62)
  }

  @Builder
  private bottomActions() {
    Row({ space: 16 }) {
      Button('退款')
        .type(ButtonType.Normal)
        .layoutWeight(1)
        .height(44)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor('#55B8A7')
        .borderRadius(8)

      Button('编辑')
        .type(ButtonType.Normal)
        .layoutWeight(1)
        .height(44)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor('#55B8A7')
        .borderRadius(8)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .backgroundColor('#FFFFFF')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  @Builder
  private optionMenu() {
    Column({ space: 0 }) {
      this.menuItem('退款')
      this.menuItem('属性设置')
      this.menuItem('账单拆分')
      this.menuItem('删除')
    }
    .width(210)
    .padding({ top: 10, bottom: 10 })
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 18, color: '#22333333', offsetY: 8 })
    .align(Alignment.TopEnd)
    .margin({ top: 74 })
  }

  @Builder
  private menuItem(label: string) {
    Text(label)
      .fontSize(17)
      .fontColor('#111111')
      .width('100%')
      .height(56)
      .padding({ left: 24 })
      .textAlign(TextAlign.Start)
      .onClick(() => {
        this.showMenu = false
        if (label === '删除') {
          this.showDeleteConfirm = true
        }
      })
  }

  @Builder
  private deleteConfirmDialog() {
    Column({ space: 16 }) {
      Text('删除账单')
        .fontSize(19)
        .fontWeight(FontWeight.Medium)
        .fontColor('#111111')

      Text('删除后会同步回滚对应资产余额，确认删除这笔账单吗？')
        .fontSize(14)
        .fontColor('#666666')
        .lineHeight(21)
        .textAlign(TextAlign.Center)

      Row({ space: 12 }) {
        Button('取消')
          .type(ButtonType.Normal)
          .layoutWeight(1)
          .height(42)
          .fontSize(15)
          .fontColor('#333333')
          .backgroundColor('#F0F0F0')
          .borderRadius(8)
          .onClick(() => {
            this.showDeleteConfirm = false
          })

        Button('确认删除')
          .type(ButtonType.Normal)
          .layoutWeight(1)
          .height(42)
          .fontSize(15)
          .fontColor('#FFFFFF')
          .backgroundColor('#D85C62')
          .borderRadius(8)
          .onClick(() => {
            this.showDeleteConfirm = false
            this.deleteBill()
          })
      }
      .width('100%')
    }
    .width(300)
    .padding({ left: 20, right: 20, top: 22, bottom: 18 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 18, color: '#22333333', offsetY: 8 })
  }

  private loadBill() {
    if (this.billId.length === 0) {
      this.hasBill = false
      this.bill = EMPTY_BILL_RECORD
      return
    }
    BillRecordStore.load(getContext(this))
      .then((records: BillRecord[]) => {
        for (let index = 0; index < records.length; index++) {
          if (records[index].id === this.billId && !records[index].isDeleted) {
            this.bill = records[index]
            this.hasBill = true
            return
          }
        }
        this.hasBill = false
        this.bill = EMPTY_BILL_RECORD
      })
      .catch(() => {
        this.hasBill = false
        this.bill = EMPTY_BILL_RECORD
      })
  }

  private loadAssets() {
    AssetAccountStore.load(getContext(this))
      .then((assets: AssetAccount[]) => {
        const activeAssets: AssetAccount[] = []
        for (let index = 0; index < assets.length; index++) {
          if (!assets[index].isDeleted) {
            activeAssets.push(assets[index])
          }
        }
        this.assets = activeAssets
      })
      .catch(() => {
        this.assets = []
      })
  }

  private updateBillDate(value: BillDatePickerValue) {
    if (!this.hasBill) {
      this.showDatePicker = false
      return
    }

    const nextDate = new Date(value.year, value.month, value.day, value.hour, value.minute, 0)
    const now = new Date().toISOString()
    const nextBill = this.copyBillWithDate(this.bill, nextDate, now)
    this.saveUpdatedBill(nextBill)
      .then(() => {
        this.bill = nextBill
        this.showDatePicker = false
        this.onUpdated()
      })
  }

  private updateBillAsset(asset: AssetAccount | undefined) {
    if (!this.hasBill || this.bill.type === 'transfer') {
      this.showAssetPicker = false
      return
    }

    const nextAssetId = asset === undefined ? '' : asset.id
    if ((this.bill.assetId === undefined ? '' : this.bill.assetId) === nextAssetId) {
      this.showAssetPicker = false
      return
    }

    const now = new Date().toISOString()
    const nextBill = this.copyBillWithAsset(this.bill, asset, now)
    this.moveBillAssetEffect(this.bill, nextBill)
      .then(() => {
        return this.saveUpdatedBill(nextBill)
      })
      .then(() => {
        this.bill = nextBill
        this.showAssetPicker = false
        this.loadAssets()
        this.onUpdated()
      })
  }

  private saveUpdatedBill(nextBill: BillRecord): Promise<void> {
    return BillRecordStore.load(getContext(this))
      .then((records: BillRecord[]) => {
        const nextRecords: BillRecord[] = []
        for (let index = 0; index < records.length; index++) {
          if (records[index].id === nextBill.id) {
            nextRecords.push(nextBill)
          } else {
            nextRecords.push(records[index])
          }
        }
        return BillRecordStore.save(getContext(this), nextRecords)
      })
  }

  private moveBillAssetEffect(oldBill: BillRecord, nextBill: BillRecord): Promise<void> {
    return AssetAccountStore.load(getContext(this))
      .then((assets: AssetAccount[]) => {
        const nextAssets: AssetAccount[] = []
        let changed = false
        for (let index = 0; index < assets.length; index++) {
          const asset = assets[index]
          let nextBalance = asset.balance
          nextBalance = this.rollbackNormalBillBalance(asset, oldBill, nextBalance)
          nextBalance = this.applyNormalBillBalance(asset, nextBill, nextBalance)

          if (nextBalance !== asset.balance) {
            nextAssets.push(this.copyAssetWithBalance(asset, this.roundMoney(nextBalance)))
            changed = true
          } else {
            nextAssets.push(asset)
          }
        }

        if (!changed) {
          return Promise.resolve(undefined)
        }
        return AssetAccountStore.save(getContext(this), nextAssets)
      })
  }

  private rollbackNormalBillBalance(asset: AssetAccount, record: BillRecord, currentBalance: number): number {
    const assetId = record.assetId === undefined ? '' : record.assetId
    if (assetId.length === 0 || asset.id !== assetId) {
      return currentBalance
    }
    if (record.type === 'expense') {
      return currentBalance + record.amount
    }
    if (record.type === 'income') {
      return currentBalance - record.amount
    }
    return currentBalance
  }

  private applyNormalBillBalance(asset: AssetAccount, record: BillRecord, currentBalance: number): number {
    const assetId = record.assetId === undefined ? '' : record.assetId
    if (assetId.length === 0 || asset.id !== assetId) {
      return currentBalance
    }
    if (record.type === 'expense') {
      return currentBalance - record.amount
    }
    if (record.type === 'income') {
      return currentBalance + record.amount
    }
    return currentBalance
  }

  private copyBillWithDate(record: BillRecord, date: Date, updateTime: string): BillRecord {
    return {
      id: record.id,
      amount: record.amount,
      type: record.type,
      assetId: record.assetId,
      assetName: record.assetName,
      fromAssetId: record.fromAssetId,
      fromAssetName: record.fromAssetName,
      toAssetId: record.toAssetId,
      toAssetName: record.toAssetName,
      transferFee: record.transferFee,
      category: record.category,
      categoryId: record.categoryId,
      categoryName: record.categoryName,
      billDate: date.toISOString(),
      month: this.monthKey(date),
      remark: record.remark,
      createTime: record.createTime,
      updateTime: updateTime,
      isDeleted: record.isDeleted
    }
  }

  private copyBillWithAsset(record: BillRecord, asset: AssetAccount | undefined, updateTime: string): BillRecord {
    return {
      id: record.id,
      amount: record.amount,
      type: record.type,
      assetId: asset === undefined ? '' : asset.id,
      assetName: asset === undefined ? '' : asset.name,
      fromAssetId: record.fromAssetId,
      fromAssetName: record.fromAssetName,
      toAssetId: record.toAssetId,
      toAssetName: record.toAssetName,
      transferFee: record.transferFee,
      category: record.category,
      categoryId: record.categoryId,
      categoryName: record.categoryName,
      billDate: record.billDate,
      month: record.month,
      remark: record.remark,
      createTime: record.createTime,
      updateTime: updateTime,
      isDeleted: record.isDeleted
    }
  }

  private deleteBill() {
    if (!this.hasBill || this.bill.id.length === 0) {
      return
    }

    BillRecordStore.load(getContext(this))
      .then((records: BillRecord[]) => {
        return this.rollbackAssetBalance(this.bill)
          .then(() => {
            return this.markBillDeleted(records, this.bill.id)
          })
      })
      .then(() => {
        this.hasBill = false
        this.bill = EMPTY_BILL_RECORD
        this.onDeleted()
        this.onBack()
      })
  }

  private markBillDeleted(records: BillRecord[], billId: string): Promise<void> {
    const nextRecords: BillRecord[] = []
    const now = new Date().toISOString()
    for (let index = 0; index < records.length; index++) {
      const record = records[index]
      if (record.id === billId) {
        nextRecords.push({
          id: record.id,
          amount: record.amount,
          type: record.type,
          assetId: record.assetId,
          assetName: record.assetName,
          fromAssetId: record.fromAssetId,
          fromAssetName: record.fromAssetName,
          toAssetId: record.toAssetId,
          toAssetName: record.toAssetName,
          transferFee: record.transferFee,
          category: record.category,
          categoryId: record.categoryId,
          categoryName: record.categoryName,
          billDate: record.billDate,
          month: record.month,
          remark: record.remark,
          createTime: record.createTime,
          updateTime: now,
          isDeleted: true
        })
      } else {
        nextRecords.push(record)
      }
    }
    return BillRecordStore.save(getContext(this), nextRecords)
  }

  private rollbackAssetBalance(record: BillRecord): Promise<void> {
    const assetId = record.assetId === undefined ? '' : record.assetId
    const fromAssetId = record.fromAssetId === undefined ? '' : record.fromAssetId
    const toAssetId = record.toAssetId === undefined ? '' : record.toAssetId

    if (record.type !== 'transfer' && assetId.length === 0) {
      return Promise.resolve(undefined)
    }
    if (record.type === 'transfer' && (fromAssetId.length === 0 || toAssetId.length === 0)) {
      return Promise.resolve(undefined)
    }

    return AssetAccountStore.load(getContext(this))
      .then((assets: AssetAccount[]) => {
        const nextAssets: AssetAccount[] = []
        let changed = false
        for (let index = 0; index < assets.length; index++) {
          const asset = assets[index]
          const nextBalance = this.rollbackBalanceForAsset(asset, record)
          if (nextBalance !== asset.balance) {
            nextAssets.push(this.copyAssetWithBalance(asset, nextBalance))
            changed = true
          } else {
            nextAssets.push(asset)
          }
        }

        if (!changed) {
          return Promise.resolve(undefined)
        }
        return AssetAccountStore.save(getContext(this), nextAssets)
      })
  }

  private rollbackBalanceForAsset(asset: AssetAccount, record: BillRecord): number {
    if (record.type === 'expense' && record.assetId === asset.id) {
      return this.roundMoney(asset.balance + record.amount)
    }
    if (record.type === 'income' && record.assetId === asset.id) {
      return this.roundMoney(asset.balance - record.amount)
    }
    if (record.type === 'transfer') {
      const fee = record.transferFee === undefined ? 0 : record.transferFee
      if (record.fromAssetId === asset.id) {
        return this.roundMoney(asset.balance + record.amount + fee)
      }
      if (record.toAssetId === asset.id) {
        return this.roundMoney(asset.balance - record.amount)
      }
    }
    return asset.balance
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

  private billCategoryName(): string {
    if (!this.hasBill) {
      return ''
    }
    if (this.bill.type === 'transfer') {
      return '转账'
    }
    return this.bill.category.name.length > 0 ? this.bill.category.name : this.bill.categoryName
  }

  private amountText(): string {
    if (!this.hasBill) {
      return '0.00'
    }
    const prefix = this.bill.type === 'income' ? '+' : (this.bill.type === 'transfer' ? '' : '-')
    return prefix + this.bill.amount.toFixed(2)
  }

  private amountColor(): string {
    if (!this.hasBill) {
      return '#111111'
    }
    if (this.bill.type === 'income') {
      return '#55B8A7'
    }
    if (this.bill.type === 'expense') {
      return '#111111'
    }
    return '#666666'
  }

  private billTypeColor(): string {
    if (this.hasBill && this.bill.type === 'income') {
      return '#55B8A7'
    }
    return '#E65F5F'
  }

  private billAccountLabel(): string {
    if (this.hasBill && this.bill.type === 'transfer') {
      return '转账账户'
    }
    return '收支账户'
  }

  private accountIcon(): string {
    if (this.hasBill && this.bill.type === 'transfer') {
      return '转'
    }
    return '¥'
  }

  private accountText(): string {
    if (!this.hasBill) {
      return ''
    }
    if (this.bill.type === 'transfer') {
      const fromName = this.bill.fromAssetName !== undefined && this.bill.fromAssetName.length > 0 ?
        this.bill.fromAssetName : '无账户'
      const toName = this.bill.toAssetName !== undefined && this.bill.toAssetName.length > 0 ?
        this.bill.toAssetName : '无账户'
      return fromName + ' → ' + toName
    }
    if (this.bill.assetName !== undefined && this.bill.assetName.length > 0) {
      return this.bill.assetName
    }
    return '无账户'
  }

  private remarkText(): string {
    if (this.hasBill && this.bill.remark !== undefined && this.bill.remark.length > 0) {
      return this.bill.remark
    }
    return '无'
  }

  private billDateText(): string {
    if (!this.hasBill || this.bill.billDate.length === 0) {
      return ''
    }
    return this.formatDate(new Date(this.bill.billDate))
  }

  private createTimeText(): string {
    if (!this.hasBill || this.bill.createTime.length === 0) {
      return ''
    }
    return this.formatDate(new Date(this.bill.createTime))
  }

  private billDate(): Date {
    if (!this.hasBill || this.bill.billDate.length === 0) {
      return new Date()
    }
    return new Date(this.bill.billDate)
  }

  private formatDate(date: Date): string {
    return date.getFullYear().toString() + '年' + this.pad2(date.getMonth() + 1) + '月' +
    this.pad2(date.getDate()) + '日 ' + this.pad2(date.getHours()) + ':' + this.pad2(date.getMinutes())
  }

  private pad2(value: number): string {
    return value < 10 ? '0' + value.toString() : value.toString()
  }

  private monthKey(date: Date): string {
    return date.getFullYear().toString() + '-' + this.pad2(date.getMonth() + 1)
  }
}
