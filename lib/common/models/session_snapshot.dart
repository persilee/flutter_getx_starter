// 集中定义数据结构，页面与服务使用明确的模型传递数据。

import 'package:freezed_annotation/freezed_annotation.dart';

// part 将生成代码并入当前库；文件名必须与 build_runner 的生成目标一致。
part 'session_snapshot.freezed.dart';

/// 异步任务捕获的会话归属；普通 Token 刷新不会改变 [version]。
// 标记为 Freezed 模型：生成不可变字段、值比较和 copyWith 等能力；生成文件不手工维护。
@freezed
abstract class SessionSnapshot with _$SessionSnapshot {
  const factory SessionSnapshot({
    required String? userId,
    // 会话版本标记任务所属的登录轮次；同账号重新登录后旧版本也应失效。
    required int version,
    required String? accessToken,
  }) = _SessionSnapshot;
}
