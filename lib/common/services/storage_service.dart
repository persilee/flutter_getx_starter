// 维护跨页面共享能力，由初始化入口统一注册。

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 文件作用：
/// - 封装 SharedPreferences 单例，供 Token / 缓存 / 启动标记共用
/// - 必须在其它 Service 之前 [Get.putAsync] 完成
/// - init() 必须 return this，否则 putAsync 类型对不上
/// - 不负责加密；调用方自行评估敏感数据风险
///
/// SharedPreferences 的进程内入口。
class StorageService extends GetxService {
  late final SharedPreferences prefs;

  /// 异步拿到 prefs 并返回自身。
  ///
  /// ⚠️ 坑：必须 `return this`。[Get.putAsync] 要求 Future 解析为实例，
  /// 写成 `Future<void>` 会在注册时类型对不上。
  Future<StorageService> init() async {
    prefs = await SharedPreferences.getInstance();
    return this;
  }
}
