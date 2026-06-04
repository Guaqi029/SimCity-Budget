import common from '@ohos.app.ability.common'
import photoAccessHelper from '@ohos.file.photoAccessHelper'
import fs from '@ohos.file.fs'
import preferences from '@ohos.data.preferences'
import promptAction from '@ohos.promptAction'

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

const ACCOUNT_STORE_NAME: string = 'account_profile_store'
const AVATAR_URI_KEY: string = 'latest_avatar_uri'
const AVATAR_FILE_NAME: string = 'account_avatar.jpg'
const NICKNAME_KEY: string = 'nickname'
const DEFAULT_NICKNAME: string = '鱼受'

// ArkUI 显示应用沙箱图片时需要 file:// 前缀；相册 URI 已经带协议，直接使用。
function getImageSource(uri: string): string {
  if (uri.startsWith('file://') || uri.startsWith('http://') || uri.startsWith('https://')) {
    return uri
  }
  return 'file://' + uri
}

@Component
export struct AccountPage {
  @State private avatarUri: string = ''
  @State private nickname: string = DEFAULT_NICKNAME
  @State private draftNickname: string = DEFAULT_NICKNAME
  @State private showProfileEditor: boolean = false

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

  aboutToAppear() {
    this.loadLocalAvatar()
  }

  build() {
    if (this.showProfileEditor) {
      ProfileEditPage({
        avatarUri: this.avatarUri,
        nickname: this.draftNickname,
        onBack: () => {
          this.showProfileEditor = false
        },
        onChangeAvatar: () => {
          this.pickAvatar()
        },
        onNicknameChange: (value: string) => {
          this.draftNickname = value
        },
        onSave: () => {
          this.saveProfile()
        }
      })
    } else {
      Column({ space: 18 }) {
        ProfileHero({
          avatarUri: this.avatarUri,
          nickname: this.nickname,
          onOpenProfileEditor: () => {
            this.openProfileEditor()
          }
        })
        ShortcutPanel({ items: this.shortcutItems })
        SettingSection({ title: '数据管理', items: this.dataItems })
        SettingSection({ title: '其他', items: this.otherItems })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }

  private openProfileEditor() {
    this.draftNickname = this.nickname
    this.showProfileEditor = true
  }

  // 从本地 Preferences 读取个人资料；没有头像时保持空字符串，由 UI 展示“暂无”占位。
  private loadLocalAvatar() {
    preferences.getPreferences(getContext(this), ACCOUNT_STORE_NAME)
      .then((store: preferences.Preferences) => {
        return Promise.all([
          store.get(AVATAR_URI_KEY, ''),
          store.get(NICKNAME_KEY, DEFAULT_NICKNAME)
        ])
      })
      .then((values: preferences.ValueType[]) => {
        const avatarValue = values[0]
        const nicknameValue = values[1]

        if (typeof avatarValue === 'string') {
          this.avatarUri = avatarValue
        }
        if (typeof nicknameValue === 'string' && nicknameValue.length > 0) {
          this.nickname = nicknameValue
          this.draftNickname = nicknameValue
        }
      })
      .catch(() => {
        promptAction.showToast({ message: '个人资料读取失败' })
      })
  }

  // 打开系统相册选择头像；本地只保存最新 URI，不维护历史头像列表。
  private pickAvatar() {
    const options = new photoAccessHelper.PhotoSelectOptions()
    options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
    options.maxSelectNumber = 1

    const picker = new photoAccessHelper.PhotoViewPicker()
    picker.select(options)
      .then((result: photoAccessHelper.PhotoSelectResult) => {
        if (result.photoUris.length === 0) {
          return
        }
        this.saveLatestAvatar(result.photoUris[0])
      })
      .catch(() => {
        promptAction.showToast({ message: '头像选择失败' })
      })
  }

  private saveLatestAvatar(uri: string) {
    const context = getContext(this) as common.UIAbilityContext
    const localAvatarPath = context.filesDir + '/' + AVATAR_FILE_NAME
    let sourceFile: fs.File | undefined = undefined
    let targetFile: fs.File | undefined = undefined

    try {
      // 固定文件名覆盖保存，确保本地只保留最新头像。
      sourceFile = fs.openSync(uri, fs.OpenMode.READ_ONLY)
      targetFile = fs.openSync(localAvatarPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC)
      fs.copyFileSync(sourceFile.fd, targetFile.fd)
    } catch (error) {
      promptAction.showToast({ message: '头像保存失败' })
      return
    } finally {
      if (sourceFile !== undefined) {
        fs.closeSync(sourceFile)
      }
      if (targetFile !== undefined) {
        fs.closeSync(targetFile)
      }
    }

    preferences.getPreferences(getContext(this), ACCOUNT_STORE_NAME)
      .then((store: preferences.Preferences) => {
        this.avatarUri = localAvatarPath
        store.put(AVATAR_URI_KEY, localAvatarPath)
        return store.flush()
      })
      .then(() => {
        promptAction.showToast({ message: '头像已更新' })
      })
      .catch(() => {
        promptAction.showToast({ message: '头像保存失败' })
      })
  }

  private saveProfile() {
    const nextNickname = this.draftNickname.trim()
    if (nextNickname.length === 0) {
      promptAction.showToast({ message: '昵称不能为空' })
      return
    }

    preferences.getPreferences(getContext(this), ACCOUNT_STORE_NAME)
      .then((store: preferences.Preferences) => {
        this.nickname = nextNickname
        store.put(NICKNAME_KEY, nextNickname)
        return store.flush()
      })
      .then(() => {
        this.showProfileEditor = false
        promptAction.showToast({ message: '资料已保存' })
      })
      .catch(() => {
        promptAction.showToast({ message: '资料保存失败' })
      })
  }
}

@Component
struct ProfileHero {
  @Prop avatarUri: string = ''
  @Prop nickname: string = DEFAULT_NICKNAME
  onOpenProfileEditor: () => void = () => {}

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

      Column({ space: 14 }) {
        AvatarBadge({
          avatarUri: this.avatarUri,
          onClickAvatar: () => {
            this.onOpenProfileEditor()
          }
        })

        Text(this.nickname)
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
struct ProfileEditPage {
  @Prop avatarUri: string = ''
  @Prop nickname: string = DEFAULT_NICKNAME
  onBack: () => void = () => {}
  onChangeAvatar: () => void = () => {}
  onNicknameChange: (value: string) => void = () => {}
  onSave: () => void = () => {}

  build() {
    Column({ space: 22 }) {
      Row() {
        Text('‹')
          .fontSize(34)
          .fontColor('#111111')
          .width(44)
          .height(44)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.onBack()
          })

        Text('编辑个人资料')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111111')

        Blank()
      }
      .width('100%')
      .height(48)

      Column({ space: 14 }) {
        EditableAvatar({ avatarUri: this.avatarUri })

        Button('更换头像')
          .type(ButtonType.Capsule)
          .height(40)
          .fontSize(15)
          .fontColor('#55B8A7')
          .backgroundColor('#EAF8F5')
          .onClick(() => {
            this.onChangeAvatar()
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      Column({ space: 10 }) {
        Text('昵称')
          .fontSize(15)
          .fontColor('#8A8A8A')

        TextInput({ text: this.nickname, placeholder: '请输入昵称' })
          .width('100%')
          .height(52)
          .fontSize(17)
          .fontColor('#111111')
          .placeholderColor('#B0B0B0')
          .backgroundColor('#F4F7F6')
          .borderRadius(12)
          .padding({ left: 14, right: 14 })
          .onChange((value: string) => {
            this.onNicknameChange(value)
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 18, right: 18, top: 22, bottom: 24 })
      .backgroundColor('#FFFFFF')
      .borderRadius(14)

      Button('保存')
        .type(ButtonType.Capsule)
        .width('100%')
        .height(52)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .backgroundColor('#55B8A7')
        .onClick(() => {
          this.onSave()
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}

@Component
struct EditableAvatar {
  @Prop avatarUri: string = ''

  build() {
    Stack({ alignContent: Alignment.Center }) {
      if (this.avatarUri.length > 0) {
        Image(getImageSource(this.avatarUri))
          .width(116)
          .height(116)
          .objectFit(ImageFit.Contain)
      } else {
        Column({ space: 6 }) {
          Text('人')
            .fontSize(40)
            .fontWeight(FontWeight.Bold)
            .fontColor('#8BBEB5')
          Text('暂无头像')
            .fontSize(13)
            .fontColor('#8BBEB5')
        }
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width(124)
    .height(124)
    .borderRadius(62)
    .clip(true)
    .backgroundColor('#EAF8F5')
    .border({ width: 1, color: '#BFE1DA' })
  }
}

@Component
struct AvatarBadge {
  @Prop avatarUri: string = ''
  onClickAvatar: () => void = () => {}

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Stack({ alignContent: Alignment.Center }) {
        if (this.avatarUri.length > 0) {
          Image(getImageSource(this.avatarUri))
            .width(86)
            .height(86)
            // 使用 Contain 保留整张图片，避免头像被居中裁切。
            .objectFit(ImageFit.Contain)
        } else {
          // 初始化暂无头像时，显示明确的空头像占位。
          Column({ space: 4 }) {
            Text('人')
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .fontColor('#8BBEB5')
            Text('暂无')
              .fontSize(12)
              .fontColor('#8BBEB5')
          }
          .width(92)
          .height(92)
          .borderRadius(46)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .backgroundColor('#EAF8F5')
          .border({ width: 1, color: '#BFE1DA' })
        }
      }
      .width(92)
      .height(92)
      .borderRadius(46)
      .clip(true)
      .backgroundColor('#EAF8F5')
      .onClick(() => {
        this.onClickAvatar()
      })
    }
    .width(96)
    .height(96)
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
          subtitle: item.subtitle ?? '',
          value: item.value ?? ''
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
