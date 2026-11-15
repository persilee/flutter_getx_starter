// 封装请求链中的独立职责，由网络客户端统一装配。

import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';

/// Apple 平台使用原生网络栈，其他原生平台保留 Dio 默认适配器。
void configurePlatformAdapter(Dio dio) {
  // Apple 平台替换为原生适配器，其他原生平台继续使用 Dio 默认实现。
  if (Platform.isIOS || Platform.isMacOS) {
    dio.httpClientAdapter = NativeAdapter();
  }
}
