// 集中定义数据结构，页面与服务使用明确的模型传递数据。

import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth_user.dart';

// part 将生成代码并入当前库；文件名必须与 build_runner 的生成目标一致。
part 'auth_session.freezed.dart';

/// 登录 / 刷新接口 `data`：一对令牌 + 用户。
// 标记为 Freezed 模型：生成不可变字段、值比较和 copyWith 等能力；生成文件不手工维护。
@freezed
abstract class AuthSession with _$AuthSession {
  const factory AuthSession({
    // 访问令牌用于业务请求鉴权；与刷新令牌分别保存，不可混用。
    required String accessToken,
    required String refreshToken,
    required AuthUser user,
  }) = _AuthSession;

  /// 手写解析，原因同 [AuthUser.fromApiJson]。
  // 先解析凭证和 user，再组装认证会话模型；模型本身不负责保存登录态。
  factory AuthSession.fromApiJson(Map<String, dynamic> json) => AuthSession(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
    user: AuthUser.fromApiJson(json['user'] as Map<String, dynamic>),
  );
}
