/**
 * 备份恢复 Ability
 */
import { BackupExtensionAbility, BundleVersion } from '@kit.CoreFileKit';

export default class EntryBackupAbility extends BackupExtensionAbility {
  async onBackup(): Promise<void> {
  }

  async onRestore(bundleVersion: BundleVersion): Promise<void> {
  }
}
