// 集中管理翻译键及支持的语言，界面通过统一入口读取文案。

/// 应用翻译键，避免页面散落字面量。
abstract final class TrKeys {
  // 引导页及首页设置菜单文案。
  // Home 与组件目录共用标题。
  static const componentStyles = 'componentStyles';
  static const next = 'next';
  static const welcomeThemeTitle = 'welcomeThemeTitle';
  static const welcomeThemeBody = 'welcomeThemeBody';
  static const welcomeReadyTitle = 'welcomeReadyTitle';
  static const welcomeReadyBody = 'welcomeReadyBody';
  static const switchLanguage = 'switchLanguage';
  static const themeLight = 'themeLight';
  static const themeDark = 'themeDark';
  static const themeSystem = 'themeSystem';

  // 通用组件操作与加载文案。
  static const cancel = 'cancel';
  static const delete = 'delete';
  static const processing = 'processing';
  static const retry = 'retry';
  static const initializationFailed = 'initializationFailed';
  static const welcomeTitle = 'welcomeTitle';
  static const welcomeBody = 'welcomeBody';
  static const start = 'start';
  static const loginTitle = 'loginTitle';
  static const email = 'email';
  static const password = 'password';
  static const loginAction = 'loginAction';
  static const loginFailed = 'loginFailed';
  static const emailRequired = 'emailRequired';
  static const passwordRequired = 'passwordRequired';
  static const homeTitle = 'homeTitle';
  static const switchTheme = 'switchTheme';
  static const signOut = 'signOut';
  static const ready = 'ready';
  static const openCounter = 'openCounter';
  static const counterTitle = 'counterTitle';
  static const counterHint = 'counterHint';
  static const counterValue = 'counterValue';
  static const increment = 'increment';
  static const validation = 'validation';
  static const load = 'load';
  static const empty = 'empty';
  static const failure = 'failure';
  static const confirm = 'confirm';
  static const sample = 'sample';
  static const choose = 'choose';
  static const inputName = 'inputName';
  static const passwordVisibility = 'passwordVisibility';
}
