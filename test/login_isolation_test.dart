// 用受控数据验证迟到登录结果隔离。

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_starter/common/index.dart';
import 'package:flutter_getx_starter/pages/login/login_controller.dart';

import 'support.dart';

import 'package:dio/dio.dart';

class PendingAuthApi extends AuthApi {
  PendingAuthApi(this.pending) : super(ApiClient(Dio()));
  final Completer<AuthSession> pending;
  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) => pending.future;
}

void main() {
  // 初始化测试绑定，后续使用 Flutter 插件或模拟平台通道前先准备运行环境。
  TestWidgetsFlutterBinding.ensureInitialized();
  // 每个用例前重置受控存储和环境，不依赖开发设备上的历史登录记录。
  setUp(prepare);
  // 用例结束后清理 GetX 注册，避免下一次测试复用旧服务或 Controller。
  tearDown(() => Get.reset());
  for (final action in ['exit', 'replace', 'close']) {
    test('迟到登录结果不覆盖 $action', () async {
      final tokens = TokenService(await StorageService().init());
      final sessions = Get.put(SessionService(tokens));
      // 使用可控 Future 模拟迟到结果，测试无需等待真实网络超时。
      final pending = Completer<AuthSession>();
      Get.put<AuthApi>(PendingAuthApi(pending));
      final c = Get.put(LoginController());
      final task = c.submit();
      if (action == 'exit') {
        await sessions.invalidate();
      }
      if (action == 'replace') {
        await sessions.establish(
          userId: 'new',
          accessToken: 'new',
          refreshToken: 'new',
        );
      }
      if (action == 'close') {
        // 删除对应依赖并触发其 onClose；页面创建的 PageController 等资源另行释放。
        Get.delete<LoginController>();
      }
      pending.complete(
        const AuthSession(
          accessToken: 'late',
          refreshToken: 'late',
          user: AuthUser(id: 'old', email: 'old@example.com'),
        ),
      );
      expect(await task, isFalse);
      expect(tokens.userId, action == 'replace' ? 'new' : null);
      if (!c.isClosed) {
        // 删除对应依赖并触发其 onClose；页面创建的 PageController 等资源另行释放。
        Get.delete<LoginController>();
      }
    });
  }
}
