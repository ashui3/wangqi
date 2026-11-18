/**
 * 条件求值单元测试
 */
import { describe, it, expect } from '@ohos/hypium';
import { Condition, ConditionField, Operator } from '../../../main/ets/model/Rule';
import { EnvState } from '../../../main/ets/model/EnvState';
import { evaluateCondition, compare, readFieldValue } from '../../../main/ets/engine/ConditionEvaluator';

export default function conditionEvaluatorTest() {
  describe('ConditionEvaluatorTest', () => {
    it('compare_gt_works', 0, () => {
      expect(compare(30, Operator.GT, 28)).assertTrue();
      expect(compare(28, Operator.GT, 28)).assertFalse();
    });

    it('compare_gte_works', 0, () => {
      expect(compare(28, Operator.GTE, 28)).assertTrue();
    });

    it('compare_all_operators_covered', 0, () => {
      // LT：小于
      expect(compare(20, Operator.LT, 28)).assertTrue();
      expect(compare(28, Operator.LT, 28)).assertFalse();
      // LTE：小于等于
      expect(compare(28, Operator.LTE, 28)).assertTrue();
      expect(compare(29, Operator.LTE, 28)).assertFalse();
      // EQ：等于
      expect(compare(28, Operator.EQ, 28)).assertTrue();
      expect(compare(29, Operator.EQ, 28)).assertFalse();
      // NEQ：不等于
      expect(compare(29, Operator.NEQ, 28)).assertTrue();
      expect(compare(28, Operator.NEQ, 28)).assertFalse();
    });

    it('evaluate_boundary_value_not_trigger', 0, () => {
      // 温度恰好等于阈值 28，> 28 不应触发
      const env = new EnvState(28, 50, 300, true);
      const cond: Condition = { field: ConditionField.TEMPERATURE, operator: Operator.GT, value: 28 };
      expect(evaluateCondition(cond, env)).assertFalse();
      // 湿度恰好等于阈值 30，< 30 不应触发
      const cond2: Condition = { field: ConditionField.HUMIDITY, operator: Operator.LT, value: 30 };
      const env2 = new EnvState(25, 30, 300, false);
      expect(evaluateCondition(cond2, env2)).assertFalse();
    });

    it('readFieldValue_occupancy_boolean', 0, () => {
      const env = new EnvState(25, 50, 300, true);
      expect(readFieldValue(env, ConditionField.OCCUPANCY)).assertEqual(1);
      const env2 = new EnvState(25, 50, 300, false);
      expect(readFieldValue(env2, ConditionField.OCCUPANCY)).assertEqual(0);
    });

    it('evaluate_temperature_condition', 0, () => {
      const env = new EnvState(32, 40, 800, true);
      const cond: Condition = { field: ConditionField.TEMPERATURE, operator: Operator.GT, value: 28 };
      expect(evaluateCondition(cond, env)).assertTrue();
    });

    it('evaluate_occupancy_condition', 0, () => {
      const env = new EnvState(25, 50, 300, true);
      const cond: Condition = { field: ConditionField.OCCUPANCY, operator: Operator.EQ, value: 1 };
      expect(evaluateCondition(cond, env)).assertTrue();
    });
  });
}
