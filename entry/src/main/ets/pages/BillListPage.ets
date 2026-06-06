import { PageHeader } from '../components/PageHeader'
import { SectionCard } from '../components/SectionCard'
import { BillDatePicker, BillDatePickerValue } from '../components/bill/BillDatePicker'

interface BillGroupItem {
  category: string
  remark: string
  amount: string
}

interface BillGroup {
  date: string
  items: BillGroupItem[]
}

@Component
export struct BillListPage {
  // 新增：账单明细页自己维护当前选中的年月日，
  // 因为顶部筛选 chip 已被替换为可交互日历，需要有页面级状态接收日历回调。
  @State private selectedYear: number = 2026
  @State private selectedMonth: number = 4
  @State private selectedDay: number = 28
  onOpenDetail: () => void = () => {}

  private readonly groups: BillGroup[] = [
    {
      date: '2026-05-28',
      items: [
        { category: '餐饮', remark: '晚餐', amount: '-¥35.00' },
        { category: '交通', remark: '地铁', amount: '-¥18.00' }
      ]
    },
    {
      date: '2026-05-27',
      items: [
        { category: '学习', remark: '资料书', amount: '-¥128.00' },
        { category: '收入', remark: '兼职收入', amount: '+¥1200.00' }
      ]
    }
  ]

  build() {
    Column({ space: 16 }) {
      PageHeader({
        eyebrow: 'BILL LIST',
        title: '账单明细',
        subtitle: '按时间流展示当月全部收支记录，并预留详情入口'
      })

      // 这里删除了原来的“月份 / 支出筛选 / 类别筛选”三个占位 chip。
      // 删除原因：当前这一步的目标是优先把“顶部日历显示”复用现有组件做出来，
      // 比起继续保留占位筛选，更需要先让账单页具备真实可见的月历结构。
      // 新增功能：直接复用现有 BillDatePicker 作为内嵌月历，先完成顶部日历展示。
      BillDatePicker({
        embeddedMode: true,
        year: this.selectedYear,
        month: this.selectedMonth,
        day: this.selectedDay,
        hour: 0,
        minute: 0,
        onValueChange: (value: BillDatePickerValue) => {
          // 新增：接收内嵌日历的实时回调，先把用户当前选中的年月日存到页面状态里。
          // 这一轮先只做显示，后续再继续把这个状态真正联动到账单列表筛选。
          this.selectedYear = value.year
          this.selectedMonth = value.month
          this.selectedDay = value.day
        }
      })

      ForEach(this.groups, (group: BillGroup) => {
        Column({ space: 10 }) {
          Text(group.date)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#6B7A99')

          ForEach(group.items, (item: BillGroupItem) => {
            Row() {
              Column({ space: 4 }) {
                Text(item.category + ' · ' + item.remark)
                  .fontSize(17)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#18233A')

                Text('长按可编辑 / 删除，点击进入详情页')
                  .fontSize(12)
                  .fontColor('#95A2BC')
              }
              .alignItems(HorizontalAlign.Start)

              Blank()

              Text(item.amount)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(item.amount.startsWith('+') ? '#24A06B' : '#18233A')
            }
            .width('100%')
            .padding(18)
            .backgroundColor('#FFFFFF')
            .borderRadius(24)
            .onClick(() => this.onOpenDetail())
          }, (item: BillGroupItem) => item.category + item.remark + item.amount)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }, (group: BillGroup) => group.date)

      SectionCard({
        title: '后续协作接口',
        description: '这里后续接入数据库分页、筛选条件、账单编辑、删除和详情跳转逻辑。'
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

}
