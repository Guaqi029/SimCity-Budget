import { AssetAccount, AssetTypeOption } from '../model/AssetAccount'
import { AssetMainPage } from '../components/asset/AssetMainPage'
import { AssetDetailFormPage } from '../components/asset/AssetDetailFormPage'
import { DEFAULT_ASSET_TYPE_OPTION } from '../components/asset/AssetTypeConfig'
import { TopMessageToast } from '../components/TopMessageToast'

@Component
export struct AssetPage {
  @State private currentStep: string = 'list'
  @State private selectedOption: AssetTypeOption = DEFAULT_ASSET_TYPE_OPTION
  @State private assetName: string = ''
  @State private assetBalance: string = ''
  @State private assetShortName: string = ''
  @State private assetRemark: string = ''
  @State private assetCardNo: string = ''
  @State private includeInTotal: boolean = true
  @State private assets: AssetAccount[] = []
  @State private toastVisible: boolean = false
  @State private toastMessage: string = ''
  @State private toastVersion: number = 0

  // 记录已经消费过的父级选择版本，避免同一次选择被重复处理。
  @State private handledSelectedTypeVersion: number = 0

  // Index 层的资产类型弹层选中结果。
  @Prop selectedAssetTypeOption: AssetTypeOption = DEFAULT_ASSET_TYPE_OPTION
  @Watch('onSelectedAssetTypeChanged') @Prop selectedAssetTypeVersion: number = 0

  // 资产页只发起打开请求，弹层本体由 Index 托管，才能真正贴住屏幕底部。
  onOpenAssetTypeSheet: () => void = () => {}

  build() {
    if (this.currentStep === 'detail') {
      Stack({ alignContent: Alignment.Top }) {
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
            this.updateBalance(value)
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

        TopMessageToast({
          visible: this.toastVisible,
          message: this.toastMessage
        })
        .margin({ top: 8 })
      }
      .width('100%')
    } else {
      AssetMainPage({
        assets: this.assets,
        onAddAsset: () => {
          this.resetDraft()
          this.onOpenAssetTypeSheet()
        }
      })
    }
  }

  private resetDraft() {
    this.selectedOption = DEFAULT_ASSET_TYPE_OPTION
    this.assetName = ''
    this.assetBalance = ''
    this.assetShortName = ''
    this.assetRemark = ''
    this.assetCardNo = ''
    this.includeInTotal = true
    this.toastVisible = false
    this.toastMessage = ''
    this.toastVersion += 1
  }

  private onSelectedAssetTypeChanged() {
    if (this.selectedAssetTypeVersion <= this.handledSelectedTypeVersion) {
      return
    }
    this.handledSelectedTypeVersion = this.selectedAssetTypeVersion
    this.selectType(this.selectedAssetTypeOption)
  }

  private selectType(option: AssetTypeOption) {
    this.selectedOption = option
    this.assetName = option.title
    this.assetShortName = option.title.length > 2 ? option.title.substring(0, 2) : option.title
    this.currentStep = 'detail'
  }

  private updateBalance(value: string) {
    if (this.hasMoreThanTwoDecimalPlaces(value)) {
      this.showToast('余额最多只能输入两位小数')
      return
    }
    this.assetBalance = value
  }

  private saveAsset() {
    if (this.hasMoreThanTwoDecimalPlaces(this.assetBalance)) {
      this.showToast('余额最多只能输入两位小数')
      return
    }

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

  private hasMoreThanTwoDecimalPlaces(value: string): boolean {
    const dotIndex = value.indexOf('.')
    if (dotIndex < 0) {
      return false
    }
    return value.substring(dotIndex + 1).length > 2
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
    }, 1800)
  }
}
