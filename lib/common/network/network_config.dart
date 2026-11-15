// 封装请求链中的独立职责，由网络客户端统一装配。

/// 文件作用：
/// - 定义 API 来源标识 [ApiSource]
/// - 定义单来源网络参数 [NetworkEndpoint]
/// - 集中登记所有来源配置 [NetworkEndpoints]
library;

import '../values/index.dart';

/// API 来源标识。
///
/// 每个来源对应一个独立 baseUrl / Dio 实例。
enum ApiSource {
  /// 主业务后端
  app,
}

/// 单个 API 来源的网络参数：baseUrl + 超时 / 鉴权 / 日志 / 公共头。
class NetworkEndpoint {
  const NetworkEndpoint({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.requiresAuth = true,
    this.enableLogging = true,
    this.headers = const {'Accept': 'application/json'},
  });

  /// 接口根地址
  final String baseUrl;

  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;

  /// 是否挂载鉴权拦截器（附带 Token、401 自动刷新重试）
  final bool requiresAuth;

  /// 是否打印请求日志
  final bool enableLogging;

  /// 该来源公共请求头
  final Map<String, String> headers;
}

/// 全部 API 来源的配置表。
///
/// 地址与日志开关来自 [AppConfig]，可通过 `--dart-define` 覆盖。
abstract final class NetworkEndpoints {
  /// 主业务后端
  // 把主业务来源配置集中在一处，API 类无需自行声明地址或超时。
  static const app = NetworkEndpoint(
    baseUrl: AppConfig.baseUrl,
    enableLogging: AppConfig.enableHttpLog,
  );

  /// 来源 -> 配置映射，新增来源时同步登记
  // 来源与配置一一对应；新增枚举项时也要补充这里的映射。
  static const values = <ApiSource, NetworkEndpoint>{ApiSource.app: app};

  static NetworkEndpoint of(ApiSource source) {
    // 查表获取配置；缺项时明确抛错，避免静默连接到错误后端。
    final endpoint = values[source];
    if (endpoint == null) {
      throw StateError('ApiSource.${source.name} 未在 NetworkEndpoints 中登记');
    }
    return endpoint;
  }
}
