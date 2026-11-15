// 在 API 层处理数据来源及协议，页面不直接拼接底层请求。

import 'package:dio/dio.dart';

import '../models/index.dart';
import '../network/index.dart';
import '../values/index.dart';

/// 文件作用：
/// - 邮箱密码登录；无 BASE_URL 时签发本地假会话
/// - 有后端时解信封 `{ code, message, data }`
class AuthApi {
  AuthApi(this._apiClient);

  final ApiClient _apiClient;

  /// 登录。未配后端时不发网，直接返回假 token。
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    // 没有配置后端时走演示或明确拒绝下载分支，不能把本地演示当作真实服务端认证。
    if (!AppConfig.hasBaseUrl) {
      return _localSession(email);
    }
    // 使用公共客户端请求，网络与异常处理留在底层；API 层处理认证协议。
    final resp = await _apiClient.post(
      AppConfig.authLoginPath,
      data: {'email': email, 'password': password},
    );
    // 先验证响应信封，再解析 data 模型；HTTP 成功不等于业务 code 成功。
    return AuthSession.fromApiJson(_unwrap(resp));
  }

  /// 刷新。未配后端时不发网。
  Future<AuthSession> refresh(String refreshToken) async {
    // 没有配置后端时走演示或明确拒绝下载分支，不能把本地演示当作真实服务端认证。
    if (!AppConfig.hasBaseUrl) {
      return _localSession('local@scaffold.app');
    }
    // 使用公共客户端请求，网络与异常处理留在底层；API 层处理认证协议。
    final resp = await _apiClient.post(
      AppConfig.authRefreshPath,
      data: {'refreshToken': refreshToken},
    );
    // 先验证响应信封，再解析 data 模型；HTTP 成功不等于业务 code 成功。
    return AuthSession.fromApiJson(_unwrap(resp));
  }

  /// 本地假会话，满足 [TokenService.hasToken] 的 userId + accessToken。
  AuthSession _localSession(String email) {
    final normalized = email.trim();
    return AuthSession(
      // 固定演示凭证仅用于本地流程；没有验证真实邮箱或密码。
      accessToken: 'scaffold-access-token',
      refreshToken: 'scaffold-refresh-token',
      user: AuthUser(id: 'local-user', email: normalized),
    );
  }

  /// 解信封；code != 0 抛 [BadRequestException]。
  Map<String, dynamic> _unwrap(Response<dynamic> resp) {
    // 响应数据类型先校验再读字段，避免异常响应直接触发强制类型转换。
    final body = resp.data;
    if (body is! Map<String, dynamic>) {
      throw const UnknownException('响应格式异常');
    }
    // 业务 code 由 API 层检查，Dio 的 HTTP 状态判断不会自动解析此字段。
    if (body['code'] != 0) {
      throw BadRequestException(
        body['message'] as String? ?? '请求失败',
        data: body['data'],
      );
    }
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw const UnknownException('响应缺少 data 字段');
    }
    return data;
  }
}
