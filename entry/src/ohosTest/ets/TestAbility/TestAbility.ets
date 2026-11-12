/**
 * ohosTest 测试 Ability 入口
 */
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import testsuite from '../test/List.test';
import { Hypium } from '@ohos/hypium';

const TAG = 'DormAutomationTest';

export default class TestAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, TAG, 'TestAbility onCreate');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('TestAbility/pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, TAG, `loadContent failed: ${JSON.stringify(err)}`);
        return;
      }
      Hypium.hypiumTest(this.context, testsuite);
    });
  }
}
