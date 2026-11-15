// 用受控数据验证请求方法与参数传递。

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_getx_starter/common/index.dart';

import 'fake_adapter.dart';

void main() {
  test('API 客户端传递方法与查询参数', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://controlled.test'));
    // 替换真实 HTTP 通道，记录请求并返回固定响应；这类测试不访问真实后端。
    final adapter = FakeAdapter((_) async => jsonResponse({'ok': true}));
    // 将可控适配器装入 Dio，请求仍经过客户端逻辑和已装配的拦截器。
    dio.httpClientAdapter = adapter;
    final client = ApiClient(dio);
    await client.get('/items', queryParameters: {'page': 1});
    await client.post('/items', data: {'name': 'demo'});
    await client.patch('/items', data: {});
    await client.delete('/items');
    expect(adapter.calls.map((x) => x.method), [
      'GET',
      'POST',
      'PATCH',
      'DELETE',
    ]);
    expect(adapter.calls.first.queryParameters['page'], 1);
  });
}
