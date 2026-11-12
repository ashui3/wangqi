/**
 * 环境调节页
 * 3 项可调的模拟环境数据（温度/湿度/光照）+ 是否有人
 * 使用 @State 标量直接绑定 UI，保证拖动实时刷新
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
        this.NumSlider('温度', '℃', -10, 45, 1, this.temperature, (v: number) => {
          this.temperature = v;
          appState.setTemperature(v);
        })

        this.NumSlider('湿度', '%', 0, 100, 1, this.humidity, (v: number) => {
          this.humidity = v;
          appState.setHumidity(v);
        })

        this.NumSlider('光照', 'lux', 0, 1000, 10, this.illuminance, (v: number) => {
          this.illuminance = v;
          appState.setIlluminance(v);
        })

        this.BoolRow()

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

  @Builder
  NumSlider(label: string, unit: string, min: number, max: number, step: number,
    value: number, onChange: (v: number) => void) {
    Column() {
      Row() {
        Text(label)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Blank()
        Text(`${value}${unit}`)
          .fontSize(16)
          .fontColor('#1677ff')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')

      Slider({
        value: value,
        min: min,
        max: max,
        step: step,
        style: SliderStyle.OutSet
      })
        .width('100%')
        .onChange((v: number) => {
          onChange(v);
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 8, color: '#14000000', offsetX: 0, offsetY: 2 })
  }

  @Builder
  BoolRow() {
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
  }
}
