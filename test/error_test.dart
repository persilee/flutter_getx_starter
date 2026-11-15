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
}
