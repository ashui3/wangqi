/**
 * 主页面
 * Tab 导航：设备 / 环境 / 规则 / 场景 / 日志
 * 通过 Tabs.onChange 维护 tabIndex，并作为刷新信号传给各页面，
 * 确保切回页面时强制重新渲染，读到最新状态。
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
  /** 全局刷新信号：任何联动事件或 tab 切换都递增，驱动子页面刷新 */
  @State refreshSignal: number = 0;
  private unsub: (() => void) | null = null;

  aboutToAppear(): void {
    this.unsub = onEvent((data: EventData) => {
      // 任何联动事件都递增刷新信号，驱动当前可见页面重绘
      this.refreshSignal++;
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
          DevicePage({ refreshSignal: this.refreshSignal })
        }
        .tabBar('设备')

        TabContent() {
          EnvPage()
        }
        .tabBar('环境')

        TabContent() {
          RulePage({ refreshSignal: this.refreshSignal })
        }
        .tabBar('规则')

        TabContent() {
          ScenePage()
        }
        .tabBar('场景')

        TabContent() {
          LogPage({ refreshSignal: this.refreshSignal })
        }
        .tabBar('日志')
      }
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        this.currentTab = index;
        // 切换 tab 时也递增刷新信号，确保切回的页面拿到最新状态
        this.refreshSignal++;
      })
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F4F7')
  }
}
