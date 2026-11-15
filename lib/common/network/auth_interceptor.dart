// 封装请求链中的独立职责，由网络客户端统一装配。

import 'dart:async';

import 'package:dio/dio.dart';

import '../models/index.dart';
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

  static List<String> get _whitelist => AppConfig.authWhitelist;
  // extra 中记录发送时的令牌，仅供本地判断是否已有更新凭证，不是发送给后端的请求体。
  static const _requestTokenKey = 'auth.request_token';
  // 记录请求所属会话；旧账号请求的迟到错误不能改变当前账号。
  static const _requestSessionKey = 'auth.request_session';
  // 重放标记限制同一请求最多自动重试一次，避免无限刷新与重放。
  static const _retriedKey = 'auth.retried';

  // 共享中的刷新任务；同一拦截器内的并发请求等待此 Future。
  // 每个来源有独立拦截器，这个字段不是所有来源共同的全局锁。
  Future<bool>? _refreshFuture;

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

    // 先查看是否已有刷新任务；已有任务时复用，避免继续携带旧凭证出站。
    final activeRefresh = _refreshFuture;
    if (activeRefresh != null) {
      // 401 已触发刷新时，后续请求先等待，避免继续携带旧凭证出站。
      await activeRefresh;
    } else if (tokenStorage.isExpired) {
      await _sharedRefresh();
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

  @override
  // 按异常类型处理失败，再将结果交给调用方。
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    // 读取这次原请求的会话快照，决定迟到的 401 是否仍属于当前登录。
    final requestSession = options.extra[_requestSessionKey];
    // 只有当前会话的首次非白名单 401 才考虑刷新；其余错误继续交给后续处理。
    if (err.response?.statusCode != 401 ||
        _isWhitelisted(options.path) ||
        options.extra[_retriedKey] == true ||
        requestSession is! SessionSnapshot ||
        !sessionService.isCurrent(requestSession)) {
      handler.next(err);
      return;
    }

    final requestToken = options.extra[_requestTokenKey] as String?;
    final currentToken = tokenStorage.accessToken;
    // 若等待过程中别的请求已经更新 token，直接用新值重放，省去重复刷新。
    final canUseNewToken =
        requestToken != null &&
        currentToken != null &&
        currentToken.isNotEmpty &&
        requestToken != currentToken;
    // || 会短路：已有新令牌时不调用刷新，否则等待共享刷新任务。
    final ready = canUseNewToken || await _sharedRefresh();
    // 刷新未准备好，或请求体无法安全重放时，保留原失败结果。
    if (!ready || !_isReplayable(options.data)) {
      handler.next(err);
      return;
    }

    final retryToken = tokenStorage.accessToken;
    if (retryToken == null || retryToken.isEmpty) {
      handler.next(err);
      return;
    }

    try {
      // 用无拦截器客户端发送原请求的副本，避免再次进入同一鉴权重试链。
      final retried = await refreshDio.fetch<dynamic>(
        options.copyWith(
          // 保留原请求头并覆盖 Bearer；不重新拼装路径、方法或业务参数。
          headers: {...options.headers, 'Authorization': 'Bearer $retryToken'},
          // 复制原元数据并标记已重试；原请求对象不需要原地修改。
          extra: {...options.extra, _retriedKey: true},
        ),
      );
      // 重放成功后用新响应完成原调用，业务层看到的是重放结果。
      handler.resolve(retried);
    } on DioException catch (retryError) {
      // 返回重放的真实错误，避免用首次 401 掩盖后续故障。
      // 重放失败要返回重放时的实际错误，例如 503，不能继续返回最初的 401。
      handler.next(retryError);
    } catch (retryError) {
      handler.next(
        DioException(
          requestOptions: options,
          error: retryError,
          message: retryError.toString(),
        ),
      );
    }
  }

  /// 所有并发调用等待同一个 Future；完成后释放以允许后续显式重试。
  Future<bool> _sharedRefresh() {
    // 已有任务就返回同一个 Future，多个调用者不会分别启动刷新。
    final active = _refreshFuture;
    if (active != null) return active;
    // 仅首个调用创建刷新任务并保存，其余调用复用该引用。
    final created = _refreshTokens();
    _refreshFuture = created;
    return created.whenComplete(() {
      // 仅清理自己创建的任务引用，避免已完成的旧任务误清除后来启动的新任务。
      if (identical(_refreshFuture, created)) _refreshFuture = null;
    });
  }

  // 请求新凭证，提交前确认原会话仍有效。
  Future<bool> _refreshTokens() async {
    // 未配后端时不发 refresh，保留本地假登录会话。
    if (!AppConfig.hasBaseUrl) return false;

    // 记录任务发起时的会话，异步完成后再判断结果是否仍可提交。
    // 刷新结果只允许回写这份快照所属的会话，不能覆盖等待期间建立的新登录。
    final captured = sessionService.snapshot;
    final refreshToken = tokenStorage.refreshToken;
    if (!sessionService.isCurrent(captured) ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      return false;
    }

    try {
      // 刷新用独立客户端；这里直接处理响应 data，不经过 AuthApi._unwrap 的业务 code 检查。
      final resp = await refreshDio.post<Map<String, dynamic>>(
        AppConfig.authRefreshPath,
        data: {'refreshToken': refreshToken},
      );
      // 自动刷新只读取当前约定的 data 信封，类型不符合时返回失败并保留会话。
      final data = resp.data?['data'];
      if (data is! Map) return false;
      final accessToken = data['accessToken'];
      final nextRefreshToken = data['refreshToken'];
      // 两种新令牌必须是非空字符串，校验通过后才进入会话更新。
      if (accessToken is! String ||
          accessToken.isEmpty ||
          nextRefreshToken is! String ||
          nextRefreshToken.isEmpty) {
        return false;
      }
      // 会话服务在写入前后校验 captured，退出或换号后的迟到刷新不能恢复旧账号。
      return await sessionService.updateCredentials(
        captured,
        accessToken: accessToken,
        refreshToken: nextRefreshToken,
      );
    } on DioException catch (error) {
      // 只有服务端明确拒绝刷新凭证时退出；断网、超时和 5xx 保留会话。
      final status = error.response?.statusCode;
      // 只有后端明确拒绝刷新凭证才失效会话；断网、超时与 5xx 不直接退出。
      if (status == 401 || status == 403) {
        // 即使收到拒绝响应，也只清理仍匹配这次刷新快照的会话。
        await sessionService.invalidate(onlyIfCurrent: captured);
      }
      return false;
    } catch (_) {
      // 响应格式和本地处理异常不等于凭证已失效。
      return false;
    }
  }

  /// FormData 和流可能已被消费，不进行无法保证一致性的自动重放。
  // FormData 或 Stream 可能已被消费，自动再次发送无法保证请求内容一致。
  bool _isReplayable(Object? data) => data is! FormData && data is! Stream;

  // 判断请求是否属于无需附加凭证的认证路径。
  bool _isWhitelisted(String path) =>
      // 当前白名单按路径后缀匹配；新增认证路径要同步维护 AppConfig 中的列表。
      _whitelist.any((candidate) => path.endsWith(candidate));
}
