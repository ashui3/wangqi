/**
 * 主页面
 * Tab 导航：设备 / 环境 / 规则 / 场景 / 日志
 */
import { onEvent, EventData } from '../common/EventBus';
import { DevicePage } from './DevicePage';
import { EnvPage } from './EnvPage';
import { RulePage } from './RulePage';
import { ScenePage } from './ScenePage';
import { LogPage } from './LogPage';

@Entry
@Component
struct Index {
  @State currentTab: number = 0;
  private unsub: (() => void) | null = null;

  aboutToAppear(): void {
    this.unsub = onEvent((data: EventData) => {
      // 事件触发时递增，驱动当前 Tab 页面刷新
      this.currentTab = this.currentTab;
    });
  }

  aboutToDisappear(): void {
    if (this.unsub) {
      this.unsub();
      this.unsub = null;
    }
  }

  build() {
    Column() {
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
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F4F7')
  }
}
