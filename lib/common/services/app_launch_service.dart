// 维护跨页面共享能力，由初始化入口统一注册。

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'storage_service.dart';

/// 文件作用：
/// - 记录是否已看过欢迎页
/// - 本节供 Splash 判断是否进入 Welcome；后续认证守卫可复用此标记
/// - 与登录态无关，登出不清此标记
///
/// 欢迎页一次性标记。
class AppLaunchService extends GetxService {
  // 构造时接收已经初始化的存储服务；依赖方向是 Service → Storage。
  AppLaunchService(StorageService storage) : _prefs = storage.prefs;

  // 固定存储键，重启后仍能读取同一项；它与登录凭证是不同的状态。
  static const _hasSeenWelcomeKey = 'app.has_seen_welcome';

  final SharedPreferences _prefs;

  // 首次安装没有记录时按 false 处理，因此会展示引导。
  bool get hasSeenWelcome => _prefs.getBool(_hasSeenWelcomeKey) ?? false;

  /// 欢迎页走完后落盘，后续启动不再进欢迎页。
  Future<void> markWelcomeSeen() async {
    // 等待写入结果再允许页面跳转；不能点击开始后立刻假定保存成功。
    final saved = await _prefs.setBool(_hasSeenWelcomeKey, true);
    // 写入返回 false 也属于失败，通过抛错交给 Controller 展示并允许重试。
    if (!saved) throw StateError('Unable to save welcome preference');
  }

  /// 仅调试 / 重置流程用；生产路径不调用。
  Future<void> reset() async {
    // 只清除引导标记，方便重新体验首次启动，不代表退出登录。
    await _prefs.remove(_hasSeenWelcomeKey);
  }
}
