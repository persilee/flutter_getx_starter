// 管理本页面的状态与动作，界面通过 GetX 读取更新。

import 'package:get/get.dart';

import '../../common/index.dart';

/// 三页引导状态；仅最后一页允许持久化完成标记。
class WelcomeController extends GetxController {
  // 与页面 GetBuilder 的 id 对应，普通字段赋值后需要主动 update。
  static const idBody = 'body';
  // 当前引导页索引，0、1、2 分别对应三页。
  int pageIndex = 0;
  // 保存期间置为 true，用于阻止重复点击并锁定翻页。
  bool busy = false;
  // null 表示没有错误；失败时保存可展示的文案。
  String? error;

  void onPageChanged(int index) {
    pageIndex = index;
    update([idBody]);
  }

  /// 写入成功才允许 Page 跳转；失败保留引导并允许重试。
  Future<bool> complete() async {
    // 入口防护：已有保存任务或尚未到最后一页时，不允许完成引导。
    if (busy || pageIndex != 2) return false;
    // 先进入加载状态并清除旧错误，再通知界面，之后才开始异步保存。
    busy = true;
    error = null;
    update([idBody]);
    try {
      // 复用跨页服务写入标记；写入成功后返回 true，由 Page 决定终点。
      await Get.find<AppLaunchService>().markWelcomeSeen();
      return true;
    } catch (exception) {
      // 把异常转换成用户可读文案，不在 Page 中重复解析异常。
      error = userFacingErrorMessage(exception);
      return false;
    } finally {
      busy = false;
      // await 期间 Controller 可能已关闭，关闭后不再通知已销毁的界面。
      if (!isClosed) update([idBody]);
    }
  }
}
