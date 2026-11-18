/**
 * 环境调节页
 * 3 项可调的模拟环境数据（温度/湿度/光照）+ 是否有人
 * 直接内联 Slider 绑定 @State，避免 @Builder 传参非响应式导致的数值不刷新
 */
import { appState } from '../store/AppState';
import { onEvent, EventData } from '../common/EventBus';

@Component
export struct EnvPage {
  @State temperature: number = appState.env.temperature;
  @State humidity: number = appState.env.humidity;
  @State illuminance: number = appState.env.illuminance;
  @State occupancy: boolean = appState.env.occupancy;
  private unsub: (() => void) | null = null;

  aboutToAppear(): void {
    this.unsub = onEvent((data: EventData) => {
      // 环境数据可能被场景载入等操作改变，同步回本地状态
      this.temperature = appState.env.temperature;
      this.humidity = appState.env.humidity;
      this.illuminance = appState.env.illuminance;
      this.occupancy = appState.env.occupancy;
    });
  }

  aboutToDisappear(): void {
    if (this.unsub) {
      this.unsub();
      this.unsub = null;
    }
  }

  build() {
    Column() {
      Text('模拟环境')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 16, bottom: 8 })

      Text('拖动滑块调整环境数据，实时触发联动规则')
        .fontSize(13)
        .fontColor('#999999')
        .margin({ bottom: 16 })

      Column({ space: 16 }) {
        // 温度
        Column() {
          Row() {
            Text('温度')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
            Blank()
            Text(`${this.temperature}℃`)
              .fontSize(16)
              .fontColor('#1677ff')
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')

          Slider({ value: this.temperature, min: -10, max: 45, step: 1, style: SliderStyle.OutSet })
            .width('100%')
            .onChange((v: number) => {
              this.temperature = v;
              appState.setTemperature(v);
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .shadow({ radius: 8, color: '#14000000', offsetX: 0, offsetY: 2 })

        // 湿度
        Column() {
          Row() {
            Text('湿度')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
            Blank()
            Text(`${this.humidity}%`)
              .fontSize(16)
              .fontColor('#1677ff')
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')

          Slider({ value: this.humidity, min: 0, max: 100, step: 1, style: SliderStyle.OutSet })
            .width('100%')
            .onChange((v: number) => {
              this.humidity = v;
              appState.setHumidity(v);
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .shadow({ radius: 8, color: '#14000000', offsetX: 0, offsetY: 2 })

        // 光照
        Column() {
          Row() {
            Text('光照')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
            Blank()
            Text(`${this.illuminance}lux`)
              .fontSize(16)
              .fontColor('#1677ff')
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')

          Slider({ value: this.illuminance, min: 0, max: 1000, step: 10, style: SliderStyle.OutSet })
            .width('100%')
            .onChange((v: number) => {
              this.illuminance = v;
              appState.setIlluminance(v);
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .shadow({ radius: 8, color: '#14000000', offsetX: 0, offsetY: 2 })

        // 是否有人
        Column() {
          Row() {
            Text('是否有人')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
            Blank()
            Text(this.occupancy ? '有人' : '无人')
              .fontSize(16)
              .fontColor('#1677ff')
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')

          Row() {
            Toggle({ type: ToggleType.Switch, isOn: this.occupancy })
              .selectedColor('#1677ff')
              .onChange((isOn: boolean) => {
                this.occupancy = isOn;
                appState.setOccupancy(isOn);
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .shadow({ radius: 8, color: '#14000000', offsetX: 0, offsetY: 2 })

        Button('触发一次联动计算')
          .width('100%')
          .height(44)
          .backgroundColor('#1677ff')
          .fontColor('#FFFFFF')
          .borderRadius(8)
          .margin({ top: 8 })
          .onClick(() => {
            appState.runEngine();
          })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, bottom: 16 })
    }
    .width('100%')
    .height('100%')
  }
}
