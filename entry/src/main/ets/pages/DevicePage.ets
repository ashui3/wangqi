/**
 * 设备控制页
 * 展示 4 类设备，支持开关与数值调节
 * 刷新策略：由父级 Index 通过 refreshSignal（@Prop）驱动，
 * 每次 tab 切换或联动事件发生时递增，强制 ForEach 重建卡片，
 * DeviceCard 只接收基础类型字段，直接读取最新值。
 */
import { Device, DeviceType, DEVICE_TYPE_META } from '../model/Device';
import { appState } from '../store/AppState';

@Component
export struct DevicePage {
  /** 刷新信号（由父级传入），变化时强制重建列表 */
  @Prop refreshSignal: number;

  build() {
    Column() {
      Text('设备控制')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 16, bottom: 8 })

      List({ space: 12 }) {
        ForEach(appState.devices, (dev: Device) => {
          ListItem() {
            DeviceCard({
              deviceId: dev.id,
              name: dev.name,
              icon: dev.icon,
              type: dev.type,
              on: dev.on,
              value: dev.value
            })
          }
        }, (dev: Device) => `${dev.id}_${this.refreshSignal}`)
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, bottom: 16 })
    }
    .width('100%')
    .height('100%')
  }
}

/**
 * 单个设备卡片，独立组件
 * 只接收基础类型字段（值类型），父级 ForEach key（含 refreshSignal）变化时重建，
 * 直接拿到最新值，不涉及对象引用/深拷贝问题
 */
@Component
struct DeviceCard {
  @Prop deviceId: string;
  @Prop name: string;
  @Prop icon: string;
  @Prop type: DeviceType;
  @Prop on: boolean;
  @Prop value: number;

  build() {
    Row() {
      Text(this.icon)
        .fontSize(36)
        .margin({ right: 12 })
      Column() {
        Text(this.name)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
        Text(DEVICE_TYPE_META[this.type].label)
          .fontSize(13)
          .fontColor('#999999')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (DEVICE_TYPE_META[this.type].hasValue) {
        Slider({
          value: this.value,
          min: DEVICE_TYPE_META[this.type].min,
          max: DEVICE_TYPE_META[this.type].max,
          step: 1,
          style: SliderStyle.OutSet
        })
          .width(100)
          .margin({ right: 8 })
          .onChange((value: number) => {
            appState.setDeviceValue(this.deviceId, value);
          })
        Text(`${this.value}`)
          .fontSize(14)
          .fontColor('#333333')
          .width(28)
      }

      Toggle({ type: ToggleType.Switch, isOn: this.on })
        .selectedColor('#1677ff')
        .onChange((isOn: boolean) => {
          appState.toggleDevice(this.deviceId);
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 8, color: '#14000000', offsetX: 0, offsetY: 2 })
  }
}
