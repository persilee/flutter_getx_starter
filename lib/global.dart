// 按依赖顺序注册公共服务，页面在初始化完成后再读取服务。

import 'package:get/get.dart';

import 'common/index.dart';

import 'package:adaptive_theme/adaptive_theme.dart';

class Global {
  static AdaptiveThemeMode? savedThemeMode;
  // 完成当前模块的初始化，准备后续调用所需的依赖或状态。
  static Future<void> init() async {
    savedThemeMode = await AdaptiveTheme.getThemeMode();
    // 先等待存储初始化，依赖 SharedPreferences 的服务才能安全构造。
    await Get.putAsync(() => StorageService().init());
    // 存储就绪后恢复语言；await 保证页面不会抢先读取未初始化的服务。
    await Get.putAsync(() => LocaleService(Get.find()).init());
    // 从存储恢复凭证后再注册会话和网络，后续同步读取依赖这份内存记录。
    Get.put(TokenService(Get.find()));
    // 先恢复语言和凭证后再注册引导标记，避免在未初始化的服务上读取。
    Get.put(AppLaunchService(Get.find()));
    // 先恢复凭证后再注册会话，避免在未初始化的服务上读取。
    Get.put(SessionService(Get.find<TokenService>()));
    // 先恢复凭证和会话后再注册网络，避免在未初始化的服务上读取。
    Get.put(
      NetworkService(tokenService: Get.find(), sessionService: Get.find()),
    );
    // 按需创建 API，实际使用时从已注册的 NetworkService 获取客户端。
    Get.lazyPut(() => AuthApi());
  }
}
