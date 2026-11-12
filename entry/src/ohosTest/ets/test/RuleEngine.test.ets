/**
 * 规则引擎单元测试
 * 覆盖：双条件规则、执行顺序、冲突优先级
 */
import { describe, it, expect } from '@ohos/hypium';
import { Rule, Condition, ConditionField, Operator, Logic, Action } from '../main/ets/model/Rule';
import { Device, DeviceType } from '../main/ets/model/Device';
import { EnvState } from '../main/ets/model/EnvState';
import { RuleEngine, evaluateRule } from '../main/ets/engine/RuleEngine';

export default function ruleEngineTest() {
  describe('RuleEngineTest', () => {
    it('evaluateRule_double_condition_and', 0, () => {
      const rule = new Rule('r1', '高温且有人', [
        { field: ConditionField.TEMPERATURE, operator: Operator.GT, value: 28 },
        { field: ConditionField.OCCUPANCY, operator: Operator.EQ, value: 1 }
      ], Logic.AND, [{ deviceId: 'aircon', deviceType: DeviceType.AIRCON, on: true }], 1, true);

      // 两个条件都满足
      const env1 = new EnvState(32, 40, 800, true);
      expect(evaluateRule(rule, env1).triggered).assertTrue();

      // 温度满足但无人 → 不触发
      const env2 = new EnvState(32, 40, 800, false);
      expect(evaluateRule(rule, env2).triggered).assertFalse();
    });

    it('evaluateRule_or_logic', 0, () => {
      const rule = new Rule('r2', '强光或有人', [
        { field: ConditionField.ILLUMINANCE, operator: Operator.GT, value: 500 },
        { field: ConditionField.OCCUPANCY, operator: Operator.EQ, value: 1 }
      ], Logic.OR, [{ deviceId: 'curtain', deviceType: DeviceType.CURTAIN, on: false }], 8, true);

      // 光照满足但无人 → OR 仍触发
      const env = new EnvState(25, 50, 800, false);
      expect(evaluateRule(rule, env).triggered).assertTrue();
    });

    it('run_engine_execution_order_and_conflict', 0, () => {
      const devices = [
        new Device('aircon', '空调', DeviceType.AIRCON, '❄️', false, 26)
      ];
      const engine = new RuleEngine();
      engine.setDevices(devices);

      // 规则A：优先级1，温度>28 且有人 → 开空调24
      const ruleA = new Rule('ruleA', '开空调', [
        { field: ConditionField.TEMPERATURE, operator: Operator.GT, value: 28 },
        { field: ConditionField.OCCUPANCY, operator: Operator.EQ, value: 1 }
      ], Logic.AND, [{ deviceId: 'aircon', deviceType: DeviceType.AIRCON, on: true, setValue: 24 }], 1, true);

      // 规则B：优先级2，温度>30 → 关空调（冲突）
      const ruleB = new Rule('ruleB', '关空调', [
        { field: ConditionField.TEMPERATURE, operator: Operator.GT, value: 30 }
      ], Logic.AND, [{ deviceId: 'aircon', deviceType: DeviceType.AIRCON, on: false }], 2, true);

      engine.setRules([ruleA, ruleB]);

      // 温度31 且有人 → 两条规则都触发，控制同一设备
      const env = new EnvState(31, 50, 300, true);
      const batch = engine.run(env, 1000);

      expect(batch.entries.length).assertEqual(2);
      // 优先级1的先执行
      expect(batch.entries[0].ruleId).assertEqual('ruleA');
      expect(batch.entries[0].order).assertEqual(1);
      expect(batch.entries[1].ruleId).assertEqual('ruleB');
      expect(batch.entries[1].order).assertEqual(2);
      // 后执行的规则B产生冲突标记
      expect(batch.entries[1].conflictNote !== '').assertTrue();
      // 最终设备被规则B关闭
      const aircon = engine.getDevice('aircon');
      expect(aircon!.on).assertFalse();
    });

    it('run_engine_no_trigger_when_disabled', 0, () => {
      const devices = [new Device('light_main', '主灯', DeviceType.LIGHT, '💡', false, 0)];
      const engine = new RuleEngine();
      engine.setDevices(devices);
      const rule = new Rule('r3', '昏暗开灯', [
        { field: ConditionField.ILLUMINANCE, operator: Operator.LT, value: 50 }
      ], Logic.AND, [{ deviceId: 'light_main', deviceType: DeviceType.LIGHT, on: true }], 5, false);
      engine.setRules([rule]);
      const env = new EnvState(25, 50, 10, false);
      const batch = engine.run(env, 2000);
      expect(batch.entries.length).assertEqual(0);
    });
  });
}
