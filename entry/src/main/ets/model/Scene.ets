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
      '炎热的下午，室内有人，光照充足，温度偏高', new EnvState(32, 40, 800, true)),
    new Scene('scene_2', '深夜无人',
      '深夜宿舍无人，温度舒适，光线昏暗', new EnvState(22, 55, 5, false)),
    new Scene('scene_3', '干燥冬季',
      '冬季室内干燥，光照弱，有人活动', new EnvState(18, 20, 120, true))
  ];
}
