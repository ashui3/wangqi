# 联动实验室 —— 智能宿舍自动化规则编排 App

面向智能宿舍管理，学生可以自行设计「满足条件时执行设备动作」的自动联动方案，并利用模拟环境检验效果。项目基于 **HarmonyOS / ArkTS** 开发，不依赖真实硬件或云平台，全部使用 Mock 数据与本地存储。

## 一、功能特性

| 需求 | 实现 |
| --- | --- |
| ≥4 类可控制设备 | 灯、空调、窗帘、加湿器（`DeviceType` 枚举 + `Device` 模型） |
| ≥3 项可调模拟环境 | 温度、湿度、光照、是否有人（`EnvState` 模型，滑块实时调节） |
| ≥4 条规则（含双条件） | 默认内置 5 条规则，其中含「温度>28 且 有人」双条件 AND 规则、OR 规则 |
| 规则增删改、启停 | `RulePage` 支持新增/编辑/删除/启停，`AppState` 提供对应方法 |
| 规则引擎按实际输入计算 | `RuleEngine.run(env)` 评估所有规则条件并执行动作 |
| 记录触发条件、设备变化、执行顺序 | `LogEntry` 模型 + `LogPage` 展示 |
| 冲突优先级处理 | 规则 `priority` 字段（越小越先执行），同设备多规则冲突按优先级裁决并记录冲突说明 |
| ≥2 组场景演练 | 内置 3 组场景（夏日午后、深夜无人、干燥冬季），一键载入环境 |
| 保存设备/规则/记录，重启恢复 | `StoreManager`：Preferences 存设备状态，RDB 存规则与日志 |
| 完整体验闭环 | 创建规则 → 调 Mock 环境 → 观察联动与日志 → 发现冲突并调整 → 退出重启恢复 |

## 二、技术栈

- **语言**：ArkTS
- **UI 框架**：ArkUI（声明式）
- **状态管理**：`@Observed` / `@ObjectLink`（`AppState` 全局单例）
- **事件通信**：`@ohos.events.emitter`（`EventBus` 封装）
- **持久化**：`@ohos.data.preferences`（设备状态）+ `@ohos.data.relationalStore`（规则、日志）
- **条件判断**：纯函数 `ConditionEvaluator`（可单元测试）
- **单元测试**：`@ohos/hypium`

## 三、目录结构

```
dorm-automation/
├── AppScope/
│   ├── app.json5
│   └── resources/
├── entry/
│   ├── build-profile.json5
│   ├── hvigorfile.ts
│   ├── oh-package.json5
│   ├── obfuscation-rules.txt
│   └── src/
│       ├── main/
│       │   ├── module.json5
│       │   ├── ets/
│       │   │   ├── entryability/EntryAbility.ets
│       │   │   ├── entrybackupability/EntryBackupAbility.ets
│       │   │   ├── model/           # 数据模型
│       │   │   │   ├── Device.ets
│       │   │   │   ├── EnvState.ets
│       │   │   │   ├── Rule.ets
│       │   │   │   ├── Log.ets
│       │   │   │   └── Scene.ets
│       │   │   ├── engine/          # 规则引擎
│       │   │   │   ├── ConditionEvaluator.ets
│       │   │   │   └── RuleEngine.ets
│       │   │   ├── store/           # 状态与持久化
│       │   │   │   ├── AppState.ets
│       │   │   │   └── StoreManager.ets
│       │   │   ├── common/          # 事件总线与默认数据
│       │   │   │   ├── EventBus.ets
│       │   │   │   └── DefaultData.ets
│       │   │   └── pages/           # 页面
│       │   │       ├── Index.ets
│       │   │       ├── DevicePage.ets
│       │   │       ├── EnvPage.ets
│       │   │       ├── RulePage.ets
│       │   │       ├── ScenePage.ets
│       │   │       └── LogPage.ets
│       │   └── resources/
│       └── ohosTest/                # 单元测试
│           ├── module.json5
│           └── ets/
│               ├── test/
│               │   ├── List.test.ets
│               │   ├── ConditionEvaluator.test.ets
│               │   ├── RuleEngine.test.ets
│               │   └── DefaultData.test.ets
│               ├── TestAbility/TestAbility.ets
│               └── TestAbility/pages/Index.ets
├── docs/                           # 项目文档
│   ├── 软件需求说明书.md
│   └── GitHub协作约定.md
├── build-profile.json5
├── hvigorfile.ts
├── hvigor/hvigor-config.json5
├── oh-package.json5
└── .gitignore
```

## 四、核心设计

### 1. 规则模型（Trigger/Condition/Action 三要素）

```typescript
class Rule {
  id: string;
  name: string;
  enabled: boolean;      // 启停
  conditions: Condition[]; // 可多个条件（支持双条件）
  logic: Logic;            // AND / OR
  actions: Action[];       // 设备动作
  priority: number;        // 优先级，越小越先执行
}
```

条件 `Condition = { field, operator, value }`，`field` 取自环境数据（温度/湿度/光照/是否有人）。

### 2. 双条件规则（核心能力）

**规则支持由多个条件共同决定触发**。`conditions` 是数组，`logic` 决定多个条件如何组合：

