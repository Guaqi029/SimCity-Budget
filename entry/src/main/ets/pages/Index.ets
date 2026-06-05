import { BottomTabBar, TabItem } from '../components/BottomTabBar'
import { HomePage } from './HomePage'
import { BillListPage } from './BillListPage'
import { AssetPage } from './AssetPage'
import { AnalyticsPage } from './AnalyticsPage'
import { AccountPage } from './AccountPage'
import { AddBillPage } from './AddBillPage'
import { BillDetailPage } from './BillDetailPage'
import { AssetTypeOption } from '../model/AssetAccount'
import { AssetTypeSheet } from '../components/asset/AssetTypeSheet'
import { ASSET_TYPE_SECTIONS, DEFAULT_ASSET_TYPE_OPTION } from '../components/asset/AssetTypeConfig'

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
        onBack: () => {
          // 关闭新增账单页后回到首页。
          this.overlayPage = ''
          this.currentTab = 0
        }
      })
    } else if (this.overlayPage === 'detail') {
      BillDetailPage({
        onBack: () => {
          // 关闭账单详情页后回到账单列表。
          this.overlayPage = ''
          this.currentTab = 1
        }
      })
    } else if (this.currentTab === 0) {
      HomePage({
        onAddBill: () => {
          // 新增账单是独立页面，不占用底部 Tab 的一个位置。
          this.overlayPage = 'add'
        },
        onOpenAccount: () => {
          this.currentTab = 4
        }
      })
    } else if (this.currentTab === 1) {
      BillListPage({
        onOpenDetail: () => {
          // 详情页同样作为覆盖页打开，避免改变当前 Tab 语义。
          this.overlayPage = 'detail'
        }
      })
    } else if (this.currentTab === 2) {
      AssetPage({
        selectedAssetTypeOption: this.selectedAssetTypeOption,
        selectedAssetTypeVersion: this.selectedAssetTypeVersion,
        onOpenAssetTypeSheet: () => {
          this.openAssetTypeSheet()
        }
      })
    } else if (this.currentTab === 3) {
      AnalyticsPage()
    } else {
      AccountPage()
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        // 主内容统一放在 Scroll 中，避免页面内容超过屏幕时被截断。
        Scroll() {
          Column() {
            this.renderCurrentPage()
          }
          .width('100%')
          .padding({
            left: 16,
            right: 16,
            top: 20,
            bottom: this.overlayPage === '' ? 24 : 20
          })
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)

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
}
