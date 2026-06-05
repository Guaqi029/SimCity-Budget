import { BillRecord } from '../model/BillRecord'
import { AssetAccount } from '../model/AssetAccount'
import { AssetAccountStore } from '../storage/AssetAccountStore'
import { BillRecordStore } from '../storage/BillRecordStore'

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
  onBack: () => void = () => {}
  onDeleted: () => void = () => {}

  aboutToAppear() {
    this.loadBill()
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column() {
        this.topBar()

        if (!this.hasBill) {
          this.emptyState()
        } else {
          Stack({ alignContent: Alignment.Bottom }) {
            Scroll() {
              Column({ space: 12 }) {
                this.summaryCard()
                this.detailCard()
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 18, bottom: 96 })
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .height('100%')
            .scrollBar(BarState.Off)

            this.bottomActions()
          }
          .layoutWeight(1)
          .width('100%')
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F3F3F3')

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
    }
    .width('100%')
    .height('100%')
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
          .fontSize(24)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111111')
          .margin({ left: 22 })

        Blank()

        Image($r('app.media.more_col'))
          .width(28)
          .height(28)
          .objectFit(ImageFit.Contain)
          .onClick(() => {
            this.showMenu = !this.showMenu
          })
      }
      .width('100%')
      .height(73)
      .padding({ left: 20, right: 20, top: 8 })

      Column()
        .width('100%')
        .height(1)
        .backgroundColor('#E7E7E7')
    }
    .width('100%')
    .height(74)
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
  }

  @Builder
  private summaryCard() {
    Row({ space: 18 }) {
      Text(this.billIcon())
        .width(36)
        .height(36)
        .fontSize(19)
        .fontColor('#3D5752')
        .textAlign(TextAlign.Center)
        .padding({ top: 7 })
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
      this.infoRow('账单日期', this.billDateText())
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
        .height(54)
        .fontSize(18)
        .fontColor('#FFFFFF')
        .backgroundColor('#55B8A7')
        .borderRadius(8)

      Button('编辑')
        .type(ButtonType.Normal)
        .layoutWeight(1)
        .height(54)
        .fontSize(18)
        .fontColor('#FFFFFF')
        .backgroundColor('#55B8A7')
        .borderRadius(8)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
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
          this.deleteBill()
        }
      })
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
    return this.bill.categoryName
  }

  private billIcon(): string {
    if (!this.hasBill) {
      return ''
    }
    if (this.bill.type === 'income') {
      return '收'
    }
    if (this.bill.type === 'transfer') {
      return '转'
    }
    return this.bill.categoryName.length > 0 ? this.bill.categoryName.substring(0, 1) : '支'
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

  private formatDate(date: Date): string {
    return date.getFullYear().toString() + '年' + this.pad2(date.getMonth() + 1) + '月' +
    this.pad2(date.getDate()) + '日 ' + this.pad2(date.getHours()) + ':' + this.pad2(date.getMinutes())
  }

  private pad2(value: number): string {
    return value < 10 ? '0' + value.toString() : value.toString()
  }
}
