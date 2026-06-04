import { PageHeader } from '../components/PageHeader'
import { SectionCard } from '../components/SectionCard'

@Component
export struct BillDetailPage {
  onBack: () => void = () => {}

  build() {
    Column({ space: 16 }) {
      PageHeader({
        eyebrow: 'BILL DETAIL',
        title: '账单详情',
        subtitle: '支持查看、编辑和删除当前账单的二级页面壳子'
      })
      SectionCard({ title: '账单金额', description: '餐饮 · 晚餐 · -¥35.00' })
      SectionCard({ title: '账单元信息', description: '日期、收支类型、备注、创建时间等字段后续在这里接入。' })

      Row({ space: 12 }) {
        Button('返回列表')
          .type(ButtonType.Capsule)
          .layoutWeight(1)
          .height(48)
          .fontColor('#FFFFFF')
          .backgroundColor('#111B33')
          .onClick(() => this.onBack())

        Button('删除账单')
          .type(ButtonType.Capsule)
          .layoutWeight(1)
          .height(48)
          .fontColor('#FFFFFF')
          .backgroundColor('#D65A6F')
      }
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
