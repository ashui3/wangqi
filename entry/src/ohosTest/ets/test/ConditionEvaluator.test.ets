/**
 * 条件求值单元测试
 */
import { describe, it, expect } from '@ohos/hypium';
import { Condition, ConditionField, Operator } from '../main/ets/model/Rule';
import { EnvState } from '../main/ets/model/EnvState';
import { evaluateCondition, compare, readFieldValue } from '../main/ets/engine/ConditionEvaluator';

export default function conditionEvaluatorTest() {
  describe('ConditionEvaluatorTest', () => {
    it('compare_gt_works', 0, () => {
      expect(compare(30, Operator.GT, 28)).assertTrue();
      expect(compare(28, Operator.GT, 28)).assertFalse();
    });

    it('compare_gte_works', 0, () => {
      expect(compare(28, Operator.GTE, 28)).assertTrue();
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
