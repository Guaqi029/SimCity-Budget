import { AssetAccount, AssetTypeOption } from '../model/AssetAccount'
import { AssetMainPage } from '../components/asset/AssetMainPage'
import { AssetDetailFormPage } from '../components/asset/AssetDetailFormPage'
import { DEFAULT_ASSET_TYPE_OPTION } from '../components/asset/AssetTypeConfig'
import { TopMessageToast } from '../components/TopMessageToast'
import { AssetAccountStore } from '../storage/AssetAccountStore'

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
  @State private selectedAsset: AssetAccount = {
    id: '',
    type: 'custom',
    group: 'fund',
    name: '',
    balance: 0,
    shortName: '',
    icon: '',
    color: '#55B8A7',
    includeInTotal: true,
    bookScope: '全部账本',
    createTime: '',
    updateTime: '',
    isDeleted: false
  }
  @State private editingAssetId: string = ''
  @State private toastVisible: boolean = false
  @State private toastMessage: string = ''
  @State private toastVersion: number = 0

  // 记录已经消费过的父级选择版本，避免同一次选择被重复处理。
  @State private handledSelectedTypeVersion: number = 0
  @State private handledEditAssetRequestVersion: number = 0

  // Index 层的资产类型弹层选中结果。
  @Prop selectedAssetTypeOption: AssetTypeOption = DEFAULT_ASSET_TYPE_OPTION
  @Watch('onSelectedAssetTypeChanged') @Prop selectedAssetTypeVersion: number = 0

  // 从全屏资产详情页发起的编辑请求，由版本号保证每次点击都能被消费。
  @Prop editAssetRequest: AssetAccount = {
    id: '',
    type: 'custom',
    group: 'fund',
    name: '',
    balance: 0,
    shortName: '',
    icon: '',
    color: '#55B8A7',
    includeInTotal: true,
    bookScope: '全部账本',
    createTime: '',
    updateTime: '',
    isDeleted: false
  }
  @Watch('onEditAssetRequestChanged') @Prop editAssetRequestVersion: number = 0

  // 资产页只发起打开请求，弹层本体由 Index 托管，才能真正贴住屏幕底部。
  onOpenAssetTypeSheet: () => void = () => {}
  onOpenAssetDetail: (asset: AssetAccount) => void = () => {}
  onOpenBillDetail: (billId: string) => void = () => {}
  onAddBillFromAsset: (asset: AssetAccount) => void = () => {}
  onTransferFromAsset: (asset: AssetAccount) => void = () => {}

  aboutToAppear() {
    this.loadAssets()
    this.onEditAssetRequestChanged()
  }

  build() {
    if (this.currentStep === 'form') {
      Stack({ alignContent: Alignment.Top }) {
        AssetDetailFormPage({
          option: this.selectedOption,
          name: this.assetName,
          balance: this.assetBalance,
          shortName: this.assetShortName,
          remark: this.assetRemark,
          cardNo: this.assetCardNo,
          includeInTotal: this.includeInTotal,
          pageTitle: this.editingAssetId.length > 0 ? '编辑' + this.assetName + '账户' : '新增' + this.selectedOption.title + '账户',
          onBack: () => {
            this.currentStep = 'list'
          },
          onNameChange: (value: string) => {
            this.assetName = value
          },
          onBalanceChange: (value: string) => {
            this.updateBalance(value)
          },
          onBalanceInvalid: () => {
            this.showToast('余额最多只能输入两位小数')
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
        },
        onOpenAsset: (asset: AssetAccount) => {
          this.selectedAsset = asset
          this.onOpenAssetDetail(asset)
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
    this.editingAssetId = ''
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

  private onEditAssetRequestChanged() {
    if (this.editAssetRequestVersion <= this.handledEditAssetRequestVersion) {
      return
    }
    this.handledEditAssetRequestVersion = this.editAssetRequestVersion
    if (this.editAssetRequest.id.length === 0) {
      return
    }
    this.selectedAsset = this.editAssetRequest
    this.startEditAsset()
  }

  private selectType(option: AssetTypeOption) {
    this.selectedOption = option
    this.assetName = option.title
    this.assetShortName = ''
    this.editingAssetId = ''
    this.currentStep = 'form'
  }

  private updateBalance(value: string) {
    const sanitizedValue = this.sanitizeBalanceInput(value)
    if (sanitizedValue !== value) {
      this.assetBalance = sanitizedValue
      this.showToast('余额最多只能输入两位小数')
      return
    }
    this.assetBalance = sanitizedValue
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

    if (name.length === 0 || balance !== balance) {
      return
    }

    const nextAsset: AssetAccount = {
      id: this.editingAssetId.length > 0 ? this.editingAssetId : 'asset_' + now,
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
      createTime: this.editingAssetId.length > 0 ? this.findCreateTime(this.editingAssetId) : now,
      updateTime: now,
      isDeleted: false
    }

    const nextAssets = this.editingAssetId.length > 0 ? this.replaceAsset(nextAsset) : [nextAsset].concat(this.assets)
    AssetAccountStore.save(getContext(this), nextAssets)
      .then(() => {
        this.assets = nextAssets
        this.selectedAsset = nextAsset
        this.editingAssetId = ''
        this.currentStep = 'list'
        this.onOpenAssetDetail(nextAsset)
      })
      .catch(() => {
        this.showToast('资产账户保存失败')
      })
  }

  private loadAssets() {
    AssetAccountStore.load(getContext(this))
      .then((assets: AssetAccount[]) => {
        this.assets = assets
      })
      .catch(() => {
        this.showToast('资产账户读取失败')
      })
  }

  // 余额允许为负数，但小数部分最多保留两位；第三位小数会被直接截断。
  private sanitizeBalanceInput(value: string): string {
    let result = ''
    let hasDot = false

    for (let index = 0; index < value.length; index++) {
      const char = value.charAt(index)

      if (char >= '0' && char <= '9') {
        result += char
      } else if (char === '-' && result.length === 0) {
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

  private startEditAsset() {
    if (this.selectedAsset.id.length === 0) {
      return
    }

    this.selectedOption = {
      type: this.selectedAsset.type,
      group: this.selectedAsset.group,
      title: this.selectedAsset.name,
      icon: this.selectedAsset.icon,
      color: this.selectedAsset.color
    }
    this.assetName = this.selectedAsset.name
    this.assetBalance = String(this.selectedAsset.balance)
    this.assetShortName = this.selectedAsset.shortName
    this.assetRemark = this.selectedAsset.remark === undefined ? '' : this.selectedAsset.remark
    this.assetCardNo = this.selectedAsset.cardNo === undefined ? '' : this.selectedAsset.cardNo
    this.includeInTotal = this.selectedAsset.includeInTotal
    this.editingAssetId = this.selectedAsset.id
    this.currentStep = 'form'
  }

  private deleteSelectedAsset() {
    if (this.selectedAsset.id.length === 0) {
      return
    }

    const targetId = this.selectedAsset.id
    const nextAssets: AssetAccount[] = []
    for (let index = 0; index < this.assets.length; index++) {
      if (this.assets[index].id !== targetId) {
        nextAssets.push(this.assets[index])
      }
    }

    AssetAccountStore.save(getContext(this), nextAssets)
      .then(() => {
        this.assets = nextAssets
        this.selectedAsset = this.emptyAsset()
        this.currentStep = 'list'
      })
      .catch(() => {
        this.showToast('资产账户删除失败')
      })
  }

  private replaceAsset(asset: AssetAccount): AssetAccount[] {
    const nextAssets: AssetAccount[] = []
    for (let index = 0; index < this.assets.length; index++) {
      if (this.assets[index].id === asset.id) {
        nextAssets.push(asset)
      } else {
        nextAssets.push(this.assets[index])
      }
    }
    return nextAssets
  }

  private findCreateTime(assetId: string): string {
    for (let index = 0; index < this.assets.length; index++) {
      if (this.assets[index].id === assetId) {
        return this.assets[index].createTime
      }
    }
    return new Date().toISOString()
  }

  private emptyAsset(): AssetAccount {
    return {
      id: '',
      type: 'custom',
      group: 'fund',
      name: '',
      balance: 0,
      shortName: '',
      icon: '',
      color: '#55B8A7',
      includeInTotal: true,
      bookScope: '全部账本',
      createTime: '',
      updateTime: '',
      isDeleted: false
    }
  }
}
