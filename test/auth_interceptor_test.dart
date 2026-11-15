// 用受控数据验证凭证注入、刷新与重放。

import 'dart:convert';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_getx_starter/common/index.dart';

import 'fake_adapter.dart';
import 'support.dart';

String expired() =>
    'header.${base64Url.encode(utf8.encode('{"exp":1}'))}.signature';
// 建立受控依赖，固定请求与会话的测试起点。
Future<(Dio, Dio, SessionService)> fixture(
  FakeAdapter original,
  FakeAdapter refreshed, {
  bool old = false,
}) async {
  final storage = await StorageService().init();
  final tokens = TokenService(storage);
  final sessions = SessionService(tokens);
  await sessions.establish(
    userId: 'u',
    accessToken: old ? expired() : 'old',
    refreshToken: 'r',
  );
  final refresh = Dio(BaseOptions(baseUrl: 'https://controlled.test'))
    ..httpClientAdapter = refreshed;
  final dio = Dio(BaseOptions(baseUrl: 'https://controlled.test'))
    ..httpClientAdapter = original;
  dio.interceptors.add(
    AuthInterceptor(
      tokenStorage: tokens,
      sessionService: sessions,
      refreshDio: refresh,
    ),
  );
  return (dio, refresh, sessions);
}

void main() {
  // 初始化测试绑定，后续使用 Flutter 插件或模拟平台通道前先准备运行环境。
  TestWidgetsFlutterBinding.ensureInitialized();
  // 每个用例前重置受控存储和环境，不依赖开发设备上的历史登录记录。
  setUp(prepare);
  test('Bearer 注入与白名单', () async {
    final original = FakeAdapter((_) async => jsonResponse({'ok': true}));
    final refresh = FakeAdapter((_) async => jsonResponse({}));
    final (dio, _, _) = await fixture(original, refresh);
    await dio.get('/protected');
    await dio.post(AppConfig.authLoginPath);
    expect(original.calls[0].headers['Authorization'], 'Bearer old');
    expect(original.calls[1].headers.containsKey('Authorization'), isFalse);
  });
  test('过期请求先刷新再发出', () async {
    final original = FakeAdapter((_) async => jsonResponse({'ok': true}));
    final refreshed = FakeAdapter(
      (_) async => jsonResponse({
        'data': {'accessToken': 'new', 'refreshToken': 'next'},
      }),
    );
    final (dio, _, sessions) = await fixture(original, refreshed, old: true);
    // 记录任务发起时的会话，异步完成后再判断结果是否仍可提交。
    // 捕获任务启动时的账号和版本；await 之后不能直接假设会话仍相同。
    final captured = sessions.snapshot;
    await dio.get('/protected');
    expect(refreshed.calls.length, 1);
    expect(original.calls.single.headers['Authorization'], 'Bearer new');
    expect(sessions.isCurrent(captured), isTrue);
  }, skip: !AppConfig.hasBaseUrl);
  test('并发等待一次共享刷新', () async {
    // gate 人工控制异步结束时机；先让请求挂起，再制造并发或退出场景。
    final gate = Completer<void>();
    // started 标记请求已进入适配器；等待此信号后再退出，避免依赖不稳定的延时。
    final started = Completer<void>();
    final original = FakeAdapter((_) async => jsonResponse({'ok': true}));
    final refreshed = FakeAdapter((_) async {
      if (!started.isCompleted) started.complete();
      // 在此挂起受控响应，测试通过 gate.complete() 决定何时返回数据。
      await gate.future;
      return jsonResponse({
        'data': {'accessToken': 'new', 'refreshToken': 'next'},
      });
    });
    final (dio, _, _) = await fixture(original, refreshed, old: true);
    // 同时发起多次受保护请求，验证它们是否共享一次刷新，而非分别刷新。
    final tasks = List.generate(5, (_) => dio.get('/protected'));
    // 确认异步操作确实已经开始后才继续改变会话或释放响应。
    await started.future;
    // 释放挂起的操作，模拟服务器结果在并发请求或退出之后才返回。
    gate.complete();
    // 等待所有并发请求结束，再统计实际刷新次数与业务请求次数。
    await Future.wait(tasks);
    expect(refreshed.calls.length, 1);
    expect(original.calls.length, 5);
  }, skip: !AppConfig.hasBaseUrl);
}
