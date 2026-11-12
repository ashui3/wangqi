/**
 * 条件求值工具（纯函数，便于单元测试）
 */
import { Condition, ConditionField, Operator } from '../model/Rule';
import { EnvState } from '../model/EnvState';

/**
 * 从环境状态中读取条件目标字段的值
 * occupancy 转为 0/1
 */
export function readFieldValue(env: EnvState, field: ConditionField): number {
  switch (field) {
    case ConditionField.TEMPERATURE:
      return env.temperature;
    case ConditionField.HUMIDITY:
      return env.humidity;
    case ConditionField.ILLUMINANCE:
      return env.illuminance;
    case ConditionField.OCCUPANCY:
      return env.occupancy ? 1 : 0;
    default:
      return 0;
  }
}

/**
 * 比较两个数是否满足操作符
 */
export function compare(actual: number, operator: Operator, expected: number): boolean {
  switch (operator) {
    case Operator.GT:
      return actual > expected;
    case Operator.LT:
      return actual < expected;
    case Operator.GTE:
      return actual >= expected;
    case Operator.LTE:
      return actual <= expected;
    case Operator.EQ:
      return actual === expected;
    case Operator.NEQ:
      return actual !== expected;
    default:
      return false;
  }
}

/**
 * 求值单个条件
 */
export function evaluateCondition(condition: Condition, env: EnvState): boolean {
  const actual = readFieldValue(env, condition.field);
  return compare(actual, condition.operator, condition.value);
}

/**
 * 生成条件的可读描述（用于日志）
 */
export function describeCondition(condition: Condition): string {
  const labelMap: Record<ConditionField, string> = {
    [ConditionField.TEMPERATURE]: '温度',
    [ConditionField.HUMIDITY]: '湿度',
    [ConditionField.ILLUMINANCE]: '光照',
    [ConditionField.OCCUPANCY]: '是否有人'
  };
  const opMap: Record<Operator, string> = {
    [Operator.GT]: '>', [Operator.LT]: '<', [Operator.GTE]: '>=',
    [Operator.LTE]: '<=', [Operator.EQ]: '=', [Operator.NEQ]: '!='
  };
  if (condition.field === ConditionField.OCCUPANCY) {
    return `${labelMap[condition.field]}${condition.value === 1 ? '=有人' : '=无人'}`;
  }
  return `${labelMap[condition.field]} ${opMap[condition.operator]} ${condition.value}`;
}
