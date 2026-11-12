/**
 * 数据存储管理（Preferences + RDB）
 * - Preferences：存储设备设置（开关/数值）与规则开关等轻量状态
 * - RDB：存储联动规则与执行记录（结构化数据）
 * 应用启动时从存储恢复状态，实现「退出重启恢复规则」
 */
import preferences from '@ohos.data.preferences';
import relationalStore from '@ohos.data.relationalStore';
import common from '@ohos.app.ability.common';
import { Device } from '../model/Device';
import { EnvState } from '../model/EnvState';
import { Rule, Condition, ConditionField, Operator, Logic, Action } from '../model/Rule';
import { LogEntry, ExecutionBatch } from '../model/Log';
import { buildDefaultDevices, buildDefaultRules } from '../common/DefaultData';

const PREFERENCES_NAME = 'dorm_automation';
const DB_NAME = 'dorm.db';

/** 设备状态序列化（存 Preferences） */
class DevicePref {
  id: string;
  on: boolean;
  value: number;

  constructor(id: string, on: boolean, value: number) {
    this.id = id;
    this.on = on;
    this.value = value;
  }
}

/** 环境数据序列化（存 Preferences） */
interface EnvPref {
  temperature: number;
  humidity: number;
  illuminance: number;
  occupancy: boolean;
}

export class StoreManager {
  private static instance: StoreManager;
  private pref: preferences.Preferences | null = null;
  private rdbStore: relationalStore.RdbStore | null = null;
  private context: common.UIAbilityContext | null = null;

  static getInstance(): StoreManager {
    if (!StoreManager.instance) {
      StoreManager.instance = new StoreManager();
    }
    return StoreManager.instance;
  }

  /**
   * 初始化存储（在 Ability onCreate 中调用）
   */
  async init(context: common.UIAbilityContext): Promise<void> {
    this.context = context;
    this.pref = await preferences.getPreferences(context, PREFERENCES_NAME);

    const config: relationalStore.StoreConfig = {
      name: DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };
    this.rdbStore = await relationalStore.getRdbStore(context, config);
    await this.createTables();
  }

  /**
   * 创建数据库表
   */
  private async createTables(): Promise<void> {
    if (!this.rdbStore) {
      return;
    }
    const sqlRule = `CREATE TABLE IF NOT EXISTS rules (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      enabled INTEGER NOT NULL,
      conditions TEXT NOT NULL,
      logic TEXT NOT NULL,
      actions TEXT NOT NULL,
      priority INTEGER NOT NULL
    )`;
    const sqlLog = `CREATE TABLE IF NOT EXISTS logs (
      id TEXT PRIMARY KEY,
      batch_id TEXT NOT NULL,
      timestamp INTEGER NOT NULL,
      rule_id TEXT NOT NULL,
      rule_name TEXT NOT NULL,
      trigger_condition TEXT NOT NULL,
      order_no INTEGER NOT NULL,
      device_changes TEXT NOT NULL,
      conflict_note TEXT NOT NULL
    )`;
    await this.rdbStore.executeSql(sqlRule);
    await this.rdbStore.executeSql(sqlLog);
  }

  // ==================== 设备状态（Preferences） ====================

  /**
   * 保存设备状态到 Preferences
   */
  async saveDevices(devices: Device[]): Promise<void> {
    if (!this.pref) {
      return;
    }
    const list: DevicePref[] = devices.map((d: Device) => new DevicePref(d.id, d.on, d.value));
    await this.pref.put('devices', JSON.stringify(list));
    await this.pref.flush();
  }

  /**
   * 从 Preferences 恢复设备状态；无记录则返回默认设备
   */
  async loadDevices(): Promise<Device[]> {
    const defaults = buildDefaultDevices();
    if (!this.pref) {
      return defaults;
    }
    const raw = await this.pref.get('devices', '');
    if (!raw || raw === '') {
      return defaults;
    }
    try {
      const list: DevicePref[] = JSON.parse(raw as string) as DevicePref[];
      return defaults.map((d: Device) => {
        const found = list.find((p: DevicePref) => p.id === d.id);
        if (found) {
          d.on = found.on;
          d.value = found.value;
        }
        return d;
      });
    } catch (e) {
      return defaults;
    }
  }

  // ==================== 环境数据（Preferences） ====================

  /**
   * 保存环境数据到 Preferences
   */
  async saveEnv(env: EnvState): Promise<void> {
    if (!this.pref) {
      return;
    }
    const data: EnvPref = {
      temperature: env.temperature,
      humidity: env.humidity,
      illuminance: env.illuminance,
      occupancy: env.occupancy
    };
    await this.pref.put('env', JSON.stringify(data));
    await this.pref.flush();
  }