| logic | 语义 | 触发条件 |
| --- | --- | --- |
| `AND` | 所有条件**同时满足**才触发 | `conditions.every(...)` |
| `OR` | 任一条件满足即触发 | `conditions.some(...)` |

**内置双条件规则示例**（`common/DefaultData.ets`）：

> 规则「高温且有人开空调」—— 当 **温度 > 28** **且（AND）** **有人** 两个条件同时满足时，自动开启空调并设为 24℃。

```typescript
new Rule(
  'rule_hot_occupy',
  '高温且有人开空调',
  [
    { field: ConditionField.TEMPERATURE, operator: Operator.GT, value: 28 }, // 条件1
    { field: ConditionField.OCCUPANCY,  operator: Operator.EQ, value: 1  }  // 条件2
  ],
  Logic.AND,  // 两个条件共同决定（缺一不可）
  [{ deviceId: 'aircon', deviceType: DeviceType.AIRCON, on: true, setValue: 24 }],
  1, true
);
```

**引擎求值实现**（`engine/RuleEngine.ets` 的 `evaluateRule`）：

```typescript
const results = rule.conditions.map((c) => evaluateCondition(c, env));
const triggered = rule.logic === Logic.AND
  ? results.every((r) => r === true)   // 双条件：全部满足
  : results.some((r) => r === true);   // 单/多条件：任一满足
```

> 验收对应：温度 28℃ 且无人 → 不触发；温度 29℃ 且有人 → 触发。该双条件行为已有单元测试覆盖（见 `RuleEngine.test.ets` 的 `evaluateRule_double_condition_and` 用例）。

### 3. 规则引擎执行流程

1. 遍历所有**启用**的规则，用 `evaluateRule(rule, env)` 求值；
2. 按 `priority` 升序排序（同优先级按 id 稳定排序）；
3. 依次执行动作，同一设备被多条规则操控时，检测冲突并记录；
4. 生成 `ExecutionBatch` 日志（含触发条件、设备变化、执行顺序、冲突说明）。

### 4. 冲突处理示例（内置规则已演示）

- 规则「高温且有人开空调」：温度>28 且 有人 → 空调开(24℃)，优先级 1
- 规则「超高温节能关空调」：温度>30 → 空调关，优先级 2

当温度 31℃ 且有人时，两条规则同时触发并都控制空调。引擎先执行优先级 1 的「开空调」，再执行优先级 2 的「关空调」，最终设备关闭，并在日志中标记冲突说明。

### 5. 持久化

- **Preferences**（`dorm_automation`）：设备开关与数值状态、环境数据
- **RDB**（`dorm.db`）：`rules` 表（规则）、`logs` 表（执行记录）

应用启动时 `EntryAbility.onCreate` 调用 `StoreManager.init()` + `appState.restore()` 恢复状态。

## 五、运行方式

1. 用 **DevEco Studio（API 12 / HarmonyOS 5.0.0）** 打开本项目根目录；
2. 同步依赖后，选择 `entry` 模块在模拟器或真机运行；
3. 单元测试：运行 `ohosTest` 目标（`TestAbility` 触发 Hypium 测试套件）。

## 六、需求覆盖对照

| 验收点 | 覆盖位置 |
| --- | --- |
| 4 类设备 | `model/Device.ets` + `common/DefaultData.ets` |
| 3 项环境数据 | `model/EnvState.ets`（温度/湿度/光照/是否有人 = 4 项） |
| 4 条规则含双条件 | `common/DefaultData.ets`（内置 5 条） |
| 规则引擎实际计算 | `engine/RuleEngine.ets` + `engine/ConditionEvaluator.ets` |
| 记录触发条件/设备变化/顺序 | `engine/RuleEngine.ets` run() + `model/Log.ets` |
| 冲突优先级 | `priority` 字段 + run() 排序 + 冲突标记 |
| 2 组场景 | `model/Scene.ets`（3 组） |
| 保存并重启恢复 | `store/StoreManager.ets`（Preferences + RDB） |
| Mock 数据 | `common/DefaultData.ets` |
| ArkTS 条件判断 | `engine/ConditionEvaluator.ets`（纯函数） |
| 状态管理 | `store/AppState.ets`（@Observed） |
| 事件通信 | `common/EventBus.ets`（emitter） |
| 单元测试 | `entry/src/ohosTest/ets/test/*.test.ets` |

## 七、参考项目

- [zhyU0-0/Intelligent_furnitures_control_app](https://github.com/zhyU0-0/Intelligent_furnitures_control_app) —— OpenHarmony 智能家居场景控制系统（RDB 存储 + 场景控制）
- [Explore-In-HMOS/smart-home](https://github.com/Explore-In-HMOS/smart-home) —— ArkTS 智能灯控，Store/Reducer/ViewModel 分层
- [Explore-In-HMOS/smart-music-scheduler](https://github.com/Explore-In-HMOS/smart-music-scheduler) —— 定时触发 + 动作模式

## 八、项目文档

| 文档 | 说明 |
| --- | --- |
| [docs/软件需求说明书.md](docs/软件需求说明书.md) | 选题功能、模块、数据模型、接口、分工、测试与验收方式 |
| [docs/GitHub协作约定.md](docs/GitHub协作约定.md) | 分支策略、提交规范、模块接口约定、分工表 |

## 九、License

Apache-2.0
