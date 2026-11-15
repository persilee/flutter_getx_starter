// 按依赖顺序注册公共服务，页面在初始化完成后再读取服务。

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:get/get.dart';

import 'common/index.dart';

class Global {
  static AdaptiveThemeMode? savedThemeMode;
  // 完成当前模块的初始化，准备后续调用所需的依赖或状态。
  static Future<void> init() async {
    savedThemeMode = await AdaptiveTheme.getThemeMode();
    await Get.putAsync(() => StorageService().init());
    await Get.putAsync(() => LocaleService(Get.find()).init());
  }
}
