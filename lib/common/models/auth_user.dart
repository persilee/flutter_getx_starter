// 集中定义数据结构，页面与服务使用明确的模型传递数据。

import 'package:freezed_annotation/freezed_annotation.dart';

// part 将生成代码并入当前库；文件名必须与 build_runner 的生成目标一致。
part 'auth_user.freezed.dart';

/// 登录 / 刷新接口 `data.user`。
// 标记为 Freezed 模型：生成不可变字段、值比较和 copyWith 等能力；生成文件不手工维护。
@freezed
abstract class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String id,
    required String email,
    String? avatar,
  }) = _AuthUser;

  /// 手写解析，避免 freezed 把 `fromJson` 识别成必须生成 `.g.dart`。
  // 这里手工解析 API 数据，不是自动生成的 fromJson；字段协议变化时同步调整。
  factory AuthUser.fromApiJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as String,
    email: json['email'] as String,
    avatar: json['avatar'] as String?,
  );
}
