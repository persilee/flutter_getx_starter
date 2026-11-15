// 组织本页面布局与交互入口，业务动作交给控制器或服务。

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/index.dart';
import 'login_controller.dart';

/// 登录页：邮箱 + 密码。成功后靠 Session revision 进 Home。
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
    Get.put(LoginController());
  }

  @override
  // 页面离开时释放本页面拥有的资源，避免重复进入后残留状态。
  void dispose() {
    // 删除对应依赖并触发其 onClose；页面创建的 PageController 等资源另行释放。
    Get.delete<LoginController>();
    super.dispose();
  }

  @override
  // 根据当前参数与状态构建界面，交互通过回调交给状态拥有者。
  Widget build(BuildContext context) {
    return PageScaffold(
      scrollable: true,
      // GetBuilder 读取已注册的 Controller；若指定 id，update 时也要使用同一 id。
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
              // 原生字段复用统一主题，并保留邮箱键盘与密码遮蔽能力。
              TextField(
                controller: c.email,
                // 选择邮箱键盘仅改善输入体验，不会自动校验邮箱格式。
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: TrKeys.email.tr,
                  // 邮箱错误在字段下展示；Controller 更新表单区域后才反映新结果。
                  errorText: c.emailError,
                ),
              ),
              const SizedBox(height: 16),
              InputWidget(
                // 复用公共密码组件的显隐能力；此示例未绑定 passwordError 的展示区域。
                controller: c.password,
                obscureText: true,
                placeholder: TrKeys.password.tr,
              ),
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
                // 由 Controller 负责提交，路由守卫监听会话变化后决定页面终点。
                onPressed: c.submit,
              ),
            ],
          );
        },
      ),
    );
  }
}