  /**
   * 从 Preferences 恢复环境数据；无记录则返回默认环境
   */
  async loadEnv(): Promise<EnvState> {
    if (!this.pref) {
      return new EnvState();
    }
    const raw = await this.pref.get('env', '');
    if (!raw || raw === '') {
      return new EnvState();
    }
    try {
      const data = JSON.parse(raw as string) as EnvPref;
      return new EnvState(data.temperature, data.humidity, data.illuminance, data.occupancy);
    } catch (e) {
      return new EnvState();
    }
  }

  // ==================== 规则（RDB） ====================

  /**
   * 保存全部规则到 RDB（全量覆盖）
   */
  async saveRules(rules: Rule[]): Promise<void> {
    if (!this.rdbStore) {
      return;
    }
    await this.rdbStore.executeSql('DELETE FROM rules');
    for (const r of rules) {
      const valueBucket: relationalStore.ValuesBucket = {
        id: r.id,
        name: r.name,
        enabled: r.enabled ? 1 : 0,
        conditions: JSON.stringify(r.conditions),
        logic: r.logic,
        actions: JSON.stringify(r.actions),
        priority: r.priority
      };
      await this.rdbStore.insert('rules', valueBucket);
    }
  }

  /**
   * 从 RDB 加载全部规则；无记录则返回默认规则
   */
  async loadRules(): Promise<Rule[]> {
    if (!this.rdbStore) {
      return buildDefaultRules();
    }
    const predicates = new relationalStore.RdbPredicates('rules');
    const resultSet = await this.rdbStore.query(predicates);
    const rules: Rule[] = [];
    while (resultSet.goToNextRow()) {
      const id = resultSet.getString(resultSet.getColumnIndex('id'));
      const name = resultSet.getString(resultSet.getColumnIndex('name'));
      const enabled = resultSet.getLong(resultSet.getColumnIndex('enabled')) === 1;
      const conditions: Condition[] = JSON.parse(resultSet.getString(resultSet.getColumnIndex('conditions'))) as Condition[];
      const logic = resultSet.getString(resultSet.getColumnIndex('logic')) as Logic;
      const actions: Action[] = JSON.parse(resultSet.getString(resultSet.getColumnIndex('actions'))) as Action[];
      const priority = resultSet.getLong(resultSet.getColumnIndex('priority'));
      rules.push(new Rule(id, name, conditions, logic, actions, priority, enabled));
    }
    resultSet.close();
    if (rules.length === 0) {
      return buildDefaultRules();
    }
    return rules;
  }

  // ==================== 执行记录（RDB） ====================

  /**
   * 追加执行批次日志
   */
  async appendLog(batch: ExecutionBatch): Promise<void> {
    if (!this.rdbStore) {
      return;
    }
    for (const entry of batch.entries) {
      const valueBucket: relationalStore.ValuesBucket = {
        id: entry.id,
        batch_id: batch.id,
        timestamp: entry.timestamp,
        rule_id: entry.ruleId,
        rule_name: entry.ruleName,
        trigger_condition: entry.triggerCondition,
        order_no: entry.order,
        device_changes: JSON.stringify(entry.deviceChanges),
        conflict_note: entry.conflictNote
      };
      await this.rdbStore.insert('logs', valueBucket);
    }
  }

  /**
   * 加载全部执行记录（按时间倒序）
   */
  async loadLogs(): Promise<LogEntry[]> {
    if (!this.rdbStore) {
      return [];
    }
    const predicates = new relationalStore.RdbPredicates('logs');
    predicates.orderByDesc('timestamp');
    const resultSet = await this.rdbStore.query(predicates);
    const logs: LogEntry[] = [];
    while (resultSet.goToNextRow()) {
      logs.push({
        id: resultSet.getString(resultSet.getColumnIndex('id')),
        timestamp: resultSet.getLong(resultSet.getColumnIndex('timestamp')),
        ruleId: resultSet.getString(resultSet.getColumnIndex('rule_id')),
        ruleName: resultSet.getString(resultSet.getColumnIndex('rule_name')),
        triggerCondition: resultSet.getString(resultSet.getColumnIndex('trigger_condition')),
        order: resultSet.getLong(resultSet.getColumnIndex('order_no')),
        deviceChanges: JSON.parse(resultSet.getString(resultSet.getColumnIndex('device_changes'))) as string[],
        conflictNote: resultSet.getString(resultSet.getColumnIndex('conflict_note'))
      });
    }
    resultSet.close();
    return logs;
  }

  /**
   * 清空执行记录
   */
  async clearLogs(): Promise<void> {
    if (!this.rdbStore) {
      return;
    }
    await this.rdbStore.executeSql('DELETE FROM logs');
  }
}
