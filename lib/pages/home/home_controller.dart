// 管理本页面的状态与动作，界面通过 GetX 读取更新。

import 'package:get/get.dart';

import '../../common/index.dart';

class HomeController extends GetxController {
  bool busy = false;
  // 通过会话服务执行退出，页面跳转由导航层响应。
  Future<void> signOut() async {
    // 业务入口也阻止重复执行，不能只依赖按钮的加载样式。
    if (busy) return;
    // 进入等待状态；普通字段改变后用 update 通知 GetBuilder。
    busy = true;
    update();
    try {
      // 退出通过会话服务清除本地身份；语言与引导设置不会在此清除。
      await Get.find<SessionService>().invalidate();
    } finally {
      busy = false;
      if (!isClosed) update();
    }
  }
}

