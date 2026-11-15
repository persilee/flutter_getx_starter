// 管理本页面的状态与动作，界面通过 GetX 读取更新。

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/index.dart';

/// 登录页状态：邮箱密码校验、请求中、错误文案。
class LoginController extends GetxController {
  static const idForm = 'form';

  /// 从统一配置预填演示账号，用户仍可编辑。
  final email = TextEditingController(text: AppConfig.demoEmail);
  final password = TextEditingController(text: AppConfig.demoPassword);

  String? emailError;
  String? passwordError;
  String? formError;
  bool loading = false;

  /// 成功返回 true；跳转由 Page / redirect 处理。
  Future<bool> submit() async {
    // 阻止同一次加载过程重复提交；loading 由 Controller 管理而非页面自行维护。
    if (loading) return false;
    // 只校验去掉首尾空格后的邮箱是否为空，不包含邮箱格式或密码强度校验。
    emailError = email.text.trim().isEmpty ? TrKeys.emailRequired.tr : null;
    passwordError = password.text.isEmpty ? TrKeys.passwordRequired.tr : null;
    formError = null;
    if (emailError != null || passwordError != null) {
      update([idForm]);
      return false;
    }

    loading = true;
    update([idForm]);
    final sessions = Get.find<SessionService>();
    // 记录任务发起时的会话，异步完成后再判断结果是否仍可提交。
    // 捕获任务启动时的账号和版本；await 之后不能直接假设会话仍相同。
    final captured = sessions.snapshot;
    try {
      // 认证协议交给 AuthApi；Controller 负责表单状态与后续会话建立。
      final session = await Get.find<AuthApi>().login(
        email: email.text.trim(),
        password: password.text,
      );
      // 登录可能从无会话开始，比较完整快照，不使用要求已登录的 isCurrent。
      if (isClosed || sessions.snapshot != captured) return false;
      await sessions.establish(
        userId: session.user.id,
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );
      return true;
    } catch (error) {
      // 页面已关闭或会话已改变时丢弃迟到结果。
      if (isClosed || sessions.snapshot != captured) return false;
      formError = userFacingErrorMessage(
        error,
        fallback: TrKeys.loginFailed.tr,
      );
      return false;
    } finally {
      loading = false;
      if (!isClosed) update([idForm]);
    }
  }

  @override
  // 控制器关闭时清理自身创建的资源。
  void onClose() {
    // 文本控制器在 LoginController 中创建，由 onClose 释放；Page 负责删除 Controller。
    email.dispose();
    password.dispose();
    super.onClose();
  }
}
