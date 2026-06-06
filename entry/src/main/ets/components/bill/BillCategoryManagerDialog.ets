import { BillCategory } from '../../model/BillCategory'
import { BillType } from '../../model/BillType'
import { BillCategoryStore } from '../../storage/BillCategoryStore'
import { ICON_LIBRARY_ITEMS, IconLibraryItem, iconResourceById } from '../icon/IconLibraryConfig'

@CustomDialog
export struct BillCategoryManagerDialog {
  controller?: CustomDialogController
  @State private categories: BillCategory[] = []
  @State private activeType: BillType = 'expense'
  @State private editingCategoryId: string = ''
  @State private draftName: string = ''
  @State private draftIconId: string = 'icon_other'
  @State private errorMessage: string = ''
  onChanged: () => void = () => {}

  aboutToAppear() {
    this.loadCategories()
  }

  build() {
    Column({ space: 12 }) {
      this.titleBar()
      this.typeTabs()
      this.categoryList()
      this.editorPanel()
      this.iconPicker()
      this.actionBar()
    }
    .width('88%')
    .height('78%')
    .padding({ left: 14, right: 14, top: 14, bottom: 14 })
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
  }

  @Builder
  private titleBar() {
    Row() {
      Text('账单类型')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#111111')
      Blank()
      Text('关闭')
        .fontSize(13)
        .fontColor('#888888')
        .onClick(() => {
          if (this.controller !== undefined) {
            this.controller.close()
          }
        })
    }
    .width('100%')
    .height(28)
  }

  @Builder
  private typeTabs() {
    Row({ space: 8 }) {
      this.typeTab('expense', '支出')
      this.typeTab('income', '收入')
      this.typeTab('transfer', '转账')
    }
    .width('100%')
  }

  @Builder
  private typeTab(type: BillType, title: string) {
    Text(title)
      .fontSize(13)
      .fontColor(this.activeType === type ? '#FFFFFF' : '#555555')
      .textAlign(TextAlign.Center)
      .width(58)
      .height(28)
      .padding({ top: 5 })
      .backgroundColor(this.activeType === type ? '#55B8A7' : '#F2F4F5')
      .borderRadius(14)
      .onClick(() => {
        this.activeType = type
        this.clearDraft()
      })
  }

