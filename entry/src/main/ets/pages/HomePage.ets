import { PageHeader } from '../components/PageHeader'
import { InfoCard } from '../components/InfoCard'
import { HomeBillTimeline } from '../components/bill/HomeBillTimeline'
import { HOME_BILL_GROUPS } from '../components/bill/MockBillData'

@Component
export struct HomePage {
  onAddBill: () => void = () => {}
  onOpenAccount: () => void = () => {}

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Scroll() {
        Column({ space: 16 }) {
          PageHeader({
            eyebrow: 'SIMCITY BUDGET',
            title: '模拟城市记账本',
            subtitle: '让每一笔消费都影响你的小镇命运'
          })

          Stack({ alignContent: Alignment.TopStart }) {
            Column()
              .width('100%')
              .height(360)
              .linearGradient({
                angle: 180,
                colors: [['#E8F6FF', 0.0], ['#D0EEFF', 0.45], ['#BDE2FF', 1.0]]
              })
              .borderRadius(36)

            Column({ space: 14 }) {
              Row({ space: 12 }) {
                Text('记账改变生活')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#61738F')
                  .padding({ left: 18, right: 18, top: 10, bottom: 10 })
                  .backgroundColor('#F6FBFF')
                  .borderRadius(24)

                Blank()

                this.buildWeatherCard()
                this.buildNoticeCard()
              }
              .width('100%')

              Blank()

              this.buildIslandScene()
            }
            .width('100%')
            .height(360)
            .padding(20)
          }
          .width('100%')

          GridRow({ columns: 2, gutter: 12 }) {
            GridCol() {
              InfoCard({ title: '今日支出', value: '¥53.00', description: '合理范围内' })
            }
            GridCol() {
              InfoCard({ title: '本月累计', value: '¥388.00', description: '合理线 ¥1806.45' })
            }
            GridCol() {
              InfoCard({ title: '剩余预算', value: '¥1612.00', description: '总预算 ¥2000.00' })
            }
            GridCol() {
              InfoCard({ title: '城市等级', value: '繁荣', description: '消费克制，小镇持续发展' })
            }
          }

          HomeBillTimeline({ groups: HOME_BILL_GROUPS })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 20, bottom: 104 })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)

      this.addBillButton()
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private addBillButton() {
    Stack({ alignContent: Alignment.Center }) {
      Image($r('app.media.add'))
        .width(28)
        .height(28)
    }
    // 首页自己的悬浮入口，按钮本体之外不占点击区域，避免影响底部 TabBar。
    .width(58)
    .height(58)
    .borderRadius(29)
    .backgroundColor('#55B8A7')
    .shadow({ radius: 18, color: '#3355B8A744', offsetY: 8 })
    .margin({ right: 22, bottom: 22 })
    .onClick(() => {
      this.onAddBill()
    })
  }

  @Builder
  private buildWeatherCard() {
    Row({ space: 10 }) {
      Text('晴')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#C78A00')
        .width(44)
        .height(44)
        .textAlign(TextAlign.Center)
        .padding({ top: 10 })
        .borderRadius(18)
        .backgroundColor('#FFEAA8')

      Column({ space: 4 }) {
        Text('晴空万里')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#24314A')
        Text('26°C')
          .fontSize(14)
          .fontColor('#61738F')
      }
      .alignItems(HorizontalAlign.Start)
    }
    .padding({ left: 14, right: 14, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
    .borderRadius(26)
  }

  @Builder
  private buildNoticeCard() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Text('消息')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#24314A')
        .width(68)
        .height(68)
        .textAlign(TextAlign.Center)
        .padding({ top: 24 })
        .backgroundColor('#FFFFFF')
        .borderRadius(24)

      Column()
        .width(12)
        .height(12)
        .margin({ top: 10, right: 10 })
        .backgroundColor('#FF5D73')
        .borderRadius(6)
    }
  }

  @Builder
  private buildIslandScene() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column()
        .width('100%')
        .height(190)
        .backgroundColor('#66D9F0')
        .borderRadius(28)

      Column()
        .width('88%')
        .height(180)
        .margin({ bottom: 8 })
        .linearGradient({
          angle: 180,
          colors: [['#D9FF88', 0.0], ['#A8E78C', 0.55], ['#86DCA0', 1.0]]
        })
        .borderRadius({ topLeft: 120, topRight: 120, bottomLeft: 60, bottomRight: 60 })

      Row({ space: 18 }) {
        this.buildMiniBuilding(82, '#7CC4FF')
        this.buildMiniBuilding(128, '#5BA9F0')
        this.buildMiniBuilding(102, '#8ED0FF')
        this.buildMiniBuilding(88, '#79B8F2')
      }
      .margin({ bottom: 44 })

      Row({ space: 12 }) {
        this.buildTinyHouse('#F6C16B')
        this.buildTinyHouse('#7FC2FF')
        this.buildTinyHouse('#8EDC9D')
      }
      .margin({ top: 110, left: 18 })
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Text('风车区')
        .fontSize(12)
        .fontColor('#40617A')
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor('#F4FBFF')
        .borderRadius(16)
        .margin({ bottom: 96, left: 220 })
        .width('100%')
        .textAlign(TextAlign.Start)

      Text('热气球')
        .fontSize(12)
        .fontColor('#40617A')
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor('#FFF8E4')
        .borderRadius(16)
        .margin({ bottom: 154, left: 250 })
        .width('100%')
        .textAlign(TextAlign.Start)
    }
    .width('100%')
    .height(250)
  }

  @Builder
  private buildMiniBuilding(height: number, tone: string) {
    Column() {
      Column()
        .width(52)
        .height(height)
        .backgroundColor(tone)
        .borderRadius({ topLeft: 18, topRight: 18, bottomLeft: 10, bottomRight: 10 })

      Column()
        .width(64)
        .height(14)
        .backgroundColor('#EDF6FF')
        .borderRadius(10)
        .margin({ top: 4 })
    }
  }

  @Builder
  private buildTinyHouse(tone: string) {
    Column({ space: 4 }) {
      Column()
        .width(34)
        .height(20)
        .backgroundColor(tone)
        .borderRadius({ topLeft: 12, topRight: 12, bottomLeft: 6, bottomRight: 6 })

      Column()
        .width(42)
        .height(8)
        .backgroundColor('#EDF6FF')
        .borderRadius(6)
    }
  }
}
