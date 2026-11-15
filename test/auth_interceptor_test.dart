// 用受控数据验证凭证注入、刷新与重放。

import 'dart:convert';

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
}
