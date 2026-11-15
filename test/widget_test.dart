// 用受控数据验证当前阶段应用挂载。

import 'package:flutter/material.dart';
import 'package:flutter_getx_starter/app.dart';
import 'package:flutter_getx_starter/common/index.dart';
import 'package:flutter_getx_starter/global.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'support.dart';

void main() {
  // 每个测试前恢复受控环境，避免依赖真实设备上的存储记录。
  setUp(prepare);
  // 测试后清理 GetX 注册与状态，减少测试之间的相互影响。
  tearDown(() => Get.reset());
  testWidgets('当前阶段应用可以挂载', (tester) async {
    // 让真实异步初始化在测试环境中完成，再挂载依赖服务的 App。
    await tester.runAsync(Global.init);
    // 挂载根组件，检查主题、翻译与路由装配是否能一起运行。
    await tester.pumpWidget(const App());
    await tester.pump(const Duration(milliseconds: 500));
    // 推进帧直到动画稳定；这是挂载检查，并未覆盖所有按钮导航。
    await tester.pumpAndSettle();
    expect(find.byType(Scaffold), findsWidgets);
    // 确认构建期间没有 Flutter 异常；不能据此推断后端认证已通过。
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    // 先卸载应用，再释放静态路由实例；本测试结束后不再复用它。
    AppRouter.router.dispose();
  });
}
