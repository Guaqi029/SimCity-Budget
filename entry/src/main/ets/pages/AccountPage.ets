interface ShortcutItem {
  icon: string
  title: string
}

interface SettingItem {
  icon: string
  title: string
  subtitle?: string
  value?: string
}

@Component
export struct AccountPage {
  // 个人页快捷入口，按截图保持 4 列 2 行。
  private readonly shortcutItems: ShortcutItem[] = [
    { icon: 'A', title: '自动记账' },
    { icon: '日', title: '周期记账' },
    { icon: '愿', title: '愿望清单' },
    { icon: '词', title: '分类关键词' },
    { icon: '本', title: '账本管理' },
    { icon: '签', title: '标签管理' },
    { icon: '类', title: '分类管理' },
    { icon: '设', title: '更多设置' }
  ]

  // 分组列表数据单独维护，后续可替换为真实账号/同步状态。
  private readonly dataItems: SettingItem[] = [
    { icon: '☁', title: '云同步', subtitle: '已同步1216条账单', value: '已开启' },
    { icon: '▣', title: '数据备份' },
    { icon: '⇅', title: '导入导出' }
  ]

  private readonly otherItems: SettingItem[] = [
    { icon: '衣', title: '主题外观' },
    { icon: '拼', title: '桌面小部件' },
    { icon: '?', title: '使用手册' }
  ]

  build() {
    Column({ space: 18 }) {
      ProfileHero()
      ShortcutPanel({ items: this.shortcutItems })
      SettingSection({ title: '数据管理', items: this.dataItems })
      SettingSection({ title: '其他', items: this.otherItems })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}

@Component
struct ProfileHero {
  build() {
    Stack({ alignContent: Alignment.Top }) {
      // 浅绿色背景和漂浮圆点模拟截图顶部的轻量插画背景。
      Column()
        .width('100%')
        .height(270)
        .backgroundColor('#D7EFEC')
        .borderRadius({ bottomLeft: 26, bottomRight: 26 })

      Circle()
        .width(64)
        .height(64)
        .fill('#ECFAF8')
        .opacity(0.75)
        .margin({ top: 22, left: -28 })
        .align(Alignment.TopStart)

      Circle()
        .width(52)
        .height(52)
        .fill('#F5FFFD')
        .opacity(0.85)
        .margin({ top: 78, right: -22 })
        .align(Alignment.TopEnd)

      Column()
        .width('100%')
        .height(176)
        .margin({ top: 92 })
        .backgroundColor('#F9FFFF')
        .borderRadius(18)

      DecorativeLeaves()
        .width('100%')
        .height(104)
        .margin({ top: 164 })

      Column({ space: 14 }) {
        AvatarBadge()

        Text('鱼受')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#55B8A7')

        Column({ space: 8 }) {
          Text('坚持记账的第 660 天')
            .fontSize(16)
            .fontColor('#6E7078')
          Text('已记录 1216 条账单')
            .fontSize(16)
            .fontColor('#6E7078')
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .margin({ top: 28 })
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height(270)
  }
}

@Component
struct AvatarBadge {
  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      // 当前项目没有真实头像资源，使用启动图做圆形头像占位。
      Image($r('app.media.icon'))
        .width(92)
        .height(92)
        .borderRadius(46)
        .objectFit(ImageFit.Cover)

      Text('♛')
        .fontSize(16)
        .fontColor('#F5D04A')
        .textAlign(TextAlign.Center)
        .width(28)
        .height(28)
        .padding({ top: 4 })
        .backgroundColor('#222222')
        .borderRadius(14)
        .border({ width: 2, color: '#F9FFFF' })
    }
    .width(96)
    .height(96)
  }
}

@Component
struct DecorativeLeaves {
  build() {
    Row() {
      Stack({ alignContent: Alignment.BottomStart }) {
        this.leaf('#67A878', 86, 44, -18)
        this.leaf('#2F7E72', 62, 34, 30)
        this.leaf('#9CCB75', 46, 24, 58)
        Text('✿')
          .fontSize(18)
          .fontColor('#FFFFFF')
          .margin({ left: 72, bottom: 14 })
      }
      .width(128)
      .height(104)

      Blank()

      Stack({ alignContent: Alignment.BottomEnd }) {
        this.leaf('#144F4D', 92, 48, -12)
        this.leaf('#69A66F', 70, 38, 36)
        this.leaf('#BDD581', 52, 26, 66)
        Text('✿')
          .fontSize(18)
          .fontColor('#FFFFFF')
          .margin({ right: 42, bottom: 18 })
      }
      .width(128)
      .height(104)
    }
    .padding({ left: 0, right: 0 })
  }

  @Builder
  private leaf(color: string, width: number, height: number, offset: number) {
    Column()
      .width(width)
      .height(height)
      .backgroundColor(color)
      .borderRadius({ topLeft: height, topRight: 8, bottomLeft: 10, bottomRight: height })
      .rotate({ angle: offset })
      .opacity(0.94)
  }
}

@Component
struct ShortcutPanel {
  @Prop items: ShortcutItem[] = []

  build() {
    GridRow({ columns: 4, gutter: 8 }) {
      ForEach(this.items, (item: ShortcutItem) => {
        GridCol() {
          ShortcutButton({ icon: item.icon, title: item.title })
        }
      }, (item: ShortcutItem) => item.title)
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 22, bottom: 18 })
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
  }
}

@Component
struct ShortcutButton {
  @Prop icon: string = ''
  @Prop title: string = ''

  build() {
    Column({ space: 10 }) {
      Text(this.icon)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .textAlign(TextAlign.Center)
        .width(34)
        .height(34)
        .padding({ top: 6 })
        .backgroundColor('#59B8A9')
        .borderRadius(9)

      Text(this.title)
        .fontSize(15)
        .fontColor('#111111')
        .textAlign(TextAlign.Center)
        .maxLines(1)
    }
    .width('100%')
    .height(86)
    .justifyContent(FlexAlign.Center)
  }
}

@Component
struct SettingSection {
  @Prop title: string = ''
  @Prop items: SettingItem[] = []

  build() {
    Column({ space: 2 }) {
      Text(this.title)
        .fontSize(15)
        .fontColor('#9B9B9B')
        .margin({ bottom: 6 })

      ForEach(this.items, (item: SettingItem) => {
        SettingRow({
          icon: item.icon,
          title: item.title,
          subtitle: item.subtitle,
          value: item.value
        })
      }, (item: SettingItem) => item.title)
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 20, bottom: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
    .alignItems(HorizontalAlign.Start)
  }
}

@Component
struct SettingRow {
  @Prop icon: string = ''
  @Prop title: string = ''
  @Prop subtitle: string = ''
  @Prop value: string = ''

  build() {
    Row({ space: 16 }) {
      Text(this.icon)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#111111')
        .textAlign(TextAlign.Center)
        .width(32)
        .height(32)

      Column({ space: 6 }) {
        Text(this.title)
          .fontSize(20)
          .fontColor('#111111')
          .fontWeight(FontWeight.Medium)

        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(14)
            .fontColor('#9B9B9B')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      if (this.value.length > 0) {
        Text(this.value)
          .fontSize(16)
          .fontColor('#5BAF9F')
      }

      Text('›')
        .fontSize(32)
        .fontColor('#9B9B9B')
    }
    .width('100%')
    .height(82)
  }
}
