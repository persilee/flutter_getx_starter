// 用受控数据验证认证 API 响应处理。

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_getx_starter/common/index.dart';

import 'fake_adapter.dart';

void main() {
  test('受控登录响应信封与业务失败', () async {
    var good = true;
    final dio = Dio(BaseOptions(baseUrl: 'https://controlled.test'));
    dio.httpClientAdapter = FakeAdapter(
      (_) async => jsonResponse(
        good
            ? {
                'code': 0,
                'data': {
                  'accessToken': 'a',
                  'refreshToken': 'r',
                  'user': {'id': 'u', 'email': 'a@b.c'},
                },
              }
            : {'code': 1, 'message': 'rejected'},
      ),
    );
    final api = AuthApi(ApiClient(dio));
    if (AppConfig.hasBaseUrl) {
      expect((await api.login(email: 'a', password: 'p')).user.id, 'u');
      good = false;
      // 为异步异常建立断言，必须 await，确保失败结果在测试结束前被验证。
      await expectLater(
        api.login(email: 'a', password: 'p'),
        throwsA(isA<BadRequestException>()),
      );
      dio.httpClientAdapter = FakeAdapter(
        (_) async => jsonResponse({'code': 0}),
      );
      // 为异步异常建立断言，必须 await，确保失败结果在测试结束前被验证。
      await expectLater(
        api.login(email: 'a', password: 'p'),
        throwsA(isA<UnknownException>()),
      );
    } else {
      expect(
        (await api.login(email: 'a', password: 'p')).user.id,
        'local-user',
      );
    }
  });
}
