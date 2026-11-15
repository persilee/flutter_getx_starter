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
    try {
      // 认证协议交给 AuthApi；Controller 负责表单状态与后续会话建立。
      final session = await Get.find<AuthApi>().login(
        email: email.text.trim(),
        password: password.text,
      );
      // 由会话服务统一保存凭证并更新身份信号，页面不逐项写 token。
      await Get.find<SessionService>().establish(
        userId: session.user.id,
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );
      return true;
    } catch (error) {
      formError = userFacingErrorMessage(
        error,
        fallback: TrKeys.loginFailed.tr,
      );
      return false;
    } finally {
      loading = false;
      update([idForm]);
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
