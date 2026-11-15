// 组织本页面布局与交互入口，业务动作交给控制器或服务。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../common/index.dart';
import 'login_controller.dart';

/// 登录页：展示邮箱、密码与校验状态；本节尚未接入 Session 或认证跳转。
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  // 页面创建时接入本页面拥有的控制器或资源。
  void initState() {
    super.initState();
    // 页面创建时注册表单状态，GetBuilder 将读取这个实例。
    Get.put(LoginController());
  }

  @override
  // 页面离开时释放本页面拥有的资源，避免重复进入后残留状态。
  void dispose() {
    // 页面退出时触发 Controller.onClose，释放邮箱和密码文本控制器。
    Get.delete<LoginController>();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final passed = await Get.find<LoginController>().submit();
    if (!passed || !mounted) return;
    // 本章只体验页面流程；第 6 章再接入本地演示会话。
    context.go(AppRoutes.home);
  }

  @override
  // 根据当前参数与状态构建界面，交互通过回调交给状态拥有者。
  Widget build(BuildContext context) {
    return PageScaffold(
      // 键盘弹出或屏幕较小时允许滚动，避免提交按钮被内容挤出可视区域。
      scrollable: true,
      // 只有 update([idForm]) 才触发此表单区域的定向重建。
      body: GetBuilder<LoginController>(
        id: LoginController.idForm,
        builder: (c) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Text(
                TrKeys.loginTitle.tr,
                style: AppTextStyles.displayOn(context),
              ),
              const SizedBox(height: 24),
              // 复用公共输入框，保持清空交互与主题样式一致。
              InputWidget(
                controller: c.email,
                // 选择更适合输入邮箱的键盘，不等于验证邮箱是否合法。
                keyboardType: TextInputType.emailAddress,
                placeholder: TrKeys.email.tr,
              ),
              // InputWidget 暂无 errorText 参数，由页面展示字段校验结果。
              if (c.emailError != null) ...[
                const SizedBox(height: 6),
                Text(
                  c.emailError!,
                  style: AppTextStyles.caption.copyWith(
                    color: context.appErrorText,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              InputWidget(
                controller: c.password,
                // 复用组件内置的密码遮蔽与显隐按钮。
                obscureText: true,
                placeholder: TrKeys.password.tr,
              ),
              if (c.passwordError != null) ...[
                const SizedBox(height: 6),
                Text(
                  c.passwordError!,
                  style: AppTextStyles.caption.copyWith(
                    color: context.appErrorText,
                  ),
                ),
              ],
              // 集合 if 与展开运算符 ... 按条件插入间距和整体错误组件。
              if (c.formError != null) ...[
                const SizedBox(height: 12),
                Text(
                  c.formError!,
                  style: AppTextStyles.caption.copyWith(
                    color: context.appErrorText,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              PrimaryButton(
                label: TrKeys.loginAction.tr,
                loading: c.loading,
                onPressed: _onLogin,
              ),
            ],
          );
        },
      ),
    );
  }
}
