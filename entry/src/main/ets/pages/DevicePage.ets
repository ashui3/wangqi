/**
 * 设备控制页
 * 展示 4 类设备，支持开关与数值调节
 * 用 @State 持有设备数组 + @ObjectLink 建立规范响应式观察链
 */
import { Device, DEVICE_TYPE_META } from '../model/Device';
import { appState } from '../store/AppState';
import { onEvent, EventData } from '../common/EventBus';

@Component
export struct DevicePage {
  /** 设备数组（@State 持有，重新赋值触发 UI 刷新） */
  @State devices: Device[] = [];
  private unsub: (() => void) | null = null;

  /**
   * 从全局状态同步最新设备引用到本地 @State
   * 重新赋整个数组，触发 ForEach / @ObjectLink 重新建立观察
   */
  private syncDevices(): void {
    // 关键：拷贝一份新数组引用，让 @State 检测到变化
    this.devices = appState.devices.slice();
  }

  aboutToAppear(): void {
    // 订阅设备/日志变更事件，事件到达时同步最新状态
    this.unsub = onEvent((data: EventData) => {
      this.syncDevices();
    });
    // 每次进入页面都主动同步一次，确保读到最新设备状态
    // （即使规则在页面不活跃期间改变了设备，切回时也能正确显示）
    this.syncDevices();
  }

  aboutToDisappear(): void {
    if (this.unsub) {
      this.unsub();
      this.unsub = null;
    }
  }

  build() {
    Column() {
      Text('设备控制')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 16, bottom: 8 })

      List({ space: 12 }) {
        ForEach(this.devices, (dev: Device) => {
          ListItem() {
            DeviceCard({ device: dev })
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
}

/**
 * 单个设备卡片，独立组件
 * @ObjectLink 观察 @Observed 的 Device 对象，属性变化实时刷新
 */
@Component
struct DeviceCard {
  @ObjectLink device: Device;

  build() {
    Row() {
      Text(this.device.icon)
        .fontSize(36)
        .margin({ right: 12 })
      Column() {
        Text(this.device.name)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
        Text(DEVICE_TYPE_META[this.device.type].label)
          .fontSize(13)
          .fontColor('#999999')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (DEVICE_TYPE_META[this.device.type].hasValue) {
        Slider({
          value: this.device.value,
          min: DEVICE_TYPE_META[this.device.type].min,
          max: DEVICE_TYPE_META[this.device.type].max,
          step: 1,
          style: SliderStyle.OutSet
        })
          .width(100)
          .margin({ right: 8 })
          .onChange((value: number) => {
            appState.setDeviceValue(this.device.id, value);
          })
        Text(`${this.device.value}`)
          .fontSize(14)
          .fontColor('#333333')
          .width(28)
      }

      Toggle({ type: ToggleType.Switch, isOn: this.device.on })
        .selectedColor('#1677ff')
        .onChange((isOn: boolean) => {
          appState.toggleDevice(this.device.id);
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 8, color: '#14000000', offsetX: 0, offsetY: 2 })
  }
}
