import { BottomTabBar, TabItem } from '../components/BottomTabBar'
import { HomePage } from './HomePage'
import { BillListPage } from './BillListPage'
import { AssetPage } from './AssetPage'
import { AnalyticsPage } from './Statistic/AnalyticsPage'
import { AccountPage } from './AccountPage'
import { AddBillPage } from './AddBillPage'
import { BillDetailPage } from './BillDetailPage'
import { BudgetPage } from './BudgetPage'
import { AssetAccount, AssetTypeOption } from '../model/AssetAccount'
import { AssetAccountDetailPage } from '../components/asset/AssetAccountDetailPage'
import { AssetTypeSheet } from '../components/asset/AssetTypeSheet'
import { ASSET_TYPE_SECTIONS, DEFAULT_ASSET_TYPE_OPTION } from '../components/asset/AssetTypeConfig'
import { AssetAccountStore } from '../storage/AssetAccountStore'

type AddBillInitialMode = 'expense' | 'transfer'

@Entry
@Component
struct Index {
  // 当前选中的底部 Tab，下标与 tabs 数组保持一致。
  @State currentTab: number = 0

  // 临时覆盖当前 Tab 的独立页面；为空时展示普通 Tab 页面。
  @State overlayPage: string = ''

  // 资产类型选择弹层提升到 Index 层，定位参考就是整屏 Stack，可以贴到屏幕底部。
  @State showAssetTypeSheet: boolean = false
  @State assetTypeSheetVisible: boolean = false

