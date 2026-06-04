import { PageHeader } from '../components/PageHeader'
import { QuickBillForm } from '../components/QuickBillForm'

@Component
export struct AddBillPage {
  onBack: () => void = () => {}

  build() {
    Column({ space: 16 }) {
      PageHeader({
        eyebrow: 'ADD BILL',
        title: '新增账单',
        subtitle: '独立页面完成一笔新的收入或支出记录'
      })

      QuickBillForm({
        title: '快速记一笔',
        subtitle: '这里先保留表单结构，后续再接入金额、类别、日期与保存逻辑',
        submitLabel: '保存账单并返回首页'
      })

      Button('返回首页')
        .type(ButtonType.Capsule)
        .width('100%')
        .height(50)
        .fontColor('#24314A')
        .backgroundColor('#EAF1F8')
        .onClick(() => this.onBack())
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
