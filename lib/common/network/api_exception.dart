// 封装请求链中的独立职责，由网络客户端统一装配。

/// 文件作用：
/// - API 异常类型：按 HTTP 状态码拆 BadRequest / Unauthorized / …
/// - 拦截器把 DioException 转成这些类型
/// - UI 用 [message]，业务用 [statusCode] / [data] 分支
/// - [userFacingErrorMessage] 把任意错误对象转成可直接展示的文案
library;

import 'package:dio/dio.dart';

/// API 层统一异常基类。
///
/// 职责：
/// - 把 Dio 的低层错误转换成业务侧更容易理解的异常。
/// - 保留状态码与响应体，方便 UI 展示、日志上报或按错误码分支。
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => message;
}

/// 400：请求参数、格式或业务校验不通过。
class BadRequestException extends ApiException {
  const BadRequestException(super.message, {super.data})
    : super(statusCode: 400);
}

/// 401：登录态无效；通常由鉴权拦截器先尝试刷新 token。
class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message, {super.data})
    : super(statusCode: 401);
}

/// 403：已登录但没有权限访问目标资源。
class ForbiddenException extends ApiException {
  const ForbiddenException(super.message, {super.data})
    : super(statusCode: 403);
}

/// 404：资源不存在或接口路径不匹配。
class NotFoundException extends ApiException {
  const NotFoundException(super.message, {super.data}) : super(statusCode: 404);
}

/// 409：资源状态冲突，例如重复提交或版本冲突。
class ConflictException extends ApiException {
  const ConflictException(super.message, {super.data}) : super(statusCode: 409);
}

/// 5xx：服务端错误，statusCode 可能是 500、502、503 等。
class ServerException extends ApiException {
  const ServerException(super.message, {super.statusCode, super.data});
}

/// 网络不可达、超时、证书失败等客户端侧连接问题。
class NetworkException extends ApiException {
  const NetworkException(super.message);
}

/// 请求被主动取消，通常不需要按失败 toast 处理。
class CancelException extends ApiException {
  const CancelException(super.message);
}

/// 未能归类的兜底异常，避免错误信息丢失。
class UnknownException extends ApiException {
  const UnknownException(super.message, {super.statusCode, super.data});
}

/// 从后端响应体里提取错误文案（message / msg / error）。
String? apiErrorMessageOf(Object? data) {
  if (data is Map) {
    // 按优先顺序提取非空字符串文案，不把任意对象强制转换成用户提示。
    for (final key in ['message', 'msg', 'error']) {
      final v = data[key];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
  }
  return null;
}

/// UI 展示用：仅业务文案，不含 Dio / ApiException 等包装前缀。
String userFacingErrorMessage(Object? error, {String fallback = '操作失败，请稍后重试'}) {
  if (error == null) return fallback;
  if (error is ApiException) return error.message;
  // 外层可能仍是 DioException，先检查内层业务异常，再尝试响应文案和兜底值。
  if (error is DioException) {
    final inner = error.error;
    if (inner is ApiException) return inner.message;

    final fromBody = apiErrorMessageOf(error.response?.data);
    if (fromBody != null) return fromBody;

    final m = error.message?.trim();
    if (m != null && m.isNotEmpty) return m;
    return fallback;
  }
  return error.toString();
}
