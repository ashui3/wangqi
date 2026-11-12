/**
 * 事件通信常量与工具
 * 使用 @ohos.events.emitter 实现跨组件事件通知
 * 注意：负载仅用于通知"发生了什么"，不携带复杂对象，避免 ArkTS 对象字面量限制
 */
import emitter from '@ohos.events.emitter';

/** 事件类型 */
export enum EventType {
  /** 环境数据变化，触发规则重算 */
  ENV_CHANGED = 'event.env.changed',
  /** 设备状态变化 */
  DEVICE_CHANGED = 'event.device.changed',
  /** 规则列表变化（增删改、启停） */
  RULE_CHANGED = 'event.rule.changed',
  /** 执行日志更新 */
  LOG_UPDATED = 'event.log.updated',
  /** 场景载入 */
  SCENE_LOADED = 'event.scene.loaded'
}

/** 事件数据包装 */
export interface EventData {
  type: EventType;
}

/**
 * 广播事件
 */
export function emit(type: EventType): void {
  const event: emitter.InnerEvent = {
    eventId: 1,
    priority: emitter.EventPriority.LOW
  };
  const data: EventData = { type: type };
  emitter.emit(event, { data: data });
}

/**
 * 订阅事件
 */
export function onEvent(callback: (data: EventData) => void): void {
  const event: emitter.InnerEvent = {
    eventId: 1,
    priority: emitter.EventPriority.LOW
  };
  emitter.on(event, (inner: emitter.EventData) => {
    const data = inner?.data as EventData;
    if (data) {
      callback(data);
    }
  });
}

/**
 * 取消订阅
 */
export function offEvent(): void {
  emitter.off(1);
}
