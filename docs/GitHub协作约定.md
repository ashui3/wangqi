# GitHub 协作约定

本文档规定本仓库的分支策略、提交规范与模块接口约定，供组队成员协作开发时共同遵守。

## 1. 仓库与账号

- 每组**一个仓库**，仓库名为 `dorm-automation`（或自定）。
- **所有成员必须使用本人 GitHub 账号**提交实际代码，禁止共用账号或代提交。
- 提交记录中的 `author` / `committer` 邮箱需与本人账号绑定，确保 `git log` 可追溯真实贡献。

## 2. 分支策略

采用 **GitHub Flow** 简化模型，配合功能分支开发：

| 分支 | 用途 |
| --- | --- |
| `main` | 稳定集成分支，只接受合并，不直接提交 |
| `feature/<模块>` | 功能开发分支，如 `feature/engine`、`feature/ui-device` |
| `docs/<主题>` | 文档分支，如 `docs/srs` |

协作流程：

1. 从 `main` 拉取最新代码：`git pull origin main`
2. 创建功能分支：`git checkout -b feature/<模块>`
3. 开发并提交（遵循第 3 节规范）
4. 推送并创建 Pull Request（PR）
5. 至少一名成员 review 后合并入 `main`

## 3. 提交规范

采用 `type(scope): subject` 格式，type 取值：

| type | 含义 |
| --- | --- |
| feat | 新功能 |
| fix | 修复缺陷 |
| docs | 文档变更 |
| refactor | 重构（不改变功能） |
| test | 测试相关 |
| chore | 构建/配置等杂项 |

示例：

```
feat(engine): 实现规则引擎优先级冲突裁决
fix(store): 修复规则持久化字段丢失
docs(srs): 补充数据模型与接口设计章节
```

要求：
- 每个提交聚焦单一改动，避免"大杂烩"提交。
- subject 用中文或英文，简洁描述意图（≤50 字）。

## 4. 模块接口约定

模块间通过 `AppState` 全局单例 + `EventBus` 事件总线通信，**接口定义以 `docs/软件需求说明书.md` 第 4 节为准**。各成员按分工开发对应模块，**集成前必须核对接口签名**：

| 模块 | 目录 | 关键对外接口 |
| --- | --- | --- |
| 数据模型 | `entry/src/main/ets/model/` | `Device`、`EnvState`、`Rule`、`LogEntry`、`Scene` |
| 规则引擎 | `entry/src/main/ets/engine/` | `RuleEngine.run()`、`evaluateRule()`、`evaluateCondition()` |
| 持久化 | `entry/src/main/ets/store/StoreManager.ets` | `saveDevices/loadDevices/saveRules/loadRules/appendLog/loadLogs` |
| 状态管理 | `entry/src/main/ets/store/AppState.ets` | `updateEnv/runEngine/toggleDevice/addRule/...` |
| 事件通信 | `entry/src/main/ets/common/EventBus.ets` | `emit/onEvent/offEvent` |
| UI 层 | `entry/src/main/ets/pages/` | 五个页面组件 |

**约定原则**：
- 模型层字段名、枚举值一旦定稿，改动需在 PR 中说明并同步所有调用方。
- 引擎层 `run(env)` 的入参出参（`EnvState` → `ExecutionBatch`）不可随意变更。
- 新增接口需先更新 SRS 文档，再提交代码。

## 5. 分工表（示例，按实际组员填写）

| 成员（GitHub 账号） | 负责模块 | 提交目录 |
| --- | --- | --- |
| 成员A | 数据模型 + 规则引擎 | `model/`、`engine/` |
| 成员B | 持久化 + 状态管理 | `store/`、`common/` |
| 成员C | UI 层五个页面 | `pages/` |
| 成员D | 单元测试 + 文档 | `ohosTest/`、`docs/` |

> 独立学生：本人承担整体设计与集成，在 SRS 分工表中注明"独立完成"。

## 6. 验收清单

- [ ] SRS 文档已保存至 `docs/软件需求说明书.md`
- [ ] 每位成员均有本人账号的实际提交记录
- [ ] 各模块接口与 SRS 第 4 节一致
- [ ] `ohosTest` 单元测试可运行通过
- [ ] 关闭进程重开可恢复数据
- [ ] 组队项目完成跨模块集成（独立学生完成整体设计集成）
