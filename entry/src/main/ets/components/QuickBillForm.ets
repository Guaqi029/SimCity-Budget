@Component
export struct QuickBillForm {
  title: string = '快速记一笔'
  subtitle: string = '在独立页面完成记账，更符合常见使用习惯'
  submitLabel: string = '保存账单'

  build() {
    Column({ space: 18 }) {
      Row() {
        Column({ space: 6 }) {
          Text('QUICK ADD')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#9AA8C2')
            .letterSpacing(2)

          Text(this.title)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#18233A')

          Text(this.subtitle)
            .fontSize(13)
            .fontColor('#6B7A99')
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        Text('+')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2B6CB0')
          .width(54)
          .height(54)
          .textAlign(TextAlign.Center)
          .borderRadius(18)
          .backgroundColor('#DDEFFF')
      }
      .width('100%')

      Column({ space: 10 }) {
        Text('收支类型')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#24314A')

        Row({ space: 12 }) {
          Button('支出')
            .type(ButtonType.Capsule)
            .layoutWeight(1)
            .height(48)
            .fontColor('#FFFFFF')
            .backgroundColor('#111B33')

          Button('收入')
            .type(ButtonType.Capsule)
            .layoutWeight(1)
            .height(48)
            .fontColor('#24314A')
            .backgroundColor('#E6ECF5')
        }
      }
      .width('100%')

      Column({ space: 10 }) {
        Text('金额')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#24314A')

        Row() {
          Text('¥ 600')
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor('#18233A')

          Blank()

          Column({ space: 6 }) {
            Text('^')
              .fontSize(10)
              .fontColor('#7D8CA7')
            Text('v')
              .fontSize(10)
              .fontColor('#7D8CA7')
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 18, bottom: 18 })
        .borderRadius(24)
        .backgroundColor('#F5F8FC')
      }
      .width('100%')

      Column({ space: 10 }) {
        Text('消费类别')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#24314A')

        GridRow({ columns: 4, gutter: 12 }) {
          GridCol() {
            this.buildCategoryCard('餐饮', false)
          }
          GridCol() {
            this.buildCategoryCard('娱乐', true)
          }
          GridCol() {
            this.buildCategoryCard('学习', false)
          }
          GridCol() {
            this.buildCategoryCard('日用', false)
          }
          GridCol() {
            this.buildCategoryCard('交通', false)
          }
          GridCol() {
            this.buildCategoryCard('服饰', false)
          }
          GridCol() {
            this.buildCategoryCard('医疗', false)
          }
          GridCol() {
            this.buildCategoryCard('其他', false)
          }
        }
      }
      .width('100%')

      Row({ space: 12 }) {
        Column({ space: 10 }) {
          Text('日期')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#24314A')

          Row() {
            Text('2026/05/28')
              .fontSize(18)
              .fontColor('#18233A')
            Blank()
            Text('日期')
              .fontSize(14)
              .fontColor('#7D8CA7')
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 18, bottom: 18 })
          .borderRadius(20)
          .backgroundColor('#F5F8FC')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Column({ space: 10 }) {
          Text('备注')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#24314A')

          Text('游戏充值')
            .fontSize(18)
            .fontColor('#18233A')
            .width('100%')
            .padding({ left: 16, right: 16, top: 18, bottom: 18 })
            .borderRadius(20)
            .backgroundColor('#F5F8FC')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }

      Button(this.submitLabel)
        .type(ButtonType.Capsule)
        .width('100%')
        .height(56)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .backgroundColor('#111B33')
    }
    .alignItems(HorizontalAlign.Start)
    .padding(20)
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(30)
  }

  @Builder
  private buildCategoryCard(label: string, active: boolean) {
    Column({ space: 8 }) {
      Text(active ? '当前' : '分类')
        .fontSize(16)
        .fontColor(active ? '#FFFFFF' : '#7D8CA7')

      Text(label)
        .fontSize(15)
        .fontWeight(active ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(active ? '#FFFFFF' : '#4F5F7A')
    }
    .width('100%')
    .height(92)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(active ? '#111B33' : '#F5F8FC')
    .borderRadius(22)
  }
}
