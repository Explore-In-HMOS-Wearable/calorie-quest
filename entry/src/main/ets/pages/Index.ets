import { DataService } from '../services/DataService';
import { HomePage } from './HomePage';
import { SettingsPage } from './SettingsPage';
import { WorkoutPage } from './WorkoutPage';
import { WaterPage } from './WaterPage';
import { MealPage } from './MealPage';
import { StatsPage } from './StatsPage';
import { QuestsPage } from './QuestsPage';

@Entry
@Component
struct Index {
  @Provide('pathStack') pathStack: NavPathStack = new NavPathStack();

  @Builder
  pageMap(name: string) {
    if (name === 'SettingsPage') {
      SettingsPage()
    } else if (name === 'WorkoutPage') {
      WorkoutPage()
    } else if (name === 'WaterPage') {
      WaterPage()
    } else if (name === 'MealPage') {
      MealPage()
    } else if (name === 'StatsPage') {
      StatsPage()
    } else if (name === 'QuestsPage') {
      QuestsPage()
    }
  }

  build() {
    Navigation(this.pathStack) {
      HomePage()
    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .hideToolBar(true)
    .navDestination(this.pageMap)
    .width('100%')
    .height('100%')
  }
}
