// 在 API 层处理数据来源及协议，页面不直接拼接底层请求。

import '../models/index.dart';

class AuthApi {
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async => AuthSession(
    // 固定演示凭证仅用于本地流程；没有验证真实邮箱或密码。
    accessToken: 'scaffold-access-token',
    refreshToken: 'scaffold-refresh-token',
    user: AuthUser(id: 'local-user', email: email.trim()),
  );
}
