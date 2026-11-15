// 封装请求链中的独立职责，由网络客户端统一装配。

export 'auth_interceptor.dart';

import 'package:dio/dio.dart';

import 'api_exception.dart';

import 'dart:convert';

import 'package:logger/logger.dart';

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({Logger? logger})
    : _logger =
          logger ??
          Logger(printer: PrettyPrinter(methodCount: 0, printEmojis: false));

  final Logger _logger;

  // 字段归一化后与此集合比较；当前没有涵盖 password、邮箱等所有业务敏感字段。
  static const _sensitiveKeys = {
    'authorization',
    'cookie',
    'setcookie',
    'idtoken',
    'accesstoken',
    'refreshtoken',
    'signedtransaction',
    'signedrenewalinfo',
    'purchasetoken',
    'receipt',
  };

  Object? _redact(Object? value, {String? key}) {
    // 去掉符号并转小写，使 access_token、accessToken 等写法使用同一匹配规则。
    final normalizedKey = key
        ?.replaceAll(RegExp(r'[^a-zA-Z]'), '')
        .toLowerCase();
    if (normalizedKey != null && _sensitiveKeys.contains(normalizedKey)) {
      return '<redacted>';
    }
    // 对嵌套 Map 递归处理，敏感字段位于子对象中也能按键名遮蔽。
    if (value is Map) {
      return value.map(
        (entryKey, entryValue) =>
            MapEntry(entryKey, _redact(entryValue, key: entryKey.toString())),
      );
    }
    // 列表中的每个元素也递归脱敏，最后转回列表供日志展示。
    if (value is Iterable) return value.map((item) => _redact(item)).toList();
    if (value is String) return _redactText(value);
    return value;
  }

  /// 同时覆盖原始 JSON、表单文本和错误字符串中的敏感字段。
  String _redactText(String value) {
    try {
      // 文本可能本身就是 JSON；解析成功后复用结构化脱敏，而非只做字符串替换。
      final decoded = jsonDecode(value);
      if (decoded is Map || decoded is List) {
        return jsonEncode(_redact(decoded));
      }
    } catch (_) {
      // 普通文本继续使用字段与 Bearer 规则处理。
    }
    // 非 JSON 文本使用字段与 Bearer 正则兜底；这里只遮蔽已列入规则的字段。
    final sensitiveField = RegExp(
      r'("?(?:authorization|cookie|set-cookie|idtoken|accesstoken|refreshtoken|signedtransaction|signedrenewalinfo|purchasetoken|receipt)"?\s*[:=]\s*)("[^"]*"|[^&,\s}\]]+)',
      caseSensitive: false,
    );
    final bearer = RegExp(r'Bearer\s+[^\s,]+', caseSensitive: false);
    return value
        .replaceAllMapped(
          sensitiveField,
          (match) => '${match.group(1)}<redacted>',
        )
        .replaceAll(bearer, 'Bearer <redacted>');
  }

  String _safeUri(RequestOptions options) {
    // URL 查询参数也可能含 token；重建日志用 URI，原始请求参数不变。
    final safeQuery = _redact(options.queryParameters);
    return options.uri
        .replace(
          queryParameters: safeQuery is Map
              ? safeQuery.map((key, value) => MapEntry('$key', '$value'))
              : null,
        )
        .toString();
  }

  @override
  // 在请求出站前处理参数或凭证，并交给后续请求链。
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d(
      '→ ${options.method} ${_safeUri(options)}\n'
      'headers: ${_redact(options.headers)}\n'
      'data: ${_redact(options.data)}',
    );
    // 继续执行后续请求链；记录日志或处理头信息后不能遗漏此交接。
    handler.next(options);
  }

  @override
  // 检查响应内容，并继续传递当前请求的结果。
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d(
      '← ${response.statusCode} ${_safeUri(response.requestOptions)}\n'
      'data: ${_redact(response.data)}',
    );
    // 日志仅观察响应，继续把真实响应交给调用方。
    handler.next(response);
  }

  @override
  // 按异常类型处理失败，再将结果交给调用方。
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      '✗ ${err.requestOptions.method} ${_safeUri(err.requestOptions)}\n'
      'status: ${err.response?.statusCode}\n'
      'data: ${_redact(err.response?.data)}\n'
      'message: ${_redact(err.message)}',
    );
    handler.next(err);
  }
}

class ErrorInterceptor extends Interceptor {
  @override
  // 按异常类型处理失败，再将结果交给调用方。
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 先将 Dio 错误分类为业务异常，再保留原请求和响应包装回 DioException。
    final exception = _map(err);
    // 结束此错误处理分支并向调用方传递失败；业务异常存放在 DioException.error 中。
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
        message: exception.message,
      ),
    );
  }

  ApiException _map(DioException err) {
    // 先区分超时、取消、断网、证书与 HTTP 响应错误，再处理具体状态码。
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('网络连接超时');
      case DioExceptionType.cancel:
        return const CancelException('请求已取消');
      case DioExceptionType.connectionError:
        return const NetworkException('网络连接失败');
      case DioExceptionType.badCertificate:
        return const NetworkException('证书校验失败');
      // 有 HTTP 错误响应时再进入状态码分类，不与本地连接失败混为一类。
      case DioExceptionType.badResponse:
        return _mapStatus(err);
      default:
        if (err.response == null) {
          return const NetworkException('网络不可用，请检查网络连接');
        }
        return UnknownException(err.message ?? '未知错误');
    }
  }

  ApiException _mapStatus(DioException err) {
    final status = err.response?.statusCode;
    final data = err.response?.data;
    // 优先取后端可读文案；没有可用字段时才使用 Dio 文案或兜底文本。
    final message = apiErrorMessageOf(data) ?? err.message ?? '请求失败';

    // 根据 HTTP 状态映射异常类型，响应 data 继续保留供业务判断。
    switch (status) {
      case 400:
        return BadRequestException(message, data: data);
      case 401:
        return UnauthorizedException(message, data: data);
      case 403:
        return ForbiddenException(message, data: data);
      case 404:
        return NotFoundException(message, data: data);
      case 409:
        return ConflictException(message, data: data);
      default:
        if (status != null && status >= 500) {
          return ServerException(message, statusCode: status, data: data);
        }
        return UnknownException(message, statusCode: status, data: data);
    }
  }
}
