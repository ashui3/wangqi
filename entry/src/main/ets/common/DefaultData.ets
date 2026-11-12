/**
 * 默认数据工厂
 * 提供初始设备与默认规则（含一条双条件规则）
 */
import { Device, DeviceType } from '../model/Device';
import { Rule, Condition, ConditionField, Operator, Logic, Action } from '../model/Rule';

/** 生成默认设备列表（4 类） */
export function buildDefaultDevices(): Device[] {
  return [
    new Device('light_main', '主灯', DeviceType.LIGHT, '💡', false, 0),
    new Device('aircon', '空调', DeviceType.AIRCON, '❄️', false, 26),
    new Device('curtain', '窗帘', DeviceType.CURTAIN, '🪟', false, 0),
    new Device('humidifier', '加湿器', DeviceType.HUMIDIFIER, '💧', false)
  ];
}

/**
 * 生成默认规则（4 条，含 1 条双条件规则）
 * 规则之间刻意设计了一组冲突，用于演示优先级裁决
 */
export function buildDefaultRules(): Rule[] {
  // 规则1（双条件）：温度 > 28 且 有人 → 开空调，优先级 1（最高）
  const r1 = new Rule(
    'rule_hot_occupy',
    '高温且有人开空调',
    [
      { field: ConditionField.TEMPERATURE, operator: Operator.GT, value: 28 },
      { field: ConditionField.OCCUPANCY, operator: Operator.EQ, value: 1 }
    ],
    Logic.AND,
    [
      { deviceId: 'aircon', deviceType: DeviceType.AIRCON, on: true, setValue: 24 }
    ],
    1, true
  );

  // 规则2：光照 < 50 → 开灯，优先级 5
  const r2 = new Rule(
    'rule_dark_light',
    '昏暗开灯',
    [
      { field: ConditionField.ILLUMINANCE, operator: Operator.LT, value: 50 }
    ],
    Logic.AND,
    [
      { deviceId: 'light_main', deviceType: DeviceType.LIGHT, on: true, setValue: 80 }
    ],
    5, true
  );

  // 规则3：湿度 < 30 → 开加湿器，优先级 5
  const r3 = new Rule(
    'rule_dry_humidifier',
    '干燥开加湿器',
    [
      { field: ConditionField.HUMIDITY, operator: Operator.LT, value: 30 }
    ],
    Logic.AND,
    [
      { deviceId: 'humidifier', deviceType: DeviceType.HUMIDIFIER, on: true }
    ],
    5, true
  );

  // 规则4（与规则1冲突）：温度 > 30 → 关空调（节能），优先级 2
  // 当温度 31 且有人时，规则1和规则4都会触发且都控制空调，
  // 因规则1优先级更高(1<2)，先执行规则1开空调，再执行规则4关空调，
  // 最终以规则4为准（演示冲突裁决）
  const r4 = new Rule(
    'rule_energy_save',
    '超高温节能关空调',
    [
      { field: ConditionField.TEMPERATURE, operator: Operator.GT, value: 30 }
    ],
    Logic.AND,
    [
      { deviceId: 'aircon', deviceType: DeviceType.AIRCON, on: false }
    ],
    2, true
  );

  // 规则5（双条件 OR）：光照 > 500 且有人 → 关窗帘（演示 OR 逻辑）
  const r5 = new Rule(
    'rule_bright_curtain',
    '强光关窗帘',
    [
      { field: ConditionField.ILLUMINANCE, operator: Operator.GT, value: 500 },
      { field: ConditionField.OCCUPANCY, operator: Operator.EQ, value: 1 }
    ],
    Logic.OR,
    [
      { deviceId: 'curtain', deviceType: DeviceType.CURTAIN, on: false, setValue: 100 }
    ],
    8, true
  );

  return [r1, r2, r3, r4, r5];
}
