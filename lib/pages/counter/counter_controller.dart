// 管理本页面的状态与动作，界面通过 GetX 读取更新。

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class CounterController extends GetxController {
  // 更新点id 计数器
  static const idCounter = 'counter';

  // 成员变量
  int count = 0;

  // 加法计算
  void increment() {
    count++;
    update([idCounter]);
  }

  @override
  // 控制器关闭时清理自身创建的资源。
  void onClose() {
    debugPrint('CounterController 已释放');
    super.onClose();
  }
}
