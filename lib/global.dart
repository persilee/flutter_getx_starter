// 按依赖顺序注册公共服务，页面在初始化完成后再读取服务。

import 'package:get/get.dart';

import 'common/index.dart';

import 'package:adaptive_theme/adaptive_theme.dart';

class Global {
  static AdaptiveThemeMode? savedThemeMode;
  // 完成当前模块的初始化，准备后续调用所需的依赖或状态。
  static Future<void> init() async {
    // 先恢复主题，随后根组件才能选择正确的初始模式。
    savedThemeMode = await AdaptiveTheme.getThemeMode();
    // 存储必须先完成异步初始化；后面的语言服务和引导服务依赖它。
    await Get.putAsync(() => StorageService().init());
    // 恢复语言并注册服务，await 保证下一个初始化步骤不会抢先执行。
    await Get.putAsync(() => LocaleService(Get.find()).init());
    // 引导服务没有额外异步初始化，直接复用已注册的 StorageService。
    Get.put(AppLaunchService(Get.find()));
  }
}
