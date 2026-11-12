/**
 * 应用入口 Ability
 * 负责初始化存储、恢复状态
 */
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { StoreManager } from '../store/StoreManager';
import { appState } from '../store/AppState';

const TAG = 'DormAutomation';

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    hilog.info(0x0000, TAG, 'EntryAbility onCreate');
    try {
      await StoreManager.getInstance().init(this.context);
      await appState.restore();
      hilog.info(0x0000, TAG, 'state restored');
    } catch (e) {
      hilog.error(0x0000, TAG, `restore failed: ${JSON.stringify(e)}`);
    }
  }

  onDestroy(): void {
    hilog.info(0x0000, TAG, 'EntryAbility onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, TAG, `loadContent failed: ${JSON.stringify(err)}`);
        return;
      }
      hilog.info(0x0000, TAG, 'loadContent success');
    });
  }

  onWindowStageDestroy(): void {
  }

  onForeground(): void {
  }

  onBackground(): void {
  }
}
