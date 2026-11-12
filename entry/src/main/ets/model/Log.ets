/**
 * 执行日志模型
 * 记录触发条件、设备变化、执行顺序与冲突裁决结果
 */
export interface LogEntry {
  id: string;
  /** 时间戳（毫秒） */
  timestamp: number;
  /** 触发的规则 ID */
  ruleId: string;
  /** 规则名称 */
  ruleName: string;
  /** 触发时的环境快照描述 */
  triggerCondition: string;
  /** 该规则此次执行在整体链路中的顺序序号 */
  order: number;
  /** 设备变化描述列表 */
  deviceChanges: string[];
  /** 是否因冲突被跳过/延迟 */
  conflictNote: string;
}

/** 执行批次：一次环境变化引发的所有规则按顺序执行的快照 */
export interface ExecutionBatch {
  id: string;
  timestamp: number;
  envSnapshot: string;
  entries: LogEntry[];
}
