import { PageHeader } from '../components/PageHeader'
import { SectionCard } from '../components/SectionCard'

@Component
export struct AccountPage {
  build() {
    Column({ space: 16 }) {
      PageHeader({
        eyebrow: 'ACCOUNT',
        title: '我的',
        subtitle: '账号管理、登录注册原型与预算设置统一放在本页'
      })

      Column({ space: 14 }) {
        Text('账号状态')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#18233A')

        Row({ space: 10 }) {
          Button('登录')
            .type(ButtonType.Capsule)
            .layoutWeight(1)
            .height(44)
            .fontColor('#FFFFFF')
            .backgroundColor('#111B33')

          Button('注册')
            .type(ButtonType.Capsule)
            .layoutWeight(1)
            .height(44)
            .fontColor('#24314A')
            .backgroundColor('#EAF1F8')
        }

        this.buildInputShell('用户名', 'simcity_player')
        this.buildInputShell('邮箱', 'budget@demo.local')
        this.buildInputShell('密码', '******')

        Button('登录 / 注册按钮占位')
          .type(ButtonType.Capsule)
          .width('100%')
          .height(50)
          .fontColor('#FFFFFF')
          .backgroundColor('#2A5CAA')
      }
      .width('100%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(28)
      .alignItems(HorizontalAlign.Start)

      Column({ space: 14 }) {
        Text('预算设置')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#18233A')

        this.buildInputShell('月总预算', '¥ 2000.00')
        this.buildInputShell('餐饮预算', '¥ 800.00')
        this.buildInputShell('娱乐预算', '¥ 300.00')
        this.buildInputShell('学习预算', '¥ 300.00')
        this.buildInputShell('日用预算', '¥ 400.00')

        Button('保存预算配置')
          .type(ButtonType.Capsule)
          .width('100%')
          .height(50)
          .fontColor('#FFFFFF')
          .backgroundColor('#111B33')
      }
      .width('100%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(28)
      .alignItems(HorizontalAlign.Start)

      SectionCard({
        title: '后续协作接口',
        description: '这里后续接入 Preferences / 数据库、登录校验、账号持久化与预算保存逻辑。'
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildInputShell(label: string, value: string) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#6B7A99')

      Text(value)
        .fontSize(17)
        .fontColor('#18233A')
        .width('100%')
        .padding({ left: 16, right: 16, top: 14, bottom: 14 })
        .backgroundColor('#F5F8FC')
        .borderRadius(18)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
