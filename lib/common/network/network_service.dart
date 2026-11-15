// 封装请求链中的独立职责，由网络客户端统一装配。

/// 文件作用：
/// - [ApiClient]：包一层 Dio，只暴露业务需要的 get / post / patch / delete
/// - [NetworkService]：按 [ApiSource] 懒加载并缓存各来源的 [ApiClient]
library;

import 'package:dio/dio.dart';
// 隐藏 GetX 同名 Response，让下面的 Response 明确指向 Dio 类型。
import 'package:get/get.dart' hide Response;

import '../services/index.dart';

import 'network_config.dart';
// 条件导入在编译期选择实现；Web 不导入 dart:io，原生平台才使用 IO 版本。
import 'platform_adapter.dart' if (dart.library.io) 'platform_adapter_io.dart';

/// 请求客户端，屏蔽 Dio 细节，方便测试替换。
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      // 有自定义请求头时才创建本次 Options，不直接修改全局 Dio.options。
      options: headers == null ? null : Options(headers: headers),
    );
  }

  Future<Response<dynamic>> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.patch(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.delete(path, data: data, queryParameters: queryParameters);
  }
}

/// 多来源网络入口。
///
/// 业务 API 只依赖取到的 [ApiClient]，不感知 Dio 与拦截器装配。
class NetworkService extends GetxService {
  NetworkService({required this.tokenService, required this.sessionService});

  final TokenService tokenService;

  final SessionService sessionService;

  // 每个来源缓存一个客户端，各自保持配置与拦截器状态。
  final _clients = <ApiSource, ApiClient>{};

  /// 取指定来源的请求客户端（首次调用时创建并缓存）
  ApiClient client(ApiSource source) {
    // 首次访问才创建；??= 只在当前缓存值为空时执行右侧表达式。
    return _clients[source] ??= ApiClient(
      _createDio(NetworkEndpoints.of(source)),
    );
  }

  /// 主业务后端快捷入口
  ApiClient get app => client(ApiSource.app);

  /// 取指定来源的 baseUrl（拼图片代理等直链场景）
  String baseUrlOf(ApiSource source) => NetworkEndpoints.of(source).baseUrl;

  Dio _createDio(NetworkEndpoint endpoint) {
    // 用来源配置构造业务客户端，后续在这个实例上装配平台适配和拦截器。
    final dio = Dio(_baseOptions(endpoint));

    // 当前阶段先装配业务请求链；独立的刷新与重放客户端在第 8 章接入。

    configurePlatformAdapter(dio);

    return dio;
  }

  BaseOptions _baseOptions(NetworkEndpoint endpoint) {
    return BaseOptions(
      baseUrl: endpoint.baseUrl,
      // 连接建立、接收和发送分别使用来源超时参数，便于不同后端单独调整。
      connectTimeout: endpoint.connectTimeout,
      receiveTimeout: endpoint.receiveTimeout,
      sendTimeout: endpoint.sendTimeout,
      // 业务接口按 JSON 解码；图片下载会单独覆盖为 stream。
      responseType: ResponseType.json,
      contentType: Headers.jsonContentType,
      // 复制公共请求头，避免一次请求的修改直接污染配置中的 Map。
      headers: {...endpoint.headers},
    );
  }
}
