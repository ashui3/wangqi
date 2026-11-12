/**
 * 主页面
 * Tab 导航：设备 / 环境 / 规则 / 场景 / 日志
 * 直接引用全局 appState 单例（@Observed），事件总线驱动刷新
 */
import { onEvent, offEvent, EventData } from '../common/EventBus';
import { DevicePage } from './DevicePage';
import { EnvPage } from './EnvPage';
import { RulePage } from './RulePage';
import { ScenePage } from './ScenePage';
import { LogPage } from './LogPage';

@Entry
@Component
struct Index {
  @State currentTab: number = 0;
  @State refreshFlag: number = 0;

  aboutToAppear(): void {
    onEvent((data: EventData) => {
      // 事件驱动刷新
      this.refreshFlag++;
    });
  }

  aboutToDisappear(): void {
    offEvent();
  }

  build() {
    Column() {
      // refreshFlag 参与渲染：事件触发时该值变化，强制整棵子树重绘
      if (this.refreshFlag >= 0) {
        Tabs({ barPosition: BarPosition.End }) {
          TabContent() {
            DevicePage()
          }
          .tabBar('设备')

          TabContent() {
            EnvPage()
          }
          .tabBar('环境')

          TabContent() {
            RulePage()
          }
          .tabBar('规则')

          TabContent() {
            ScenePage()
          }
          .tabBar('场景')

          TabContent() {
            LogPage()
          }
          .tabBar('日志')
        }
        .barMode(BarMode.Fixed)
        .onChange((index: number) => {
          this.currentTab = index;
        })
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F4F7')
  }
}
