import { Component } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  build() {
    Column() {
      Text('Test Runner')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 100 })
    }
    .width('100%')
    .height('100%')
  }
}
