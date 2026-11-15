// 用受控数据验证路由守卫与会话分流。

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_starter/app.dart';
import 'package:flutter_getx_starter/global.dart';
import 'package:flutter_getx_starter/common/index.dart';
import 'package:flutter_getx_starter/pages/index.dart';

import 'support.dart';

void main() {
  // 每个用例前重置受控存储和环境，不依赖开发设备上的历史登录记录。
  setUp(prepare);
  // 用例结束后清理 GetX 注册，避免下一次测试复用旧服务或 Controller。
  tearDown(() => Get.reset());
  testWidgets('未登录拦截、登录通知与退出分流', (tester) async {
    await tester.runAsync(Global.init);
    await tester.runAsync(() => Get.find<AppLaunchService>().markWelcomeSeen());
    // 挂载根组件，验证初始化后的主题、翻译与路由能一起运行。
    await tester.pumpWidget(const App());
    await tester.pump(const Duration(milliseconds: 500));
    // 推进界面帧直到动画稳定；外部异步任务仍需要 runAsync 或可控 Future 配合。
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    AppRouter.router.go(AppRoutes.home);
    // 推进界面帧直到动画稳定；外部异步任务仍需要 runAsync 或可控 Future 配合。
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    await tester.runAsync(
      () => Get.find<SessionService>().establish(
        userId: 'u',
        accessToken: 'a',
        refreshToken: 'r',
      ),
    );
    // 推进界面帧直到动画稳定；外部异步任务仍需要 runAsync 或可控 Future 配合。
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
    AppRouter.router.go(AppRoutes.login);
    // 推进界面帧直到动画稳定；外部异步任务仍需要 runAsync 或可控 Future 配合。
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
    await tester.runAsync(() => Get.find<SessionService>().invalidate());
    // 推进界面帧直到动画稳定；外部异步任务仍需要 runAsync 或可控 Future 配合。
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    // 卸载 App 后释放静态路由实例；此测试结束后不再复用已 dispose 的实例。
    AppRouter.router.dispose();
  });
}
