/**
 * 联动规则模型
 * 采用 Trigger/Condition/Action 三要素，支持多条件（含双条件）与多动作
 */
import { DeviceType } from './Device';

/** 条件比较运算符 */
export enum Operator {
  GT = '>',      // 大于
  LT = '<',      // 小于
  GTE = '>=',    // 大于等于
  LTE = '<=',    // 小于等于
  EQ = '==',     // 等于
  NEQ = '!='     // 不等于
}

/** 条件目标字段（环境数据） */
export enum ConditionField {
  TEMPERATURE = 'temperature',
  HUMIDITY = 'humidity',
  ILLUMINANCE = 'illuminance',
  OCCUPANCY = 'occupancy'
}

/** 单个条件 */
export interface Condition {
  field: ConditionField;
  operator: Operator;
  value: number; // occupancy 用 0/1 表示 false/true
}

/** 多个条件之间的逻辑关系 */
export enum Logic {
  AND = 'and',
  OR = 'or'
}

/** 设备动作 */
export interface Action {
  deviceId: string;
  deviceType: DeviceType;
  /** 目标开关状态 */
  on: boolean;
  /** 可选：设置数值属性（温度/亮度/开合度） */
  setValue?: number;
}

/**
 * 联动规则
 * conditions 可包含多个条件（支持双条件），logic 决定它们如何共同作用
 * priority 越小优先级越高，用于冲突时的执行顺序裁决
 */
export class Rule {
  id: string;
  name: string;
  enabled: boolean;
  conditions: Condition[];
  logic: Logic;
  actions: Action[];
  priority: number;

  constructor(id: string, name: string, conditions: Condition[], logic: Logic,
    actions: Action[], priority: number = 10, enabled: boolean = true) {
    this.id = id;
    this.name = name;
    this.conditions = conditions;
    this.logic = logic;
    this.actions = actions;
    this.priority = priority;
    this.enabled = enabled;
  }
}

/** 条件字段元信息 */
export interface ConditionFieldMeta {
  label: string;
  unit: string;
  isBoolean: boolean;
}

export const CONDITION_FIELD_META: Record<ConditionField, ConditionFieldMeta> = {
  [ConditionField.TEMPERATURE]: { label: '温度', unit: '℃', isBoolean: false },
  [ConditionField.HUMIDITY]: { label: '湿度', unit: '%', isBoolean: false },
  [ConditionField.ILLUMINANCE]: { label: '光照', unit: 'lux', isBoolean: false },
  [ConditionField.OCCUPANCY]: { label: '是否有人', unit: '', isBoolean: true }
};

export const OPERATOR_META: Record<Operator, string> = {
  [Operator.GT]: '大于',
  [Operator.LT]: '小于',
  [Operator.GTE]: '大于等于',
  [Operator.LTE]: '小于等于',
  [Operator.EQ]: '等于',
  [Operator.NEQ]: '不等于'
};
