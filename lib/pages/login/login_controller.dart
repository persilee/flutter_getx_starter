// 管理本页面的状态与动作，界面通过 GetX 读取更新。

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/index.dart';

/// 登录页状态：邮箱密码校验、请求中、错误文案。
class LoginController extends GetxController {
  // 表单区域更新标识，与 LoginPage 中 GetBuilder 的 id 保持一致。
  static const idForm = 'form';

  /// 从统一配置预填演示账号，用户仍可编辑。
  final email = TextEditingController(text: AppConfig.demoEmail);
  final password = TextEditingController(text: AppConfig.demoPassword);

  // 邮箱与密码错误用于字段校验；formError 用于整体提交错误。
  // null 表示该项没有错误，本节仅校验非空。
  String? emailError;
  String? passwordError;
  String? formError;
  bool loading = false;

  /// 本节无认证请求；true 仅表示校验通过，允许进入 Home 体验页面。
  Future<bool> submit() async {
    // 防止加载期间重复提交；后续接入异步请求时仍复用这道入口判断。
    if (loading) return false;
    // 邮箱先去除首尾空白再判断；邮箱键盘不会自动进行邮箱格式校验。
    emailError = email.text.trim().isEmpty ? TrKeys.emailRequired.tr : null;
    // 密码按原始内容判断，不 trim，以免改变用户输入的密码。
    passwordError = password.text.isEmpty ? TrKeys.passwordRequired.tr : null;
    formError = null;
    // 校验失败先刷新错误文案再返回，不进入提交阶段。
    if (emailError != null || passwordError != null) {
      update([idForm]);
      return false;
    }

    // 通过 update([idForm]) 通知按钮显示加载态；普通 bool 不会自动刷新。
    loading = true;
    update([idForm]);
    try {
      // 当前只搭好提交状态骨架，没有调用 API 或建立会话。
      // 非空校验通过后允许 Page 导航到 Home，不代表认证成功。
      // return false;

      return true;
    } catch (error) {
      // 预留提交异常处理；本节 try 内没有请求，通常不会进入此分支。
      formError = TrKeys.loginFailed.tr;
      return false;
    } finally {
      // finally 在成功、失败或提前 return 后都会执行，确保恢复可交互状态。
      loading = false;
      update([idForm]);
    }
  }

  @override
  // 控制器关闭时清理自身创建的资源。
  void onClose() {
    // Controller 创建的文本资源由 onClose 释放；Page 只负责 Get.delete。
    email.dispose();
    password.dispose();
    super.onClose();
  }
}
