// 维护跨页面共享能力，由初始化入口统一注册。

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/index.dart';
import 'token_service.dart';

/// 文件作用：
/// - 集中建立、更新和失效登录会话
/// - 用后端用户 ID 与单调版本隔离旧异步结果
class SessionService extends GetxService {
  SessionService(this._token);

  final TokenService _token;

  /// 身份变化信号，供路由 redirect 监听。
  // 身份建立或失效时递增，通知 GoRouter 重新运行 redirect。
  final revision = ValueNotifier<int>(0);

  /// 凭证变化信号，供图片代理重建鉴权。
  // 仅凭证更新也可发出通知；不直接替代身份版本，不要求重建整个业务流程。
  final credentialRevision = ValueNotifier<int>(0);

  // 递增版本用于区分登录轮次；用户 ID 相同也不能把两次登录当作同一次会话。
  int _version = 0;

  bool get isLogin => _token.hasToken;

  /// 捕获任务所属账号和版本；异步结果必须在提交点重新校验。
  // 返回当前身份与版本的不可变快照，异步任务应在发起时捕获、提交结果前校验。
  SessionSnapshot get snapshot => SessionSnapshot(
    userId: _token.userId,
    version: _version,
    accessToken: _token.accessToken,
  );

  // 同时核对身份、版本与当前登录状态；刷新 accessToken 本身不会改变会话版本。
  bool isCurrent(SessionSnapshot captured) =>
      captured.userId != null &&
      captured.userId == _token.userId &&
      captured.version == _version &&
      _token.hasToken;

  /// 建立或替换登录会话；同账号重新登录也作废旧任务。
  Future<void> establish({
    required String userId,
    required String accessToken,
    required String refreshToken,
  }) async {
    _version++;
    await _token.save(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
    );
    revision.value++;
    credentialRevision.value++;
  }

  /// 同一会话刷新凭证，不触发业务页整页重载。
  Future<bool> updateCredentials(
    SessionSnapshot captured, {
    required String accessToken,
    required String refreshToken,
  }) async {
    // 异步等待前后都可能换号或退出，校验失败就丢弃旧任务的凭证或通知。
    if (!isCurrent(captured)) return false;
    await _token.save(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: captured.userId,
    );
    // 异步等待前后都可能换号或退出，校验失败就丢弃旧任务的凭证或通知。
    if (!isCurrent(captured)) return false;
    credentialRevision.value++;
    return true;
  }

  /// 先递增版本并清内存，再等待凭证落盘清理；图片缓存清理在第 9 章接入。
  Future<void> invalidate({SessionSnapshot? onlyIfCurrent}) async {
    // 仅让发起这次失效操作的会话退出，防止旧请求的 401 清除后来建立的新会话。
    if (onlyIfCurrent != null && !isCurrent(onlyIfCurrent)) return;
    _version++;
    // 调用时内存即被清空；先保留落盘 Future，通知路由后再 await，不等待磁盘才退出页面。
    final clearToken = _token.clear();
    revision.value++;
    credentialRevision.value++;
    await clearToken;
  }

  @override
  // 控制器关闭时清理自身创建的资源。
  void onClose() {
    // 服务销毁时释放自己创建的 ValueNotifier，避免监听资源残留。
    revision.dispose();
    credentialRevision.dispose();
    super.onClose();
  }
}
