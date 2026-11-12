/**
 * 设备控制页
 * 展示 4 类设备，支持开关与数值调节
 */
import { Device, DEVICE_TYPE_META } from '../model/Device';
import { appState } from '../store/AppState';

@Component
export struct DevicePage {
  build() {
    Column() {
      Text('设备控制')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 16, bottom: 8 })

      List({ space: 12 }) {
        ForEach(appState.devices, (dev: Device) => {
          ListItem() {
            this.DeviceCard(dev)
          }
        }, (dev: Device) => dev.id)
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, bottom: 16 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DeviceCard(dev: Device) {
    Row() {
      Text(dev.icon)
        .fontSize(36)
        .margin({ right: 12 })
      Column() {
        Text(dev.name)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
        Text(DEVICE_TYPE_META[dev.type].label)
          .fontSize(13)
          .fontColor('#999999')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (DEVICE_TYPE_META[dev.type].hasValue) {
        Slider({
          value: dev.value,
          min: DEVICE_TYPE_META[dev.type].min,
          max: DEVICE_TYPE_META[dev.type].max,
          step: 1,
          style: SliderStyle.OutSet
        })
          .width(100)
          .margin({ right: 8 })
          .onChange((value: number) => {
            appState.setDeviceValue(dev.id, value);
          })
        Text(`${dev.value}`)
          .fontSize(14)
          .fontColor('#333333')
          .width(28)
      }

      Toggle({ type: ToggleType.Switch, isOn: dev.on })
        .selectedColor('#1677ff')
        .onChange((isOn: boolean) => {
          appState.toggleDevice(dev.id);
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 8, color: '#14000000', offsetX: 0, offsetY: 2 })
  }
}
