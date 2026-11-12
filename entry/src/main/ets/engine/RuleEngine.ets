/**
 * 规则引擎核心
 * 根据实际环境输入计算触发结果，处理执行顺序与冲突
 */
import { Rule, Logic, Condition } from '../model/Rule';
import { EnvState } from '../model/EnvState';
import { Device } from '../model/Device';
import { LogEntry, ExecutionBatch } from '../model/Log';
import { evaluateCondition, describeCondition } from './ConditionEvaluator';

/**
 * 规则求值结果
 */
export interface RuleEvaluation {
  rule: Rule;
  /** 是否触发 */
  triggered: boolean;
  /** 触发时的条件描述 */
  conditionDesc: string;
}

/**
 * 设备变更描述（用于日志）
 */
export interface DeviceChange {
  deviceId: string;
  from: string;
  to: string;
}

/**
 * 计算一条规则的触发结果
 */
export function evaluateRule(rule: Rule, env: EnvState): RuleEvaluation {
  if (!rule.enabled) {
    return { rule: rule, triggered: false, conditionDesc: '规则已停用' };
  }
  if (rule.conditions.length === 0) {
    return { rule: rule, triggered: false, conditionDesc: '无条件' };
  }

  const results: boolean[] = rule.conditions.map((c: Condition) => evaluateCondition(c, env));
  let triggered = false;
  if (rule.logic === Logic.AND) {
    triggered = results.every((r: boolean) => r === true);
  } else {
    triggered = results.some((r: boolean) => r === true);
  }

  const desc = rule.conditions.map((c: Condition) => describeCondition(c))
    .join(rule.logic === Logic.AND ? ' 且 ' : ' 或 ');

  return { rule: rule, triggered: triggered, conditionDesc: desc };
}

/**
 * 规则引擎
 * 维护设备列表，评估所有规则并按优先级决定执行顺序，处理设备冲突
 */
export class RuleEngine {
  /** 所有规则 */
  private rules: Rule[] = [];
  /** 设备映射（id -> Device） */
  private devices: Map<string, Device> = new Map<string, Device>();

  setRules(rules: Rule[]): void {
    this.rules = rules;
  }

  getRules(): Rule[] {
    return this.rules;
  }

  setDevices(devices: Device[]): void {
    this.devices = new Map<string, Device>();
    devices.forEach((d: Device) => this.devices.set(d.id, d));
  }

  getDevice(id: string): Device | undefined {
    return this.devices.get(id);
  }

  getDevices(): Device[] {
    return Array.from(this.devices.values());
  }

  /**
   * 执行一次联动：评估所有规则，按优先级排序执行，返回执行批次日志
   */
  run(env: EnvState, now: number = Date.now()): ExecutionBatch {
    const evaluations: RuleEvaluation[] = this.rules.map((r: Rule) => evaluateRule(r, env));
    const triggered = evaluations.filter((e: RuleEvaluation) => e.triggered);

    // 按优先级升序排序（priority 越小越先执行），同优先级按规则 id 稳定排序
    triggered.sort((a: RuleEvaluation, b: RuleEvaluation) => {
      if (a.rule.priority !== b.rule.priority) {
        return a.rule.priority - b.rule.priority;
      }
      return a.rule.id.localeCompare(b.rule.id);
    });

    const entries: LogEntry[] = [];
    const batchId = `batch_${now}_${Math.floor(Math.random() * 10000)}`;

    let order = 1;
    // 记录本批次内已被占用的设备（用于冲突检测）
    const touchedDevices = new Set<string>();

    triggered.forEach((ev: RuleEvaluation, idx: number) => {
      const changes: DeviceChange[] = [];
      const changeDescs: string[] = [];
      let conflictNote = '';

      ev.rule.actions.forEach((action) => {
        const dev = this.devices.get(action.deviceId);
        if (!dev) {
          return;
        }
        // 冲突检测：同一设备在本批次中被多条规则操控
        const conflict = touchedDevices.has(action.deviceId);
        touchedDevices.add(action.deviceId);

        const from = this.describeDevice(dev);
        // 应用动作
        dev.on = action.on;
        if (action.setValue !== undefined) {
          dev.value = action.setValue;
        }
        dev.lastRuleId = ev.rule.id;
        const to = this.describeDevice(dev);

        changes.push({ deviceId: dev.id, from: from, to: to });
        changeDescs.push(`${dev.name}: ${from} → ${to}`);
        if (conflict) {
          conflictNote = `[冲突] 设备「${dev.name}」被多条规则操控，本条规则(优先级${ev.rule.priority})较后执行，最终以本条为准`;
        }
      });

      entries.push({
        id: `log_${now}_${idx}`,
        timestamp: now,
        ruleId: ev.rule.id,
        ruleName: ev.rule.name,
        triggerCondition: ev.conditionDesc,
        order: order++,
        deviceChanges: changeDescs,
        conflictNote: conflictNote
      });
    });

    return {
      id: batchId,
      timestamp: now,
      envSnapshot: `温度${env.temperature}℃ 湿度${env.humidity}% 光照${env.illuminance}lux ${env.occupancy ? '有人' : '无人'}`,
      entries: entries
    };
  }

  /**
   * 设备状态可读描述
   */
  private describeDevice(dev: Device): string {
    const state = dev.on ? '开' : '关';
    // 带数值属性的设备展示数值
    const hasValue = dev.type === 'light' || dev.type === 'aircon' || dev.type === 'curtain';
    if (hasValue) {
      return `${state}(${dev.value})`;
    }
    return state;
  }
}
