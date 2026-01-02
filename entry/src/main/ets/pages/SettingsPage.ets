import { DataService } from '../services/DataService';
import { UserProfile } from '../models/UserProfile';

@Component
export struct SettingsPage {
  @Consume('pathStack') pathStack: NavPathStack;
  @State profile: UserProfile | null = null;
  @State username: string = 'Hero';
  @State weightKg: number = 70;
  @State dailyWaterGoal: number = 2000;
  @State dailyStepGoal: number = 10000;
  @State questDifficulty: 'easy' | 'normal' | 'hard' = 'normal';
  @State notificationsEnabled: boolean = true;
  @State hapticFeedback: boolean = true;

  async aboutToAppear() {
    this.profile = DataService.getInstance().getUserProfile();
    if (this.profile) {
      this.username = this.profile.username;
      this.weightKg = this.profile.settings.weightKg;
      this.dailyWaterGoal = this.profile.settings.dailyWaterGoal;
      this.dailyStepGoal = this.profile.settings.dailyStepGoal;
      this.questDifficulty = this.profile.settings.questDifficulty;
      this.notificationsEnabled = this.profile.settings.notificationsEnabled;
      this.hapticFeedback = this.profile.settings.hapticFeedback;
    }
  }

  build() {
    NavDestination() {
      Column() {
        this.buildHeader()
        Scroll() {
          Column({ space: 16 }) {
            this.buildProfileSection()
            this.buildGoalsSection()
            this.buildPreferencesSection()
            this.buildAboutSection()
            this.buildSaveButton()
          }.padding(16).width('100%')
        }.layoutWeight(1).scrollBar(BarState.Off)
      }.width('100%').height('100%').backgroundColor('#1A1A1A')
    }.hideTitleBar(true)
  }

  @Builder
  buildHeader() {
    Row() {
      Button({ type: ButtonType.Circle }) {
        Text('←').fontSize(20).fontColor('#FFFFFF')
      }.backgroundColor('#2A2A2A').width(40).height(40)
      .onClick(() => { this.pathStack.pop(); })
      Text('Settings').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
        .layoutWeight(1).textAlign(TextAlign.Center)
      Row().width(40).height(40)
    }.width('100%').padding(16).backgroundColor('#1A1A1A')
  }

  @Builder
  buildProfileSection() {
    Column({ space: 12 }) {
      Text('Profile').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
      Column({ space: 12 }) {
        Row() {
          Text('Username').fontSize(14).fontColor('#CCCCCC').layoutWeight(1)
          TextInput({ text: this.username }).width(120).height(40).fontSize(14)
            .backgroundColor('#1A1A1A').onChange((value: string) => { this.username = value; })
        }.width('100%')
        Row() {
          Text('Weight (kg)').fontSize(14).fontColor('#CCCCCC').layoutWeight(1)
          TextInput({ text: this.weightKg.toString() }).width(80).height(40).fontSize(14)
            .type(InputType.Number).backgroundColor('#1A1A1A')
            .onChange((value: string) => { this.weightKg = parseInt(value) || 70; })
        }.width('100%')
      }.padding(12).backgroundColor('#2A2A2A').borderRadius(12)
    }
  }

  @Builder
  buildGoalsSection() {
    Column({ space: 12 }) {
      Text('Daily Goals').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
      Column({ space: 12 }) {
        Row() {
          Text('Water Goal (ml)').fontSize(14).fontColor('#CCCCCC').layoutWeight(1)
          TextInput({ text: this.dailyWaterGoal.toString() }).width(100).height(40).fontSize(14)
            .type(InputType.Number).backgroundColor('#1A1A1A')
            .onChange((value: string) => { this.dailyWaterGoal = parseInt(value) || 2000; })
        }.width('100%')
        Row() {
          Text('Step Goal').fontSize(14).fontColor('#CCCCCC').layoutWeight(1)
          TextInput({ text: this.dailyStepGoal.toString() }).width(100).height(40).fontSize(14)
            .type(InputType.Number).backgroundColor('#1A1A1A')
            .onChange((value: string) => { this.dailyStepGoal = parseInt(value) || 10000; })
        }.width('100%')
        Row() {
          Text('Quest Difficulty').fontSize(14).fontColor('#CCCCCC').layoutWeight(1)
          Row({ space: 8 }) {
            ForEach(['easy', 'normal', 'hard'], (diff: string) => {
              Button(diff.charAt(0).toUpperCase() + diff.slice(1)).fontSize(12).height(36)
                .backgroundColor(this.questDifficulty === diff ? '#4ECDC4' : '#1A1A1A')
                .onClick(() => { this.questDifficulty = diff as ('easy' | 'normal' | 'hard'); })
            }, (diff: string): string => diff)
          }
        }.width('100%')
      }.padding(12).backgroundColor('#2A2A2A').borderRadius(12)
    }
  }

  @Builder
  buildPreferencesSection() {
    Column({ space: 12 }) {
      Text('Preferences').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
      Column({ space: 12 }) {
        Row() {
          Text('Notifications').fontSize(14).fontColor('#CCCCCC').layoutWeight(1)
          Toggle({ type: ToggleType.Switch, isOn: this.notificationsEnabled }).selectedColor('#4ECDC4')
            .onChange((isOn: boolean) => { this.notificationsEnabled = isOn; })
        }.width('100%')
        Row() {
          Text('Haptic Feedback').fontSize(14).fontColor('#CCCCCC').layoutWeight(1)
          Toggle({ type: ToggleType.Switch, isOn: this.hapticFeedback }).selectedColor('#4ECDC4')
            .onChange((isOn: boolean) => { this.hapticFeedback = isOn; })
        }.width('100%')
      }.padding(12).backgroundColor('#2A2A2A').borderRadius(12)
    }
  }

  @Builder
  buildAboutSection() {
    Column({ space: 12 }) {
      Text('About').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
      Column({ space: 8 }) {
        Row() {
          Text('CalorieQuest').fontSize(14).fontColor('#CCCCCC').layoutWeight(1)
          Text('v1.0.0').fontSize(14).fontColor('#999999')
        }.width('100%')
        Text('Turn your fitness journey into an RPG adventure!').fontSize(12).fontColor('#999999').width('100%')
      }.padding(12).backgroundColor('#2A2A2A').borderRadius(12)
    }
  }

  @Builder
  buildSaveButton() {
    Button('Save Settings').width('100%').height(56).fontSize(18).fontWeight(FontWeight.Bold)
      .backgroundColor('#4ECDC4').borderRadius(12).onClick(() => { this.saveSettings(); })
  }

  async saveSettings() {
    if (!this.profile) {
      return;
    }
    await DataService.getInstance().updateUserProfile({
      username: this.username,
      settings: {
        weightKg: this.weightKg,
        dailyWaterGoal: this.dailyWaterGoal,
        dailyStepGoal: this.dailyStepGoal,
        questDifficulty: this.questDifficulty,
        notificationsEnabled: this.notificationsEnabled,
        hapticFeedback: this.hapticFeedback
      }
    });
    this.pathStack.pop();
  }
}
