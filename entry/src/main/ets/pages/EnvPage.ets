/**
 * 环境调节页
 * 3 项可调的模拟环境数据（温度/湿度/光照）+ 是否有人
 */
import { ENV_FIELDS, EnvFieldMeta } from '../model/EnvState';
import { appState } from '../store/AppState';
import { onEvent, offEvent, EventData } from '../common/EventBus';

@Component
export struct EnvPage {
  @State refreshFlag: number = 0;

  aboutToAppear(): void {
    onEvent((data: EventData) => {
      this.refreshFlag++;
    });
  }

  aboutToDisappear(): void {
    offEvent();
  }

  build() {
    Column() {
      if (this.refreshFlag >= 0) {
        this.Content()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Content() {
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
        ForEach(ENV_FIELDS, (field: EnvFieldMeta) => {
          this.EnvSlider(field)
        }, (field: EnvFieldMeta) => field.key)

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
  EnvSlider(field: EnvFieldMeta) {
    Column() {
      Row() {
        Text(field.label)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Blank()
        Text(this.formatValue(field))
          .fontSize(16)
          .fontColor('#1677ff')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')

      if (field.isBoolean) {
        Row() {
          Toggle({ type: ToggleType.Switch, isOn: appState.env.occupancy })
            .selectedColor('#1677ff')
            .onChange((isOn: boolean) => {
              appState.setOccupancy(isOn);
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
      } else {
        Slider({
          value: this.getNumberValue(field),
          min: field.min,
          max: field.max,
          step: field.step,
          style: SliderStyle.OutSet
        })
          .width('100%')
          .onChange((value: number) => {
            this.applyNumber(field, value);
          })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 8, color: '#14000000', offsetX: 0, offsetY: 2 })
  }

  private getNumberValue(field: EnvFieldMeta): number {
    switch (field.key) {
      case 'temperature':
        return appState.env.temperature;
      case 'humidity':
        return appState.env.humidity;
      case 'illuminance':
        return appState.env.illuminance;
      default:
        return 0;
    }
  }

  private formatValue(field: EnvFieldMeta): string {
    if (field.isBoolean) {
      return appState.env.occupancy ? '有人' : '无人';
    }
    const v = this.getNumberValue(field);
    return `${v}${field.unit}`;
  }

  private applyNumber(field: EnvFieldMeta, value: number): void {
    switch (field.key) {
      case 'temperature':
        appState.setTemperature(value);
        break;
      case 'humidity':
        appState.setHumidity(value);
        break;
      case 'illuminance':
        appState.setIlluminance(value);
        break;
      default:
        break;
    }
  }
}
