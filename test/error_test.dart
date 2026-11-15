// 用受控数据验证异常转换。

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_getx_starter/common/index.dart';

import 'fake_adapter.dart';

void main() {
  test('HTTP 错误映射为外层 Dio 与业务异常', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://controlled.test'));
    dio.httpClientAdapter = FakeAdapter(
      (_) async => jsonResponse({'message': 'controlled'}, status: 503),
    );
    dio.interceptors.add(ErrorInterceptor());
    try {
      await dio.get('/failure');
      // 请求若意外成功，主动让测试失败；只有进入 catch 并验证业务异常才算通过。
      fail('必须失败');
    } on DioException catch (e) {
      // 外层仍是 DioException，内层 error 才是映射后的业务异常。
      expect(e.error, isA<ServerException>());
      expect(userFacingErrorMessage(e), 'controlled');
    }
  });
  test('连接超时映射为网络异常', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://controlled.test'));
    dio.httpClientAdapter = FakeAdapter(
      (options) async => throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionTimeout,
      ),
    );
    dio.interceptors.add(ErrorInterceptor());
    // 为异步异常建立断言，必须 await，确保失败结果在测试结束前被验证。
    await expectLater(
      dio.get('/slow'),
      throwsA(
        isA<DioException>().having(
          (e) => e.error,
          '业务异常',
          isA<NetworkException>(),
        ),
      ),
    );
  });
}
