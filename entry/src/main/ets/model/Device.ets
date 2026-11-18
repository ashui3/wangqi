/**
 * 设备模型
 * 支持多类型可控制设备：灯、空调、窗帘、加湿器等
 */

/** 设备类型 */
export enum DeviceType {
  LIGHT = 'light',       // 灯
  AIRCON = 'aircon',     // 空调
  CURTAIN = 'curtain',   // 窗帘
  HUMIDIFIER = 'humidifier' // 加湿器
}

/** 设备状态：布尔开关 */
export interface DeviceState {
  on: boolean;
}

/** 扩展状态：用于空调温度、灯亮度、窗帘开合度等 */
export interface DeviceExtra {
  value: number; // 数值型属性，如温度(16-30)、亮度(0-100)、开合度(0-100)
}

/**
 * 设备实体
 * extra 为可选，灯可存亮度、空调可存温度、窗帘可存开合度
 */
@Observed
export class Device {
  id: string;
  name: string;
  type: DeviceType;
  /** 设备图标 emoji，简化 UI 展示 */
  icon: string;
  /** 开关状态 */
  on: boolean;
  /** 附加数值属性 */
  value: number;
  /** 该设备上一次被哪条规则操控（用于日志追溯） */
  lastRuleId: string;

  constructor(id: string, name: string, type: DeviceType, icon: string,
    on: boolean = false, value: number = 0) {
    this.id = id;
    this.name = name;
    this.type = type;
    this.icon = icon;
    this.on = on;
    this.value = value;
    this.lastRuleId = '';
  }
}

/** 设备类型元信息（UI 展示用） */
export interface DeviceTypeMeta {
  label: string;
  icon: string;
  hasValue: boolean;
  valueLabel: string;
  min: number;
  max: number;
}

export const DEVICE_TYPE_META: Record<DeviceType, DeviceTypeMeta> = {
  [DeviceType.LIGHT]: { label: '灯', icon: '💡', hasValue: true, valueLabel: '亮度', min: 0, max: 100 },
  [DeviceType.AIRCON]: { label: '空调', icon: '❄️', hasValue: true, valueLabel: '温度', min: 16, max: 30 },
  [DeviceType.CURTAIN]: { label: '窗帘', icon: '🪟', hasValue: true, valueLabel: '开合度', min: 0, max: 100 },
  [DeviceType.HUMIDIFIER]: { label: '加湿器', icon: '💧', hasValue: false, valueLabel: '', min: 0, max: 0 }
};
