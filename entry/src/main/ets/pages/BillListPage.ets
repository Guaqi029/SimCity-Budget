import { PageHeader } from '../components/PageHeader'
import { SectionCard } from '../components/SectionCard'

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

      Row({ space: 10 }) {
        this.buildFilterChip('2026-05')
        this.buildFilterChip('支出筛选')
        this.buildFilterChip('类别筛选')
      }
      .width('100%')

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

  @Builder
  private buildFilterChip(label: string) {
    Text(label)
      .fontSize(14)
      .fontColor('#24314A')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#EAF1F8')
      .borderRadius(20)
  }
}