  // 通过“选中项 + 版本号”把弹层选择结果传回 AssetPage。
  @State selectedAssetTypeOption: AssetTypeOption = DEFAULT_ASSET_TYPE_OPTION
  @State selectedAssetTypeVersion: number = 0
  @State billRefreshVersion: number = 0
  @State homeRefreshVersion: number = 0
  @State selectedBillId: string = ''
  @State addBillInitialMode: AddBillInitialMode = 'expense'
  @State addBillInitialAssetId: string = ''
  @State addBillInitialAssetName: string = ''
  @State addBillBackTab: number = 0
  @State selectedAssetForDetail: AssetAccount = {
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
  @State editAssetRequest: AssetAccount = {
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
  @State editAssetRequestVersion: number = 0

  // 底部导航配置：中间的“资产”是主功能入口之一。
  private readonly tabs: TabItem[] = [
    { label: '首页', icon: $r('app.media.home'), selectedIcon: $r('app.media.home_selected') },
    { label: '账单', icon: $r('app.media.calendar'), selectedIcon: $r('app.media.calendar_selected') },
    { label: '资产', icon: $r('app.media.wallet'), selectedIcon: $r('app.media.wallet_selected') },
    { label: '统计', icon: $r('app.media.calculate'), selectedIcon: $r('app.media.calculate_selected') },
    { label: '我的', icon: $r('app.media.my'), selectedIcon: $r('app.media.my_selected') }
  ]

  @Builder
  renderCurrentPage() {
    // overlayPage 优先级高于 currentTab，用于从任意 Tab 临时打开独立流程页。
    if (this.overlayPage === 'add') {
      AddBillPage({
        initialMode: this.addBillInitialMode,
        initialAssetId: this.addBillInitialAssetId,
        initialAssetName: this.addBillInitialAssetName,
        onSaved: () => {
          this.billRefreshVersion += 1
        },
        onBack: () => {
          // 关闭新增账单页后回到发起入口所在的 Tab。
          this.overlayPage = ''
          this.currentTab = this.addBillBackTab
          this.resetAddBillInitialState()
        }
      })
    } else if (this.overlayPage === 'detail') {
      BillDetailPage({
        billId: this.selectedBillId,
        onDeleted: () => {
          this.billRefreshVersion += 1
          this.selectedBillId = ''
        },
        onUpdated: () => {
          this.billRefreshVersion += 1
        },
        onBack: () => {
          // 关闭账单详情页后回到账单列表。
          this.overlayPage = ''
        }
      })
    } else if (this.overlayPage === 'assetDetail') {
      AssetAccountDetailPage({
        asset: this.selectedAssetForDetail,
        onBack: () => {
          this.closeAssetDetailPage()
        },
        onEdit: () => {
          this.requestEditAsset()
        },
        onDelete: () => {
          this.deleteSelectedAssetFromDetail()
        },
        onOpenBill: (billId: string) => {
          this.selectedBillId = billId
          this.overlayPage = 'detail'
        },
        onAddBill: (asset: AssetAccount) => {
          this.openAddBillPage('expense', asset, 2)
        },
        onTransfer: (asset: AssetAccount) => {
          this.openAddBillPage('transfer', asset, 2)
        }
      })
    } else if (this.overlayPage === 'budget') {
      BudgetPage({
        onBack: () => {
          this.overlayPage = ''
          this.refreshHomeAfterOverlayClosed()
        },
        onChanged: () => {
          this.homeRefreshVersion += 1
        }
      })
    } else if (this.currentTab === 0) {
      HomePage({
        billRefreshVersion: this.billRefreshVersion,
        homeRefreshVersion: this.homeRefreshVersion,
        onAddBill: () => {
          // 新增账单是独立页面，不占用底部 Tab 的一个位置。
          this.openAddBillPage('expense', undefined, 0)
        },
        onOpenAccount: () => {
          this.currentTab = 4
        },
        onOpenBillDetail: (billId: string) => {
          this.selectedBillId = billId
          this.overlayPage = 'detail'
        },
        onOpenBudget: () => {
          this.overlayPage = 'budget'
        }
      })
    } else if (this.currentTab === 1) {
      BillListPage({
        // 把新增/删除账单后的刷新信号继续传给账单明细页。
        billRefreshVersion: this.billRefreshVersion,
        onOpenDetail: (billId: string) => {
          // 详情页同样作为覆盖页打开，避免改变当前 Tab 语义。
          this.selectedBillId = billId
          this.overlayPage = 'detail'
        }
      })
    } else if (this.currentTab === 2) {
      AssetPage({
        selectedAssetTypeOption: this.selectedAssetTypeOption,
        selectedAssetTypeVersion: this.selectedAssetTypeVersion,
        editAssetRequest: this.editAssetRequest,
        editAssetRequestVersion: this.editAssetRequestVersion,
        onOpenAssetTypeSheet: () => {
          this.openAssetTypeSheet()
        },
        onOpenAssetDetail: (asset: AssetAccount) => {
          this.openAssetDetailPage(asset)
        },
        onOpenBillDetail: (billId: string) => {
          this.selectedBillId = billId
          this.overlayPage = 'detail'
        },
        onAddBillFromAsset: (asset: AssetAccount) => {
          this.openAddBillPage('expense', asset, 2)
        },
        onTransferFromAsset: (asset: AssetAccount) => {
          this.openAddBillPage('transfer', asset, 2)
        }
      })
    } else if (this.currentTab === 3) {
      // 新增：把账单刷新版本号继续传给统计页。
      // 原因：统计页现在已经有多个组件直接读取本地账单数据，
      // 所以它也需要和首页、账单页一样，在账单变化后收到统一刷新信号。
      // 新增功能：统计图表在新增/删除账单后可以重新读取本地存储并刷新展示。
      AnalyticsPage({
        billRefreshVersion: this.billRefreshVersion
      })
    } else {
      AccountPage()
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        if (this.overlayPage === '') {
          if (this.currentTab === 0) {
            // 首页内部有自己的 Scroll 和悬浮添加按钮，避免全局浮层遮挡 TabBar。
            Column() {
              this.renderCurrentPage()
            }
            .width('100%')
            .layoutWeight(1)
          } else {
            // 其他普通 Tab 页面继续由 Index 提供统一滚动容器。
            Scroll() {
              Column() {
                this.renderCurrentPage()
              }
              .width('100%')
              .padding({
                left: 16,
                right: 16,
                top: 20,
                bottom: 24
              })
            }
            .scrollBar(BarState.Off)
            .layoutWeight(1)
          }
        } else {
          // 覆盖页使用完整屏幕，新增账单页的底部键盘才能贴近屏幕底部。
          Column() {
            this.renderCurrentPage()
          }
          .width('100%')
          .height('100%')
        }

        // 覆盖页打开时隐藏底部导航，让新增/详情流程更像完整页面。
        if (this.overlayPage === '') {
          Column() {
            BottomTabBar({
              currentIndex: this.currentTab,
              items: this.tabs,
              onChange: (index: number) => {
                this.closeAssetTypeSheet()
                this.overlayPage = ''
                this.currentTab = index
              }
            })
          }
          .width('100%')
        }
      }
      .width('100%')
      .height('100%')

      if (this.showAssetTypeSheet) {
        // 全屏遮罩同样放在 Index 层，避免被某个页面内部布局裁剪。
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#000000')
          .opacity(0.58)
          .onClick(() => {
            this.closeAssetTypeSheet()
          })

        AssetTypeSheet({
          sections: ASSET_TYPE_SECTIONS,
          onSelect: (option: AssetTypeOption) => {
            this.selectAssetType(option)
          }
        })
        .width('100%')
        .align(Alignment.Bottom)
        .translate({ y: this.assetTypeSheetVisible ? 0 : 620 })
        .opacity(this.assetTypeSheetVisible ? 1 : 0)
        .animation({ duration: 260, curve: Curve.EaseOut })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#EEF6FF')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  private openAssetTypeSheet() {
    this.showAssetTypeSheet = true
    this.assetTypeSheetVisible = false
    setTimeout(() => {
      this.assetTypeSheetVisible = true
    }, 20)
  }

  private closeAssetTypeSheet() {
    if (!this.showAssetTypeSheet) {
      return
    }
    this.assetTypeSheetVisible = false
    setTimeout(() => {
      if (!this.assetTypeSheetVisible) {
        this.showAssetTypeSheet = false
      }
    }, 260)
  }

  private selectAssetType(option: AssetTypeOption) {
    this.selectedAssetTypeOption = option
    this.selectedAssetTypeVersion += 1
    this.closeAssetTypeSheet()
  }

  private openAddBillPage(mode: AddBillInitialMode, asset: AssetAccount | undefined, backTab: number) {
    this.addBillInitialMode = mode
    this.addBillInitialAssetId = asset === undefined ? '' : asset.id
    this.addBillInitialAssetName = asset === undefined ? '' : (asset.shortName.length > 0 ? asset.shortName : asset.name)
    this.addBillBackTab = backTab
    this.overlayPage = 'add'
  }

  private resetAddBillInitialState() {
    this.addBillInitialMode = 'expense'
    this.addBillInitialAssetId = ''
    this.addBillInitialAssetName = ''
    this.addBillBackTab = 0
  }

  private refreshHomeAfterOverlayClosed() {
    setTimeout(() => {
      this.homeRefreshVersion += 1
    }, 0)
  }

  private openAssetDetailPage(asset: AssetAccount) {
    this.currentTab = 2
    this.selectedAssetForDetail = asset
    this.overlayPage = 'assetDetail'
  }

  private closeAssetDetailPage() {
    this.overlayPage = ''
    this.selectedAssetForDetail = this.emptyAsset()
  }

  private requestEditAsset() {
    if (this.selectedAssetForDetail.id.length === 0) {
      return
    }
    this.editAssetRequest = this.selectedAssetForDetail
    this.editAssetRequestVersion += 1
    this.overlayPage = ''
    this.currentTab = 2
  }

  private deleteSelectedAssetFromDetail() {
    if (this.selectedAssetForDetail.id.length === 0) {
      return
    }

    const targetId = this.selectedAssetForDetail.id
    AssetAccountStore.load(getContext(this))
      .then((assets: AssetAccount[]) => {
        const nextAssets: AssetAccount[] = []
        for (let index = 0; index < assets.length; index++) {
          if (assets[index].id !== targetId) {
            nextAssets.push(assets[index])
          }
        }
        return AssetAccountStore.save(getContext(this), nextAssets)
      })
      .then(() => {
        this.closeAssetDetailPage()
      })
      .catch(() => {
        this.closeAssetDetailPage()
      })
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
