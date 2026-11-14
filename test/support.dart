// 集中准备模拟依赖，让各项测试从相同的初始状态开始。

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 重置依赖容器和模拟存储，隔离每次测试的状态。
void prepare() {
  Get.reset();
  SharedPreferences.setMockInitialValues({});
}
