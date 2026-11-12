/**
 * 规则管理页
 * 展示规则列表，支持新增、修改、启停、删除
 */
import { Rule, Logic, Condition, ConditionField, Operator, Action } from '../model/Rule';
import { DeviceType } from '../model/Device';
import { appState } from '../store/AppState';
import { describeCondition } from '../engine/ConditionEvaluator';
import { onEvent, offEvent, EventData } from '../common/EventBus';

@Component
export struct RulePage {
  @State showEditor: boolean = false;
  @State editingRule: Rule | null = null;
  @State refreshFlag: number = 0;

  aboutToAppear(): void {
    onEvent((data: EventData) => {
      this.refreshFlag++;
    });
  }

  aboutToDisappear(): void {
    offEvent();
  }

  build() {
    Column() {
      if (this.refreshFlag >= 0) {
        this.Content()
      }
    }
    .width('100%')
    .height('100%')
    .bindSheet($$this.showEditor, this.EditorSheet(), {
      height: 520,
      showClose: true,
      title: { title: this.editingRule ? '编辑规则' : '新增规则' }
    })
  }

  @Builder
  Content() {
    Column() {
      Row() {
        Text('联动规则')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
        Blank()
        Button('新增')
          .height(36)
          .backgroundColor('#1677ff')
          .fontColor('#FFFFFF')
          .borderRadius(8)
          .onClick(() => {
            this.editingRule = new Rule(
              `rule_${Date.now()}`,
              '新规则',
              [{ field: ConditionField.TEMPERATURE, operator: Operator.GT, value: 25 }],
              Logic.AND,
              [{ deviceId: 'light_main', deviceType: DeviceType.LIGHT, on: true }],
              10, true
            );
            this.showEditor = true;
          })
      }
      .width('100%')
      .margin({ top: 16, bottom: 8 })

      List({ space: 12 }) {
        ForEach(appState.rules, (rule: Rule) => {
          ListItem() {
            this.RuleCard(rule)
          }
        }, (rule: Rule) => rule.id)
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, bottom: 16 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  RuleCard(rule: Rule) {
    Column() {
      Row() {
        Text(rule.name)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
        Text(`优先级 ${rule.priority}`)
          .fontSize(12)
          .fontColor('#1677ff')
          .backgroundColor('#e8f1ff')
          .borderRadius(4)
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
      }
      .width('100%')

      Text(this.describeConditions(rule))
        .fontSize(13)
        .fontColor('#666666')
        .width('100%')
        .margin({ top: 6 })

      Text(this.describeActions(rule))
        .fontSize(13)
        .fontColor('#333333')
        .width('100%')
        .margin({ top: 4 })

      Row() {
        Toggle({ type: ToggleType.Switch, isOn: rule.enabled })
          .selectedColor('#1677ff')
          .onChange((isOn: boolean) => {
            appState.toggleRule(rule.id);
          })
        Blank()
        Button('编辑')
          .height(30)
          .fontSize(13)
          .backgroundColor('#f0f0f0')
          .fontColor('#333333')
          .borderRadius(6)
          .onClick(() => {
            this.editingRule = rule;
            this.showEditor = true;
          })
        Button('删除')
          .height(30)
          .fontSize(13)
          .backgroundColor('#ffebeb')
          .fontColor('#e33')
          .borderRadius(6)
          .margin({ left: 8 })
          .onClick(() => {
            appState.deleteRule(rule.id);
          })
      }
      .width('100%')
      .margin({ top: 10 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(rule.enabled ? '#FFFFFF' : '#F5F5F5')
    .borderRadius(12)
    .shadow({ radius: 8, color: '#14000000', offsetX: 0, offsetY: 2 })
  }

  private describeConditions(rule: Rule): string {
    if (rule.conditions.length === 0) {
      return '条件：无';
    }
    const desc = rule.conditions.map((c: Condition) => describeCondition(c))
      .join(rule.logic === Logic.AND ? ' 且 ' : ' 或 ');
    return `条件：${desc}`;
  }

  private describeActions(rule: Rule): string {
    const desc = rule.actions.map((a: Action) => {
      const name = this.deviceName(a.deviceId);
      return `${name}${a.on ? '开' : '关'}`;
    }).join('、');
    return `动作：${desc}`;
  }

  private deviceName(deviceId: string): string {
    switch (deviceId) {
      case 'light_main':
        return '主灯';
      case 'aircon':
        return '空调';
      case 'curtain':
        return '窗帘';
      case 'humidifier':
        return '加湿器';
      default:
        return deviceId;
    }
  }

  @Builder
  EditorSheet() {
    Column() {
      if (this.editingRule) {
        TextInput({ text: this.editingRule.name, placeholder: '规则名称' })
          .height(44)
          .onChange((v: string) => {
            if (this.editingRule) {
              this.editingRule.name = v;
            }
          })
          .margin({ bottom: 12 })

        Row() {
          Text('优先级')
            .fontSize(15)
          Blank()
          TextInput({ text: `${this.editingRule.priority}` })
            .height(40)
            .type(InputType.Number)
            .width(80)
            .onChange((v: string) => {
              if (this.editingRule) {
                const n = parseInt(v);
                if (!isNaN(n)) {
                  this.editingRule.priority = n;
                }
              }
            })
        }
        .width('100%')
        .margin({ bottom: 12 })

        Text('条件设置')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .margin({ bottom: 8 })

        // 条件1：温度
        Row() {
          Text('温度')
            .fontSize(14)
            .width(60)
          Select([
            { value: '温度 > 25' },
            { value: '温度 > 28' },
            { value: '温度 > 30' },
            { value: '温度 < 18' },
            { value: '湿度 < 30' },
            { value: '光照 < 50' },
            { value: '有人(是)' },
            { value: '无人(否)' }
          ])
            .selected(0)
            .layoutWeight(1)
            .onSelect((index: number) => {
              if (this.editingRule) {
                this.editingRule.conditions = this.buildConditionByPreset(index);
              }
            })
        }
        .width('100%')
        .margin({ bottom: 12 })

        Text('动作设置')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .margin({ bottom: 8 })

        Row() {
          Text('动作')
            .fontSize(14)
            .width(60)
          Select([
            { value: '主灯 开' },
            { value: '主灯 关' },
            { value: '空调 开(24℃)' },
            { value: '空调 关' },
            { value: '窗帘 关(100%)' },
            { value: '加湿器 开' }
          ])
            .selected(0)
            .layoutWeight(1)
            .onSelect((index: number) => {
              if (this.editingRule) {
                this.editingRule.actions = this.buildActionByPreset(index);
              }
            })
        }
        .width('100%')
        .margin({ bottom: 16 })

        Button('保存')
          .width('100%')
          .height(44)
          .backgroundColor('#1677ff')
          .fontColor('#FFFFFF')
          .borderRadius(8)
          .onClick(() => {
            if (this.editingRule) {
              const exists = appState.rules.some((r: Rule) => r.id === this.editingRule!.id);
              if (exists) {
                appState.updateRule(this.editingRule);
              } else {
                appState.addRule(this.editingRule);
              }
              this.showEditor = false;
            }
          })
      }
    }
    .width('100%')
    .padding(20)
  }

  private buildConditionByPreset(index: number): Condition[] {
    switch (index) {
      case 0: return [{ field: ConditionField.TEMPERATURE, operator: Operator.GT, value: 25 }];
      case 1: return [{ field: ConditionField.TEMPERATURE, operator: Operator.GT, value: 28 }];
      case 2: return [{ field: ConditionField.TEMPERATURE, operator: Operator.GT, value: 30 }];
      case 3: return [{ field: ConditionField.TEMPERATURE, operator: Operator.LT, value: 18 }];
      case 4: return [{ field: ConditionField.HUMIDITY, operator: Operator.LT, value: 30 }];
      case 5: return [{ field: ConditionField.ILLUMINANCE, operator: Operator.LT, value: 50 }];
      case 6: return [{ field: ConditionField.OCCUPANCY, operator: Operator.EQ, value: 1 }];
      case 7: return [{ field: ConditionField.OCCUPANCY, operator: Operator.EQ, value: 0 }];
      default: return [{ field: ConditionField.TEMPERATURE, operator: Operator.GT, value: 25 }];
    }
  }

  private buildActionByPreset(index: number): Action[] {
    switch (index) {
      case 0: return [{ deviceId: 'light_main', deviceType: DeviceType.LIGHT, on: true }];
      case 1: return [{ deviceId: 'light_main', deviceType: DeviceType.LIGHT, on: false }];
      case 2: return [{ deviceId: 'aircon', deviceType: DeviceType.AIRCON, on: true, setValue: 24 }];
      case 3: return [{ deviceId: 'aircon', deviceType: DeviceType.AIRCON, on: false }];
      case 4: return [{ deviceId: 'curtain', deviceType: DeviceType.CURTAIN, on: false, setValue: 100 }];
      case 5: return [{ deviceId: 'humidifier', deviceType: DeviceType.HUMIDIFIER, on: true }];
      default: return [{ deviceId: 'light_main', deviceType: DeviceType.LIGHT, on: true }];
    }
  }
}