  @Builder
  private categoryList() {
    Column({ space: 6 }) {
      Row() {
        Text('当前类型')
          .fontSize(12)
          .fontColor('#777777')
        Blank()
        Text('点选可编辑自定义类型')
          .fontSize(11)
          .fontColor('#AAAAAA')
      }
      .width('100%')

      Scroll() {
        Column({ space: 4 }) {
          ForEach(this.activeCategories(), (category: BillCategory) => {
            this.categoryRow(category)
          }, (category: BillCategory) => category.id)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .height(130)
      .scrollBar(BarState.Off)
    }
    .width('100%')
  }

  @Builder
  private categoryRow(category: BillCategory) {
    Row({ space: 9 }) {
      Image(iconResourceById(category.iconId))
        .width(22)
        .height(22)
        .objectFit(ImageFit.Contain)

      Text(category.name)
        .fontSize(13)
        .fontColor('#111111')
        .layoutWeight(1)
        .maxLines(1)

      Text(category.isSystem ? '内置' : '自定义')
        .fontSize(11)
        .fontColor(category.isSystem ? '#AAAAAA' : '#55B8A7')
    }
    .width('100%')
    .height(36)
    .padding({ left: 10, right: 10 })
    .backgroundColor(this.editingCategoryId === category.id ? '#EEF9F6' : '#F8F8F8')
    .borderRadius(8)
    .onClick(() => {
      this.applyDraft(category)
    })
  }

  @Builder
  private editorPanel() {
    Column({ space: 8 }) {
      Row({ space: 10 }) {
        Stack({ alignContent: Alignment.Center }) {
          Image(iconResourceById(this.draftIconId))
            .width(25)
            .height(25)
            .objectFit(ImageFit.Contain)
        }
        .width(42)
        .height(42)
        .backgroundColor('#F2F4F5')
        .borderRadius(21)

        TextInput({ placeholder: '输入类型名称', text: this.draftName })
          .fontSize(14)
          .fontColor('#111111')
          .placeholderColor('#AAAAAA')
          .backgroundColor('#F6F7F8')
          .height(42)
          .borderRadius(8)
          .layoutWeight(1)
          .onChange((value: string) => {
            this.draftName = value
            this.errorMessage = ''
          })
      }
      .width('100%')

      if (this.errorMessage.length > 0) {
        Text(this.errorMessage)
          .fontSize(11)
          .fontColor('#D65A62')
          .width('100%')
      }
    }
    .width('100%')
  }

  @Builder
  private iconPicker() {
    Column({ space: 6 }) {
      Text('选择图标')
        .fontSize(12)
        .fontColor('#777777')
        .width('100%')

      Scroll() {
        GridRow({ columns: 5, gutter: 6 }) {
          ForEach(this.categoryIcons(), (icon: IconLibraryItem) => {
            GridCol() {
              this.iconCell(icon)
            }
          }, (icon: IconLibraryItem) => icon.id)
        }
        .width('100%')
      }
      .width('100%')
      .height(160)
      .scrollBar(BarState.Off)
    }
    .width('100%')
  }

  @Builder
  private iconCell(icon: IconLibraryItem) {
    Column({ space: 4 }) {
      Stack({ alignContent: Alignment.Center }) {
        Image(icon.resource)
          .width(21)
          .height(21)
          .objectFit(ImageFit.Contain)
      }
      .width(38)
      .height(38)
      .backgroundColor(this.draftIconId === icon.id ? '#DDF3EE' : '#F4F5F7')
      .borderRadius(19)

      Text(icon.name)
        .fontSize(10)
        .fontColor(this.draftIconId === icon.id ? '#55B8A7' : '#555555')
        .maxLines(1)
        .textAlign(TextAlign.Center)
        .width('100%')
    }
    .width('100%')
    .height(58)
    .onClick(() => {
      this.draftIconId = icon.id
      this.errorMessage = ''
    })
  }

  @Builder
  private actionBar() {
    Row({ space: 10 }) {
      Text('清空')
        .fontSize(14)
        .fontColor('#666666')
        .textAlign(TextAlign.Center)
        .height(38)
        .layoutWeight(1)
        .padding({ top: 9 })
        .backgroundColor('#F2F4F5')
        .borderRadius(8)
        .onClick(() => {
          this.clearDraft()
        })

      Text('删除')
        .fontSize(14)
        .fontColor(this.canDelete() ? '#D65A62' : '#BBBBBB')
        .textAlign(TextAlign.Center)
        .height(38)
        .layoutWeight(1)
        .padding({ top: 9 })
        .backgroundColor('#F2F4F5')
        .borderRadius(8)
        .onClick(() => {
          this.deleteDraftCategory()
        })

      Text(this.editingCategoryId.length > 0 ? '保存' : '新增')
        .fontSize(14)
        .fontColor('#FFFFFF')
        .textAlign(TextAlign.Center)
        .height(38)
        .layoutWeight(1)
        .padding({ top: 9 })
        .backgroundColor('#55B8A7')
        .borderRadius(8)
        .onClick(() => {
          this.saveDraftCategory()
        })
    }
    .width('100%')
  }

  private loadCategories() {
    BillCategoryStore.load(getContext(this))
      .then((categories: BillCategory[]) => {
        this.categories = categories
      })
      .catch(() => {
        this.categories = []
      })
  }

  private activeCategories(): BillCategory[] {
    return BillCategoryStore.activeByType(this.categories, this.activeType)
  }

  private categoryIcons(): IconLibraryItem[] {
    const icons: IconLibraryItem[] = []
    for (let index = 0; index < ICON_LIBRARY_ITEMS.length; index++) {
      if (ICON_LIBRARY_ITEMS[index].id.indexOf('icon_') === 0) {
        icons.push(ICON_LIBRARY_ITEMS[index])
      }
    }
    return icons
  }

  private applyDraft(category: BillCategory) {
    this.draftName = category.name
    this.draftIconId = category.iconId
    this.errorMessage = category.isSystem ? '内置类型不可修改，可修改名称后新增为自定义类型' : ''
    this.editingCategoryId = category.isSystem ? '' : category.id
  }

  private clearDraft() {
    this.editingCategoryId = ''
    this.draftName = ''
    this.draftIconId = 'icon_other'
    this.errorMessage = ''
  }

  private canDelete(): boolean {
    return this.editingCategoryId.length > 0
  }

  private saveDraftCategory() {
    const name = this.draftName.trim()
    if (name.length === 0) {
      this.errorMessage = '请输入类型名称'
      return
    }

    const now = new Date().toISOString()
    const nextCategories: BillCategory[] = []
    let updated = false
    for (let index = 0; index < this.categories.length; index++) {
      const category = this.categories[index]
      if (category.id === this.editingCategoryId) {
        nextCategories.push({
          id: category.id,
          name: name,
          type: category.type,
          iconId: this.draftIconId,
          createTime: category.createTime,
          updateTime: now,
          isSystem: false,
          isDeleted: false
        })
        updated = true
      } else {
        nextCategories.push(category)
      }
    }

    if (!updated) {
      nextCategories.push({
        id: 'category_' + now,
        name: name,
        type: this.activeType,
        iconId: this.draftIconId,
        createTime: now,
        updateTime: now,
        isSystem: false,
        isDeleted: false
      })
    }

    BillCategoryStore.save(getContext(this), nextCategories)
      .then(() => {
        this.categories = nextCategories
        this.clearDraft()
        this.onChanged()
      })
      .catch(() => {
        this.errorMessage = '保存失败'
      })
  }

  private deleteDraftCategory() {
    if (!this.canDelete()) {
      return
    }

    const now = new Date().toISOString()
    const nextCategories: BillCategory[] = []
    for (let index = 0; index < this.categories.length; index++) {
      const category = this.categories[index]
      if (category.id === this.editingCategoryId) {
        nextCategories.push({
          id: category.id,
          name: category.name,
          type: category.type,
          iconId: category.iconId,
          createTime: category.createTime,
          updateTime: now,
          isSystem: category.isSystem,
          isDeleted: true
        })
      } else {
        nextCategories.push(category)
      }
    }

    BillCategoryStore.save(getContext(this), nextCategories)
      .then(() => {
        this.categories = nextCategories
        this.clearDraft()
        this.onChanged()
      })
      .catch(() => {
        this.errorMessage = '删除失败'
      })
  }
}
