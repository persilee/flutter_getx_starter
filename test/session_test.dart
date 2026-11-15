// 用受控数据验证会话版本隔离。

import 'dart:async';

import 'package:flutter_getx_starter/common/index.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  // 初始化测试绑定，后续使用 Flutter 插件或模拟平台通道前先准备运行环境。
  TestWidgetsFlutterBinding.ensureInitialized();
  // 每个用例前重置受控存储和环境，不依赖开发设备上的历史登录记录。
  setUp(prepare);
  test('刷新保留版本，退出重登与换号使旧结果失效', () async {
    final storage = await StorageService().init();
    final sessions = SessionService(TokenService(storage));
    await sessions.establish(userId: 'u', accessToken: 'a', refreshToken: 'r');
    // 记录任务发起时的会话，异步完成后再判断结果是否仍可提交。
    // 捕获任务启动时的账号和版本；await 之后不能直接假设会话仍相同。
    final captured = sessions.snapshot;
    await sessions.updateCredentials(
      captured,
      accessToken: 'b',
      refreshToken: 's',
    );
    expect(sessions.isCurrent(captured), isTrue);
    // 使用可控 Future 模拟迟到结果，测试无需等待真实网络超时。
    final pending = Completer<String>();
    String? submitted;
    final task = pending.future.then((result) {
      if (sessions.isCurrent(captured)) submitted = result;
    });
    await sessions.invalidate();
    await sessions.establish(userId: 'u', accessToken: 'c', refreshToken: 'r');
    pending.complete('old');
    await task;
    expect(submitted, isNull);
    expect(sessions.isCurrent(captured), isFalse);
    final sameUser = sessions.snapshot;
    await sessions.establish(
      userId: 'other',
      accessToken: 'd',
      refreshToken: 'r',
    );
    expect(sessions.isCurrent(sameUser), isFalse);
  });
}
