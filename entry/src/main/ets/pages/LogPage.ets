/**
 * 执行日志页
 * 展示触发条件、设备变化、执行顺序与冲突信息
 */
import { LogEntry } from '../model/Log';
import { appState } from '../store/AppState';

@Component
export struct LogPage {
  build() {
    Column() {
      Row() {
        Text('执行日志')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
        Blank()
        Button('清空')
          .height(32)
          .fontSize(14)
          .backgroundColor('#f0f0f0')
          .fontColor('#333333')
          .borderRadius(8)
          .onClick(() => {
            appState.clearLogs();
          })
      }
      .width('100%')
      .margin({ top: 16, bottom: 8 })

      if (appState.logs.length === 0) {
        Column() {
          Text('暂无执行记录')
            .fontSize(15)
            .fontColor('#999999')
            .margin({ top: 80 })
          Text('调整环境或载入场景后，触发的联动会记录在这里')
            .fontSize(13)
            .fontColor('#cccccc')
            .margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
      } else {
        List({ space: 12 }) {
          ForEach(appState.logs, (entry: LogEntry) => {
            ListItem() {
              this.LogCard(entry)
            }
          }, (entry: LogEntry) => entry.id)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, bottom: 16 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  LogCard(entry: LogEntry) {
    Column() {
      Row() {
        Text(`#${entry.order} ${entry.ruleName}`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
        Text(this.formatTime(entry.timestamp))
          .fontSize(12)
          .fontColor('#999999')
      }
      .width('100%')

      Text(`触发：${entry.triggerCondition}`)
        .fontSize(13)
        .fontColor('#1677ff')
        .width('100%')
        .margin({ top: 6 })

      ForEach(entry.deviceChanges, (change: string) => {
        Text(`设备变化：${change}`)
          .fontSize(13)
          .fontColor('#333333')
          .width('100%')
          .margin({ top: 3 })
      }, (change: string, idx: number) => `${entry.id}_${idx}`)

      if (entry.conflictNote !== '') {
        Text(entry.conflictNote)
          .fontSize(12)
          .fontColor('#ff8800')
          .backgroundColor('#fff7e6')
          .borderRadius(4)
          .padding(6)
          .width('100%')
          .margin({ top: 6 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 8, color: '#14000000', offsetX: 0, offsetY: 2 })
  }

  private formatTime(ts: number): string {
    const d = new Date(ts);
    const hh = d.getHours().toString().padStart(2, '0');
    const mm = d.getMinutes().toString().padStart(2, '0');
    const ss = d.getSeconds().toString().padStart(2, '0');
    return `${hh}:${mm}:${ss}`;
  }
}
