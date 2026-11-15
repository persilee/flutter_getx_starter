// 封装请求链中的独立职责，由网络客户端统一装配。

import 'package:dio/dio.dart';

/// Web 保留 Dio 默认的浏览器适配器，避免引入原生 FFI 依赖。
void configurePlatformAdapter(Dio dio) {}
