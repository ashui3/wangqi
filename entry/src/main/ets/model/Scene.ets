/**
 * 场景模型
 * 一组预设的模拟环境数据，用于场景演练
 */
import { EnvState } from './EnvState';

export class Scene {
  id: string;
  name: string;
  description: string;
  /** 场景对应的环境数据 */
  env: EnvState;

  constructor(id: string, name: string, description: string, env: EnvState) {
    this.id = id;
    this.name = name;
    this.description = description;
    this.env = env;
  }
}

/** 内置默认场景（≥2 组） */
export function buildDefaultScenes(): Scene[] {
  return [
    new Scene('scene_1', '夏日午后',
      '炎热的下午，室内有人，光照充足，温度偏高（29℃ 触发开空调，未超 30℃ 节能阈值）', new EnvState(29, 40, 800, true)),
    new Scene('scene_2', '深夜无人',
      '深夜宿舍无人，温度舒适，光线昏暗', new EnvState(22, 55, 5, false)),
    new Scene('scene_3', '干燥冬季',
      '冬季室内干燥，光照弱，有人活动', new EnvState(18, 20, 120, true)),
    new Scene('scene_4', '超高温冲突',
      '极端高温有人：开空调规则与节能关空调规则同时触发，演示优先级冲突裁决', new EnvState(33, 45, 900, true))
  ];
}
