/**
 * 数据模型与默认数据单元测试
 */
import { describe, it, expect } from '@ohos/hypium';
import { buildDefaultDevices, buildDefaultRules } from '../../../main/ets/common/DefaultData';
import { buildDefaultScenes } from '../../../main/ets/model/Scene';

export default function defaultDataTest() {
  describe('DefaultDataTest', () => {
    it('default_devices_has_4_types', 0, () => {
      const devices = buildDefaultDevices();
      expect(devices.length >= 4).assertTrue();
      const types: string[] = [];
      devices.forEach((d) => {
        if (types.indexOf(d.type) < 0) {
          types.push(d.type);
        }
      });
      expect(types.length >= 4).assertTrue();
    });

    it('default_rules_has_4_and_double_condition', 0, () => {
      const rules = buildDefaultRules();
      expect(rules.length >= 4).assertTrue();
      // 至少一条规则包含两个条件
      const hasDouble = rules.some((r) => r.conditions.length >= 2);
      expect(hasDouble).assertTrue();
    });

    it('default_scenes_has_at_least_2', 0, () => {
      const scenes = buildDefaultScenes();
      expect(scenes.length >= 2).assertTrue();
    });
  });
}
