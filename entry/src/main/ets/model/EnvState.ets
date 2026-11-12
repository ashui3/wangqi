/**
 * 模拟环境数据模型
 * 学生可手动调节这些环境数据来检验联动规则
 */
export class EnvState {
  /** 温度（℃），范围 -10 ~ 45 */
  temperature: number;
  /** 湿度（%），范围 0 ~ 100 */
  humidity: number;
  /** 光照强度（lux），范围 0 ~ 1000 */
  illuminance: number;
  /** 是否有人 */
  occupancy: boolean;

  constructor(temperature: number = 25, humidity: number = 50,
    illuminance: number = 300, occupancy: boolean = false) {
    this.temperature = temperature;
    this.humidity = humidity;
    this.illuminance = illuminance;
    this.occupancy = occupancy;
  }
}

/** 环境字段元信息（UI 展示用） */
export interface EnvFieldMeta {
  key: keyof EnvState;
  label: string;
  unit: string;
  min: number;
  max: number;
  step: number;
  isBoolean: boolean;
}

export const ENV_FIELDS: EnvFieldMeta[] = [
  { key: 'temperature', label: '温度', unit: '℃', min: -10, max: 45, step: 1, isBoolean: false },
  { key: 'humidity', label: '湿度', unit: '%', min: 0, max: 100, step: 1, isBoolean: false },
  { key: 'illuminance', label: '光照', unit: 'lux', min: 0, max: 1000, step: 10, isBoolean: false },
  { key: 'occupancy', label: '是否有人', unit: '', min: 0, max: 1, step: 1, isBoolean: true }
];
