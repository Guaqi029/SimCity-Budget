import { AssetAccount, AssetTypeOption } from '../model/AssetAccount'
import { AssetMainPage } from '../components/asset/AssetMainPage'
import { AssetDetailFormPage } from '../components/asset/AssetDetailFormPage'
import { AssetTypeSection, AssetTypeSheet } from '../components/asset/AssetTypeSheet'

@Component
export struct AssetPage {
  @State private currentStep: string = 'list'
  @State private selectedOption: AssetTypeOption = {
    type: 'cash',
    group: 'fund',
    title: '现金',
    icon: '¥',
    color: '#F6C44F'
  }
  @State private assetName: string = ''
  @State private assetBalance: string = ''
  @State private assetShortName: string = ''
  @State private assetRemark: string = ''
  @State private assetCardNo: string = ''
  @State private includeInTotal: boolean = true
  @State private assets: AssetAccount[] = []

  private readonly sections: AssetTypeSection[] = [
    {
      title: '资金账户',
      options: [
        { type: 'cash', group: 'fund', title: '现金', icon: '¥', color: '#F6C44F' },
        { type: 'alipay', group: 'fund', title: '支付宝', icon: '支', color: '#22A7F2' },
        { type: 'wechat', group: 'fund', title: '微信钱包', icon: '微', color: '#14BF37' },
        { type: 'bank_card', group: 'fund', title: '银行卡', icon: '卡', color: '#F5BE22' },
        { type: 'qq_wallet', group: 'fund', title: 'QQ钱包', icon: 'Q', color: '#111111' },
        { type: 'jd_finance', group: 'fund', title: '京东金融', icon: '京', color: '#F04B37' },
        { type: 'custom', group: 'fund', title: '自定义', icon: '★', color: '#55B8A7' }
      ]
    },
    {
      title: '信贷账户',
      options: [
        { type: 'credit_card', group: 'credit', title: '信用卡', icon: '卡', color: '#C7CCD8' },
        { type: 'huabei', group: 'credit', title: '花呗', icon: '花', color: '#2B86F0' },
        { type: 'baitiao', group: 'credit', title: '白条', icon: '白', color: '#E95A64' },
        { type: 'custom', group: 'credit', title: '自定义', icon: '★', color: '#55B8A7' }
      ]
    },
    {
      title: '充值账户',
      options: [
        { type: 'member_card', group: 'stored_value', title: '会员卡', icon: '会', color: '#F7C739' },
        { type: 'bus_card', group: 'stored_value', title: '公交卡', icon: '交', color: '#66C26F' },
        { type: 'meal_card', group: 'stored_value', title: '饭卡', icon: '餐', color: '#F39A38' },
        { type: 'deposit', group: 'stored_value', title: '押金', icon: '押', color: '#2E8AF7' },
        { type: 'custom', group: 'stored_value', title: '自定义', icon: '★', color: '#55B8A7' }
      ]
    },
    {
      title: '投资理财',
      options: [
        { type: 'insurance', group: 'investment', title: '保险', icon: '保', color: '#178FD1' },
        { type: 'virtual_currency', group: 'investment', title: '虚拟货币', icon: 'B', color: '#D565D8' },
        { type: 'custom', group: 'investment', title: '自定义', icon: '★', color: '#55B8A7' }
      ]
    },
    {
      title: '二手货物',
      options: [
        { type: 'house', group: 'second_hand', title: '房子', icon: '房', color: '#ED5F65' },
        { type: 'car', group: 'second_hand', title: '车子', icon: '车', color: '#4DB5E8' },
        { type: 'custom', group: 'second_hand', title: '自定义', icon: '★', color: '#55B8A7' }
      ]
    },
    {
      title: '债务',
      options: [
        { type: 'payable', group: 'debt', title: '应付款/借入', icon: '付', color: '#FFC63D' },
        { type: 'receivable', group: 'debt', title: '应收款/借出', icon: '收', color: '#FFC63D' },
        { type: 'reimbursement', group: 'debt', title: '报销账户', icon: '报', color: '#2F86F6' }
      ]
    }
  ]

  build() {
    if (this.currentStep === 'detail') {
      AssetDetailFormPage({
        option: this.selectedOption,
        name: this.assetName,
        balance: this.assetBalance,
        shortName: this.assetShortName,
        remark: this.assetRemark,
        cardNo: this.assetCardNo,
        includeInTotal: this.includeInTotal,
        onBack: () => {
          this.currentStep = 'list'
        },
        onNameChange: (value: string) => {
          this.assetName = value
        },
        onBalanceChange: (value: string) => {
          this.assetBalance = value
        },
        onShortNameChange: (value: string) => {
          this.assetShortName = value
        },
        onRemarkChange: (value: string) => {
          this.assetRemark = value
        },
        onCardNoChange: (value: string) => {
          this.assetCardNo = value
        },
        onIncludeChange: () => {
          this.includeInTotal = !this.includeInTotal
        },
        onSave: () => {
          this.saveAsset()
        }
      })
    } else {
      Stack() {
        AssetMainPage({
          assets: this.assets,
          onAddAsset: () => {
            this.resetDraft()
            this.currentStep = 'type'
          }
        })

        if (this.currentStep === 'type') {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('#000000')
            .opacity(0.58)
            .onClick(() => {
              this.currentStep = 'list'
            })

          AssetTypeSheet({
            sections: this.sections,
            onSelect: (option: AssetTypeOption) => {
              this.selectType(option)
            }
          })
            .align(Alignment.Bottom)
            .transition(TransitionEffect.move(TransitionEdge.BOTTOM))
            .animation({ duration: 220, curve: Curve.EaseOut })
        }
      }
      .width('100%')
      .height('100%')
    }
  }

  private resetDraft() {
    this.selectedOption = this.sections[0].options[0]
    this.assetName = ''
    this.assetBalance = ''
    this.assetShortName = ''
    this.assetRemark = ''
    this.assetCardNo = ''
    this.includeInTotal = true
  }

  private selectType(option: AssetTypeOption) {
    this.selectedOption = option
    this.assetName = option.title
    this.assetShortName = option.title.length > 2 ? option.title.substring(0, 2) : option.title
    this.currentStep = 'detail'
  }

  private saveAsset() {
    const balance = Number(this.assetBalance)
    const now = new Date().toISOString()
    const name = this.assetName.trim()
    const shortName = this.assetShortName.trim()

    if (name.length === 0 || shortName.length === 0 || balance !== balance) {
      return
    }

    const nextAsset: AssetAccount = {
      id: 'asset_' + now,
      type: this.selectedOption.type,
      group: this.selectedOption.group,
      name: name,
      balance: balance,
      shortName: shortName,
      icon: this.selectedOption.icon,
      color: this.selectedOption.color,
      cardNo: this.assetCardNo.trim(),
      remark: this.assetRemark.trim(),
      includeInTotal: this.includeInTotal,
      bookScope: '全部账本',
      createTime: now,
      updateTime: now,
      isDeleted: false
    }

    this.assets = [nextAsset].concat(this.assets)
    this.currentStep = 'list'
  }
}
