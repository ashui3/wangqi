/**
 * 场景演练页
 * 支持载入多组场景进行模拟演练，观察设备联动
 */
import { Scene } from '../model/Scene';
import { appState } from '../store/AppState';
import { onEvent, EventData } from '../common/EventBus';

@Component
export struct ScenePage {
  @State refreshFlag: number = 0;
  private unsub: (() => void) | null = null;

  aboutToAppear(): void {
    this.unsub = onEvent((data: EventData) => {
      this.refreshFlag++;
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
      Text('场景演练')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 16, bottom: 8 })

      Text('点击场景一键载入环境数据，观察设备联动与日志')
        .fontSize(13)
        .fontColor('#999999')
        .margin({ bottom: 16 })

      List({ space: 12 }) {
        ForEach(appState.scenes, (scene: Scene) => {
          ListItem() {
            this.SceneCard(scene)
          }
        }, (scene: Scene) => scene.id)
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, bottom: 16 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  SceneCard(scene: Scene) {
    Column() {
      Row() {
        Text(scene.name)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
        Button('载入')
          .height(32)
          .fontSize(14)
          .backgroundColor('#1677ff')
          .fontColor('#FFFFFF')
          .borderRadius(8)
          .onClick(() => {
            appState.loadScene(scene.id).then(() => {
              this.refreshFlag++;
            });
          })
      }
      .width('100%')

      Text(scene.description)
        .fontSize(13)
        .fontColor('#666666')
        .width('100%')
        .margin({ top: 6 })

      Text(`环境：温度 ${scene.env.temperature}℃ · 湿度 ${scene.env.humidity}% · 光照 ${scene.env.illuminance}lux · ${scene.env.occupancy ? '有人' : '无人'}`)
        .fontSize(13)
        .fontColor('#333333')
        .width('100%')
        .margin({ top: 6 })

      Text(`当前环境：温度 ${appState.env.temperature}℃ · 湿度 ${appState.env.humidity}% · 光照 ${appState.env.illuminance}lux · ${appState.env.occupancy ? '有人' : '无人'}`)
        .fontSize(12)
        .fontColor('#1677ff')
        .width('100%')
        .margin({ top: 4 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 8, color: '#14000000', offsetX: 0, offsetY: 2 })
  }
}
