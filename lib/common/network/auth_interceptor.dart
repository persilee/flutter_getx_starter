// 封装请求链中的独立职责，由网络客户端统一装配。

import 'package:dio/dio.dart';

import '../services/index.dart';
import '../values/index.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.tokenStorage,
    required this.sessionService,
    required this.refreshDio,
  });

  final TokenService tokenStorage;
  final SessionService sessionService;

  /// 无拦截器的 Dio：刷新不会递归，重放失败可保留真实 Dio 错误。
  final Dio refreshDio;

  /// 认证白名单：登录、刷新等无需附加凭证的路径。
  static List<String> get _whitelist => AppConfig.authWhitelist;
  // extra 中记录发送时的令牌，仅供本地判断是否已有更新凭证，不是发送给后端的请求体。
  static const _requestTokenKey = 'auth.request_token';
  // 记录请求所属会话；旧账号请求的迟到错误不能改变当前账号。
  static const _requestSessionKey = 'auth.request_session';

  @override
  // 在请求出站前处理参数或凭证，并交给后续请求链。
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 登录与刷新路径无需先携带业务凭证，提前放行也避免刷新接口触发自身刷新。
    if (_isWhitelisted(options.path)) {
      // 继续执行后续请求链；记录日志或处理头信息后不能遗漏此交接。
      handler.next(options);
      return;
    }

    // 在等待刷新之后读取内存凭证，不能继续使用等待前捕获的旧 token。
    final token = tokenStorage.accessToken;
    if (token != null && token.isNotEmpty) {
      // 在请求发出前写入 Bearer 头，业务 API 无需逐个拼接鉴权信息。
      options.headers['Authorization'] = 'Bearer $token';
      options.extra[_requestTokenKey] = token;
      options.extra[_requestSessionKey] = sessionService.snapshot;
    }
    // 继续执行后续请求链；记录日志或处理头信息后不能遗漏此交接。
    handler.next(options);
  }

  // 判断请求是否属于无需附加凭证的认证路径。
  bool _isWhitelisted(String path) =>
      // 当前白名单按路径后缀匹配；新增认证路径要同步维护 AppConfig 中的列表。
      _whitelist.any((candidate) => path.endsWith(candidate));
}
