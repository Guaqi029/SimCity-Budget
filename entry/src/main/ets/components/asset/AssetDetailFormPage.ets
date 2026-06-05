import { AssetGroup, AssetTypeOption } from '../../model/AssetAccount'

@Component
export struct AssetDetailFormPage {
  @Prop option: AssetTypeOption = {
    type: 'cash',
    group: 'fund',
    title: '现金',
    icon: '¥',
    color: '#F6C44F'
  }
  @Prop name: string = ''
  @Prop balance: string = ''
  @Prop shortName: string = ''
  @Prop remark: string = ''
  @Prop cardNo: string = ''
  @Prop includeInTotal: boolean = true
  @Prop pageTitle: string = ''
  onBack: () => void = () => {}
  onNameChange: (value: string) => void = () => {}
  onBalanceChange: (value: string) => void = () => {}
  onBalanceInvalid: () => void = () => {}
  onShortNameChange: (value: string) => void = () => {}
  onRemarkChange: (value: string) => void = () => {}
  onCardNoChange: (value: string) => void = () => {}
  onIncludeChange: () => void = () => {}
  onSave: () => void = () => {}

  build() {
    Column({ space: 8 }) {
      Row() {
        Text('×')
          .fontSize(28)
          .fontColor('#000000')
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.onBack()
          })

        Text(this.pageTitle.length > 0 ? this.pageTitle : '新增' + this.option.title + '账户')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111111')
          .layoutWeight(1)

        Text('✓')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#000000')
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.onSave()
          })
      }
      .width('100%')
      .height(48)
      .backgroundColor('#FFFFFF')

      // 基础信息是最高频输入区域，压缩行高后仍保留清晰的标签/输入层级。
      Column({ space: 0 }) {
        FormInputRow({ label: '名称', value: this.name, placeholder: '请输入账户名称', onChange: (value: string) => this.onNameChange(value) })
        BalanceInputRow({
          value: this.balance,
          onChange: (value: string) => this.onBalanceChange(value),
          onInvalid: () => this.onBalanceInvalid()
        })
        FormInputRow({ label: '简称', value: this.shortName, placeholder: '如工资卡、农行，可用于账户快速识别', onChange: (value: string) => this.onShortNameChange(value) })
        FormInputRow({ label: '备注', value: this.remark, placeholder: '请输入备注', onChange: (value: string) => this.onRemarkChange(value) })
        FormInputRow({ label: '卡号', value: this.cardNo, placeholder: '请输入卡号，可为空', onChange: (value: string) => this.onCardNoChange(value) })

        Text('卡号仅用作个人备忘，不涉及任何金融交易，可不填写')
          .fontSize(12)
          .fontColor('#8A8A8A')
          .maxLines(1)
          .margin({ left: 76, top: 0, bottom: 4 })
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 6, bottom: 6 })
      .backgroundColor('#FFFFFF')
      .borderRadius(12)

      Column({ space: 0 }) {
        SettingValueRow({ title: '账户图标', value: this.option.icon, color: this.option.color })
        SettingValueRow({ title: '夜间模式图标', value: this.option.icon, color: '#31454C' })
        ArrowValueRow({ title: '所属分组', value: this.groupTitle(this.option.group), subtitle: '' })
        ArrowValueRow({ title: '收益同步', value: '无', subtitle: '余额宝、零钱通等收益自动同步' })
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 4, bottom: 4 })
      .backgroundColor('#FFFFFF')
      .borderRadius(12)

      Column({ space: 0 }) {
        Row() {
          Text('计入总资产')
            .fontSize(16)
            .fontColor('#111111')
          Blank()
          SwitchButton({ active: this.includeInTotal, onToggle: () => this.onIncludeChange() })
        }
        .width('100%')
        .height(44)

        ArrowValueRow({ title: '选择生效账本', value: '全部账本', subtitle: '账户仅显示在指定账本' })
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 4, bottom: 4 })
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  private groupTitle(group: AssetGroup): string {
    if (group === 'fund') {
      return '资金账户'
    }
    if (group === 'credit') {
      return '信贷账户'
    }
    if (group === 'stored_value') {
      return '充值账户'
    }
    if (group === 'investment') {
      return '投资理财'
    }
    if (group === 'second_hand') {
      return '二手货物'
    }
    return '债务'
  }
}

