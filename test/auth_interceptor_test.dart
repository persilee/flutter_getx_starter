// 阅读顺序：先看 fixture 如何搭建环境，再逐个看 test 的准备、请求和断言。
// FakeAdapter 替代真实服务器：回调决定返回内容，calls 记录收到的请求。
// jsonResponse 把 Map 包装成模拟 HTTP 响应；默认状态为 200。
// expect(实际值, 预期值) 用来验证结果，isTrue / isFalse 分别表示真 / 假。

import 'dart:convert';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_getx_starter/common/index.dart';

import 'fake_adapter.dart';
import 'support.dart';

// 构造仅供测试的 JWT：exp=1 表示 1970 年起第 1 秒，必然已经过期。
// 这里只触发本地过期判断，header 和 signature 都是占位，不是真实签名。
String expired() =>
    'header.${base64Url.encode(utf8.encode('{"exp":1}'))}.signature';

// 每个用例创建独立的存储、令牌和会话，避免共享登录状态。
// original：接收首次业务请求；refreshed：接收刷新请求，以及刷新后的重放请求。
// old=true 使用过期 JWT，触发请求前刷新；false 使用字符串 old，等服务器 401 再刷新。
// 返回 Dart 记录 (业务 Dio, 刷新/重放 Dio, 会话服务)，供用例解构使用。
Future<(Dio, Dio, SessionService)> fixture(
  FakeAdapter original,
  FakeAdapter refreshed, {
  bool old = false,
}) async {
  final storage = await StorageService().init();
  final tokens = TokenService(storage);
  final sessions = SessionService(tokens);
  // 先模拟用户 u 已登录，r 是可供刷新使用的测试令牌。
  await sessions.establish(
    userId: 'u',
    accessToken: old ? expired() : 'old',
    refreshToken: 'r',
  );
  // .. 是级联语法：配置刚创建的 Dio。两个客户端都使用替身，不访问网络。
  // refresh 不挂鉴权拦截器，防止刷新请求再次触发刷新。
  final refresh = Dio(BaseOptions(baseUrl: 'https://controlled.test'))
    ..httpClientAdapter = refreshed;
  final dio = Dio(BaseOptions(baseUrl: 'https://controlled.test'))
    ..httpClientAdapter = original;
  // 只给业务 Dio 挂待测拦截器；发送请求时才会执行注入、刷新和重放逻辑。
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

  // 场景 1：普通接口带令牌，登录白名单接口不带令牌。
  test('Bearer 注入与白名单', () async {
    final original = FakeAdapter((_) async => jsonResponse({'ok': true}));
    final refresh = FakeAdapter((_) async => jsonResponse({}));
    // 解构返回值：这里只需要业务 Dio，两个 _ 表示忽略其他结果。
    final (dio, _, _) = await fixture(original, refresh);
    await dio.get('/protected');
    await dio.post(AppConfig.authLoginPath);
    // calls 按接收顺序记录请求：[0] 是受保护接口，[1] 是登录接口。
    expect(original.calls[0].headers['Authorization'], 'Bearer old');
    expect(original.calls[1].headers.containsKey('Authorization'), isFalse);
  });

  // 场景 2：令牌本地已过期，业务请求发出前必须先取得新令牌。
  test('过期请求先刷新再发出', () async {
    final original = FakeAdapter((_) async => jsonResponse({'ok': true}));
    final refreshed = FakeAdapter(
      (_) async => jsonResponse({
        'data': {'accessToken': 'new', 'refreshToken': 'next'},
      }),
    );
    final (dio, _, sessions) = await fixture(original, refreshed, old: true);
    // 捕获账号和会话版本；刷新只更新凭证，不应让这个快照失效。
    final captured = sessions.snapshot;
    await dio.get('/protected');
    // 刷新只能发生一次。
    expect(refreshed.calls.length, 1);
    // single 要求恰好只有一次业务请求；它首次发出就应携带 new。
    expect(original.calls.single.headers['Authorization'], 'Bearer new');
    expect(sessions.isCurrent(captured), isTrue);
  }, skip: !AppConfig.hasBaseUrl);
  // 后续用例的 skip 在未配置 BASE_URL 时跳过刷新分支。
  // 在 VS Code 中选择本节末尾的“8-5 鉴权测试（受控后端）”配置运行这些用例。

  // 场景 3：5 个请求遇到过期令牌，只发一次刷新，全部等待同一个结果。
  test('并发等待一次共享刷新', () async {
    // gate 人工控制异步结束时机；先让请求挂起，再制造并发或退出场景。
    final gate = Completer<void>();
    // started 是“刷新已开始”的信号；gate 是“允许刷新返回”的开关。
    // Completer.future 用于等待，complete() 用于解除等待，不需要猜测延时。
    final started = Completer<void>();
    final original = FakeAdapter((_) async => jsonResponse({'ok': true}));
    final refreshed = FakeAdapter((_) async {
      // 信号只能 complete 一次；即使实现错误地多次刷新，也避免重复完成信号。
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
    // 刷新只能发生一次。
    expect(refreshed.calls.length, 1);
    expect(original.calls.length, 5);
  }, skip: !AppConfig.hasBaseUrl);

  // 场景 4：首次业务请求 401 → 刷新成功 → 重放业务请求 503。
  // 调用方最终应该收到 503，不能被最初的 401 覆盖。
  test('401刷新后重放，重放失败保留实际状态', () async {
    final original = FakeAdapter(
      (_) async => jsonResponse({'message': 'expired'}, status: 401),
    );
    final refreshed = FakeAdapter(
      // 同一个适配器接收两类请求：刷新路径返回新令牌，业务重放返回 503。
      (options) async => options.path == AppConfig.authRefreshPath
          ? jsonResponse({
              'data': {'accessToken': 'new', 'refreshToken': 'next'},
            })
          : jsonResponse({'message': 'actual'}, status: 503),
    );
    final (dio, _, _) = await fixture(original, refreshed);
    // 为异步异常建立断言，必须 await，确保失败结果在测试结束前被验证。
    await expectLater(
      dio.get('/protected'),
      throwsA(
        // isA 检查异常类型；having 继续检查异常内的状态码，第二个参数是失败提示名。
        isA<DioException>().having((e) => e.response?.statusCode, '重放状态', 503),
      ),
    );
    // where 按路径筛选记录：刷新一次，重放也只能一次。
    expect(
      refreshed.calls.where((x) => x.path == AppConfig.authRefreshPath).length,
      1,
    );
    expect(refreshed.calls.where((x) => x.path == '/protected').length, 1);
  }, skip: !AppConfig.hasBaseUrl);

  // 场景 5：循环注册三个独立用例，比较刷新失败状态对应的会话策略。
  // 刷新 401/403 表示凭证被明确拒绝，退出；500 表示服务器故障，保留登录。
  for (final status in [401, 403, 500]) {
    test('刷新失败 $status 的会话策略', () async {
      final original = FakeAdapter((_) async => jsonResponse({'ok': true}));
      final refreshed = FakeAdapter(
        (_) async => jsonResponse({}, status: status),
      );
      final (dio, _, sessions) = await fixture(original, refreshed, old: true);
      // 此处 401/403/500 来自刷新接口，首次业务接口的替身始终返回 200。
      // 请求前刷新失败后仍会继续业务请求，所以这里 await 不期望抛异常。
      await dio.get('/protected');
      // status==500 的计算结果就是预期值：500 为 true，其余两个为 false。
      expect(sessions.isLogin, status == 500);
    }, skip: !AppConfig.hasBaseUrl);
  }

  // 场景 6：刷新开始 → 用户退出 → 刷新才成功返回。
  // 旧请求的快照已失效，迟到的新令牌不能把用户重新登录。
  test('退出后迟到刷新不恢复会话', () async {
    // gate 人工控制异步结束时机；先让请求挂起，再制造并发或退出场景。
    final gate = Completer<void>();
    // started 是“刷新已开始”的信号；gate 是“允许刷新返回”的开关。
    // Completer.future 用于等待，complete() 用于解除等待，不需要猜测延时。
    final started = Completer<void>();
    final original = FakeAdapter((_) async => jsonResponse({}));
    final refreshed = FakeAdapter((_) async {
      started.complete();
      // 在此挂起受控响应，测试通过 gate.complete() 决定何时返回数据。
      await gate.future;
      return jsonResponse({
        'data': {'accessToken': 'new', 'refreshToken': 'next'},
      });
    });
    final (dio, _, sessions) = await fixture(original, refreshed, old: true);
    // 暂不 await：保留尚未完成的请求，才能在刷新过程中执行退出。
    final task = dio.get('/protected');
    // 确认异步操作确实已经开始后才继续改变会话或释放响应。
    await started.future;
    // 退出会清除凭证并递增会话版本，让刷新开始时捕获的旧快照失效。
    await sessions.invalidate();
    // 释放挂起的操作，模拟服务器结果在并发请求或退出之后才返回。
    gate.complete();
    await task;
    expect(sessions.isLogin, isFalse);
  }, skip: !AppConfig.hasBaseUrl);

  // 场景 7：上传表单遇到 401 时，不自动重发可能已被读取的 FormData。
  // 当前实现可能先刷新，再检查请求体是否可重放；这里只验证上传没有重发。
  test('FormData不会自动重放', () async {
    final original = FakeAdapter((_) async => jsonResponse({}, status: 401));
    final refreshed = FakeAdapter(
      (_) async => jsonResponse({
        'data': {'accessToken': 'new', 'refreshToken': 'next'},
      }),
    );
    final (dio, _, _) = await fixture(original, refreshed);
    // 为异步异常建立断言，必须 await，确保失败结果在测试结束前被验证。
    await expectLater(
      dio.post('/upload', data: FormData.fromMap({'name': 'sample'})),
      // 原来的上传 401 继续向调用方抛出，结果不会被当成上传成功。
      throwsA(isA<DioException>()),
    );
    // 首次上传仅发送一次。
    expect(original.calls.length, 1);
    expect(
      refreshed.calls.where((request) => request.path == '/upload'),
      // 刷新/重放客户端从未收到 /upload；并非要求它完全没有刷新请求。
      isEmpty,
    );
  }, skip: !AppConfig.hasBaseUrl);
}
