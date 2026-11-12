/**
 * 事件通信工具
 * 使用 @ohos.events.emitter 实现跨组件事件通知
 * 每个订阅者使用独立的 eventId，避免 offEvent 互相干扰
 */
import emitter from '@ohos.events.emitter';

/** 事件类型 */
export enum EventType {
  ENV_CHANGED = 'event.env.changed',
  DEVICE_CHANGED = 'event.device.changed',
  RULE_CHANGED = 'event.rule.changed',
  LOG_UPDATED = 'event.log.updated',
  SCENE_LOADED = 'event.scene.loaded'
}

/** 事件数据 */
export interface EventData {
  type: EventType;
}

/** 广播事件的公共 eventId（所有 emit/on 共用） */
const BROADCAST_EVENT_ID: number = 1001;

/**
 * 广播事件
 */
export function emit(type: EventType): void {
  const data: emitter.EventData = { data: { type: type } };
  emitter.emit({ eventId: BROADCAST_EVENT_ID, priority: emitter.EventPriority.IMMEDIATE }, data);
}

/**
 * 订阅事件
 * 返回取消订阅函数
 */
export function onEvent(callback: (data: EventData) => void): () => void {
  const listener = (data: emitter.EventData): void => {
    const payload = data?.data;
    if (payload) {
      const type = payload['type'] as EventType;
      if (type) {
        callback({ type: type });
      }
    }
  };
  emitter.on({ eventId: BROADCAST_EVENT_ID, priority: emitter.EventPriority.IMMEDIATE }, listener);
  return (): void => {
    emitter.off(BROADCAST_EVENT_ID, listener);
  };
}

/**
 * 取消订阅（兼容旧接口，用于不关心返回值时手动退订）
 */
export function offEvent(): void {
  emitter.off(BROADCAST_EVENT_ID);
}
