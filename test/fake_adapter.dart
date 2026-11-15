// 用受控响应替换真实 HTTP 连接，固定网络测试的执行时序。

import 'dart:typed_data';
import 'dart:convert';

import 'package:dio/dio.dart';

class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.respond);
  final Future<ResponseBody> Function(RequestOptions) respond;
  // 保存每次请求选项，断言可检查请求次数、方法、参数与出站头。
  final calls = <RequestOptions>[];
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    // 先记录请求，再交给注入的响应函数，支持即时返回和延迟返回两种场景。
    calls.add(options);
    // 返回测试提供的响应，不发真实 HTTP；取消等机制需要用例另行模拟。
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

// 把 Map 编码为 JSON 响应体，并设置 JSON Content-Type，让 Dio 正常进行解码。
ResponseBody jsonResponse(Object data, {int status = 200}) =>
    ResponseBody.fromString(
      jsonEncode(data),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
