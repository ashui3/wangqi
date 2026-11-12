/**
 * 全局应用状态（状态管理）
 * 使用 @Observed + @ObjectLink 实现响应式状态
 */
import { Device } from '../model/Device';
import { EnvState } from '../model/EnvState';
import { Rule } from '../model/Rule';
import { LogEntry } from '../model/Log';
import { Scene } from '../model/Scene';
import { RuleEngine } from '../engine/RuleEngine';
import { StoreManager } from './StoreManager';
import { buildDefaultDevices, buildDefaultRules } from '../common/DefaultData';
import { buildDefaultScenes } from '../model/Scene';
import { emit, EventType } from '../common/EventBus';

@Observed
export class AppState {
  /** 设备列表 */
  devices: Device[] = buildDefaultDevices();
  /** 模拟环境数据 */
  env: EnvState = new EnvState();
  /** 规则列表 */
  rules: Rule[] = buildDefaultRules();
  /** 执行日志（倒序） */
  logs: LogEntry[] = [];
  /** 场景列表 */
  scenes: Scene[] = buildDefaultScenes();
  /** 是否已初始化（从存储恢复完成） */
  initialized: boolean = false;

  /** 规则引擎实例 */
  private engine: RuleEngine = new RuleEngine();
  private store: StoreManager = StoreManager.getInstance();

  constructor() {
    this.engine.setDevices(this.devices);
    this.engine.setRules(this.rules);
  }

  /**
   * 从存储恢复状态（启动时调用）
   */
  async restore(): Promise<void> {
    this.devices = await this.store.loadDevices();
    this.rules = await this.store.loadRules();
    this.logs = await this.store.loadLogs();
    this.env = await this.store.loadEnv();
    this.engine.setDevices(this.devices);
    this.engine.setRules(this.rules);
    this.initialized = true;
  }

  /**
   * 更新环境数据并触发规则重算
   */
  async updateEnv(partial: Partial<EnvState>): Promise<void> {
    Object.assign(this.env, partial);
    await this.store.saveEnv(this.env);
    emit(EventType.ENV_CHANGED, { env: this.env as Object });
    await this.runEngine();
  }

  /**
   * 运行规则引擎，执行联动并记录日志
   */
  async runEngine(): Promise<void> {
    this.engine.setDevices(this.devices);
    this.engine.setRules(this.rules);
    const batch = this.engine.run(this.env);
    if (batch.entries.length > 0) {
      await this.store.appendLog(batch);
      await this.store.saveDevices(this.devices);
      this.logs = (await this.store.loadLogs()).slice(0, 100);
      emit(EventType.DEVICE_CHANGED);
      emit(EventType.LOG_UPDATED);
    }
  }

  /**
   * 手动切换设备
   */
  async toggleDevice(id: string): Promise<void> {
    const dev = this.devices.find((d: Device) => d.id === id);
    if (dev) {
      dev.on = !dev.on;
      await this.store.saveDevices(this.devices);
      emit(EventType.DEVICE_CHANGED);
    }
  }

  /**
   * 手动设置设备数值
   */
  async setDeviceValue(id: string, value: number): Promise<void> {
    const dev = this.devices.find((d: Device) => d.id === id);
    if (dev) {
      dev.value = value;
      await this.store.saveDevices(this.devices);
      emit(EventType.DEVICE_CHANGED);
    }
  }

  /**
   * 新增规则
   */
  async addRule(rule: Rule): Promise<void> {
    this.rules.push(rule);
    await this.persistRules();
  }

  /**
   * 修改规则
   */
  async updateRule(rule: Rule): Promise<void> {
    const idx = this.rules.findIndex((r: Rule) => r.id === rule.id);
    if (idx >= 0) {
      this.rules[idx] = rule;
      await this.persistRules();
    }
  }

  /**
   * 删除规则
   */
  async deleteRule(id: string): Promise<void> {
    this.rules = this.rules.filter((r: Rule) => r.id !== id);
    await this.persistRules();
  }

  /**
   * 启停规则
   */
  async toggleRule(id: string): Promise<void> {
    const rule = this.rules.find((r: Rule) => r.id === id);
    if (rule) {
      rule.enabled = !rule.enabled;
      await this.persistRules();
    }
  }

  /**
   * 载入场景
   */
  async loadScene(sceneId: string): Promise<void> {
    const scene = this.scenes.find((s: Scene) => s.id === sceneId);
    if (scene) {
      this.env = new EnvState(scene.env.temperature, scene.env.humidity,
        scene.env.illuminance, scene.env.occupancy);
      await this.store.saveEnv(this.env);
      emit(EventType.SCENE_LOADED, { sceneId: sceneId });
      await this.runEngine();
    }
  }

  /**
   * 清空日志
   */
  async clearLogs(): Promise<void> {
    await this.store.clearLogs();
    this.logs = [];
    emit(EventType.LOG_UPDATED);
  }

  private async persistRules(): Promise<void> {
    this.engine.setRules(this.rules);
    await this.store.saveRules(this.rules);
    emit(EventType.RULE_CHANGED);
  }
}

/** 全局单例 */
export const appState: AppState = new AppState();