@Component
struct BalanceInputRow {
  @Prop value: string = ''
  onChange: (value: string) => void = () => {}
  onInvalid: () => void = () => {}

  build() {
    Row({ space: 12 }) {
      Text('余额')
        .fontSize(16)
        .fontColor('#111111')
        .width(60)

      TextInput({ text: this.value, placeholder: '请输入账户余额' })
        .layoutWeight(1)
        .height(36)
        .fontSize(16)
        .fontColor('#111111')
        .placeholderColor('#9B9B9B')
        .backgroundColor('#FFFFFF')
        .padding({ left: 0, right: 0 })
        // 余额支持负数，且小数部分最多两位；第三位小数会被输入框直接拒绝。
        .inputFilter('^-?\\d*(\\.\\d{0,2})?$', (_value: string) => {
          this.onInvalid()
        })
        .onChange((value: string) => {
          this.onChange(value)
        })
    }
    .width('100%')
    .height(44)
  }
}

@Component
struct FormInputRow {
  @Prop label: string = ''
  @Prop value: string = ''
  @Prop placeholder: string = ''
  onChange: (value: string) => void = () => {}

  build() {
    Row({ space: 12 }) {
      Text(this.label)
        .fontSize(16)
        .fontColor('#111111')
        .width(60)

      TextInput({ text: this.value, placeholder: this.placeholder })
        .layoutWeight(1)
        .height(36)
        .fontSize(16)
        .fontColor('#111111')
        .placeholderColor('#9B9B9B')
        .backgroundColor('#FFFFFF')
        .padding({ left: 0, right: 0 })
        .onChange((value: string) => {
          this.onChange(value)
        })
    }
    .width('100%')
    .height(44)
  }
}

@Component
struct SettingValueRow {
  @Prop title: string = ''
  @Prop value: string = ''
  @Prop color: string = '#55B8A7'

  build() {
    Row() {
      Text(this.title)
        .fontSize(16)
        .fontColor('#111111')
      Blank()
      Text(this.value)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .textAlign(TextAlign.Center)
        .width(32)
        .height(32)
        .padding({ top: 7 })
        .backgroundColor(this.color)
        .borderRadius(16)
    }
    .width('100%')
    .height(48)
  }
}

@Component
struct ArrowValueRow {
  @Prop title: string = ''
  @Prop value: string = ''
  @Prop subtitle: string = ''

  build() {
    Row() {
      Column({ space: 2 }) {
        Text(this.title)
          .fontSize(16)
          .fontColor('#111111')
        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(12)
            .fontColor('#9B9B9B')
            .maxLines(1)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text(this.value)
        .fontSize(15)
        .fontColor('#111111')
      Text('›')
        .fontSize(24)
        .fontColor('#9B9B9B')
        .margin({ left: 6 })
    }
    .width('100%')
    .height(48)
  }
}

@Component
struct SwitchButton {
  @Prop active: boolean = true
  onToggle: () => void = () => {}

  build() {
    Row() {
      if (this.active) {
        Blank()
      }
      Column()
        .width(24)
        .height(24)
        .backgroundColor(this.active ? '#55B8A7' : '#C7CDD2')
        .borderRadius(12)
      if (!this.active) {
        Blank()
      }
    }
    .width(44)
    .height(28)
    .padding(2)
    .backgroundColor(this.active ? '#DFF3EE' : '#EEF0F2')
    .borderRadius(14)
    .onClick(() => {
      this.onToggle()
    })
  }
}
