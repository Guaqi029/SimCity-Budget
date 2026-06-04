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
  onBack: () => void = () => {}
  onNameChange: (value: string) => void = () => {}
  onBalanceChange: (value: string) => void = () => {}
  onShortNameChange: (value: string) => void = () => {}
  onRemarkChange: (value: string) => void = () => {}
  onCardNoChange: (value: string) => void = () => {}
  onIncludeChange: () => void = () => {}
  onSave: () => void = () => {}

  build() {
    Column({ space: 14 }) {
      Row() {
        Text('×')
          .fontSize(34)
          .fontColor('#000000')
          .width(46)
          .height(46)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.onBack()
          })

        Text('新增' + this.option.title + '账户')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111111')
          .layoutWeight(1)

        Text('✓')
          .fontSize(34)
          .fontWeight(FontWeight.Bold)
          .fontColor('#000000')
          .width(46)
          .height(46)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.onSave()
          })
      }
      .width('100%')
      .height(64)
      .backgroundColor('#FFFFFF')

      Column({ space: 0 }) {
        FormInputRow({ label: '名称', value: this.name, placeholder: '请输入账户名称', onChange: (value: string) => this.onNameChange(value) })
        FormInputRow({ label: '余额', value: this.balance, placeholder: '请输入账户余额', onChange: (value: string) => this.onBalanceChange(value) })
        FormInputRow({ label: '简称', value: this.shortName, placeholder: '如工资卡、农行，可用于账户快速识别', onChange: (value: string) => this.onShortNameChange(value) })
        FormInputRow({ label: '备注', value: this.remark, placeholder: '请输入备注', onChange: (value: string) => this.onRemarkChange(value) })
        FormInputRow({ label: '卡号', value: this.cardNo, placeholder: '请输入卡号，可为空', onChange: (value: string) => this.onCardNoChange(value) })

        Text('卡号仅用作个人备忘，不涉及任何金融交易，可不填写')
          .fontSize(14)
          .fontColor('#8A8A8A')
          .margin({ left: 96, top: 2, bottom: 12 })
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 12, bottom: 10 })
      .backgroundColor('#FFFFFF')
      .borderRadius(14)

      Column({ space: 0 }) {
        SettingValueRow({ title: '账户图标', value: this.option.icon, color: this.option.color })
        SettingValueRow({ title: '夜间模式图标', value: this.option.icon, color: '#31454C' })
        ArrowValueRow({ title: '所属分组', value: this.groupTitle(this.option.group), subtitle: '' })
        ArrowValueRow({ title: '收益同步', value: '无', subtitle: '余额宝、零钱通等收益自动同步' })
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 10, bottom: 10 })
      .backgroundColor('#FFFFFF')
      .borderRadius(14)

      Column({ space: 0 }) {
        Row() {
          Text('计入总资产')
            .fontSize(20)
            .fontColor('#111111')
          Blank()
          SwitchButton({ active: this.includeInTotal, onToggle: () => this.onIncludeChange() })
        }
        .width('100%')
        .height(64)

        ArrowValueRow({ title: '选择生效账本', value: '全部账本', subtitle: '账户仅显示在指定账本' })
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 10, bottom: 10 })
      .backgroundColor('#FFFFFF')
      .borderRadius(14)
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
struct FormInputRow {
  @Prop label: string = ''
  @Prop value: string = ''
  @Prop placeholder: string = ''
  onChange: (value: string) => void = () => {}

  build() {
    Row({ space: 18 }) {
      Text(this.label)
        .fontSize(20)
        .fontColor('#111111')
        .width(72)

      TextInput({ text: this.value, placeholder: this.placeholder })
        .layoutWeight(1)
        .height(58)
        .fontSize(20)
        .fontColor('#111111')
        .placeholderColor('#9B9B9B')
        .backgroundColor('#FFFFFF')
        .padding({ left: 0, right: 0 })
        .onChange((value: string) => {
          this.onChange(value)
        })
    }
    .width('100%')
    .height(74)
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
        .fontSize(20)
        .fontColor('#111111')
      Blank()
      Text(this.value)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .textAlign(TextAlign.Center)
        .width(46)
        .height(46)
        .padding({ top: 12 })
        .backgroundColor(this.color)
        .borderRadius(23)
    }
    .width('100%')
    .height(74)
  }
}

@Component
struct ArrowValueRow {
  @Prop title: string = ''
  @Prop value: string = ''
  @Prop subtitle: string = ''

  build() {
    Row() {
      Column({ space: 5 }) {
        Text(this.title)
          .fontSize(20)
          .fontColor('#111111')
        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(14)
            .fontColor('#9B9B9B')
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text(this.value)
        .fontSize(18)
        .fontColor('#111111')
      Text('›')
        .fontSize(30)
        .fontColor('#9B9B9B')
        .margin({ left: 10 })
    }
    .width('100%')
    .height(74)
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
        .width(34)
        .height(34)
        .backgroundColor(this.active ? '#55B8A7' : '#C7CDD2')
        .borderRadius(17)
      if (!this.active) {
        Blank()
      }
    }
    .width(58)
    .height(38)
    .padding(2)
    .backgroundColor(this.active ? '#DFF3EE' : '#EEF0F2')
    .borderRadius(19)
    .onClick(() => {
      this.onToggle()
    })
  }
}
