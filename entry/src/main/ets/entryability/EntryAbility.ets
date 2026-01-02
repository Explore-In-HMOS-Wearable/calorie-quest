import { UIAbility, AbilityConstant, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { DataService } from '../services/DataService';
import { BackgroundTaskService } from '../services/BackgroundTaskService';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    console.info('[CalorieQuest] EntryAbility onCreate');

    // Initialize data service with context
    DataService.getInstance().initialize(this.context);

    // Initialize background tasks with context
    BackgroundTaskService.getInstance().initialize(this.context);
  }

  onDestroy(): void {
    console.info('[CalorieQuest] EntryAbility onDestroy');
    BackgroundTaskService.getInstance().cleanup();
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    console.info('[CalorieQuest] EntryAbility onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        console.error(`[CalorieQuest] Failed to load content. Code: ${err.code}, message: ${err.message}`);
        return;
      }
      console.info('[CalorieQuest] Succeeded in loading content');
    });
  }

  onWindowStageDestroy(): void {
    console.info('[CalorieQuest] EntryAbility onWindowStageDestroy');
  }

  onForeground(): void {
    console.info('[CalorieQuest] EntryAbility onForeground');
    DataService.getInstance().refreshData();
  }

  onBackground(): void {
    console.info('[CalorieQuest] EntryAbility onBackground');
  }
}

