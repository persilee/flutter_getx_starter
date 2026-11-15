// 封装请求链中的独立职责，由网络客户端统一装配。

import 'package:dio/dio.dart';

import 'api_exception.dart';

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
