import { BottomTabBar, TabItem } from '../components/BottomTabBar'
import { HomePage } from './HomePage'
import { BillListPage } from './BillListPage'
import { AnalyticsPage } from './AnalyticsPage'
import { AccountPage } from './AccountPage'
import { AddBillPage } from './AddBillPage'
import { BillDetailPage } from './BillDetailPage'

@Entry
@Component
struct Index {
  @State currentTab: number = 0
  @State overlayPage: string = ''

  private readonly tabs: TabItem[] = [
    { label: '首页' },
    { label: '账单' },
    { label: '统计' },
    { label: '我的' }
  ]

  @Builder
  renderCurrentPage() {
    if (this.overlayPage === 'add') {
      AddBillPage({
        onBack: () => {
          this.overlayPage = ''
          this.currentTab = 0
        }
      })
    } else if (this.overlayPage === 'detail') {
      BillDetailPage({
        onBack: () => {
          this.overlayPage = ''
          this.currentTab = 1
        }
      })
    } else if (this.currentTab === 0) {
      HomePage({
        onAddBill: () => {
          this.overlayPage = 'add'
        },
        onOpenAccount: () => {
          this.currentTab = 3
        }
      })
    } else if (this.currentTab === 1) {
      BillListPage({
        onOpenDetail: () => {
          this.overlayPage = 'detail'
        }
      })
    } else if (this.currentTab === 2) {
      AnalyticsPage()
    } else {
      AccountPage()
    }
  }

  build() {
    Column() {
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

      if (this.overlayPage === '') {
        Column() {
          BottomTabBar({
            currentIndex: this.currentTab,
            items: this.tabs,
            onChange: (index: number) => {
              this.overlayPage = ''
              this.currentTab = index
            }
          })
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#EEF6FF')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
