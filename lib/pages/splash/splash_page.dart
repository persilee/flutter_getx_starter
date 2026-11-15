// 组织本页面布局与交互入口，业务动作交给控制器或服务。

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../common/index.dart';
import 'splash_controller.dart';

/// 启动页：展示应用名，首帧显示后固定停留 0.5 秒，再按 welcome / token 分流。
///
/// Get.put / Get.delete 配对。跳转只用 context.go。
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  // 页面创建时接入本页面拥有的控制器或资源。
  void initState() {
    super.initState();
    Get.put(SplashController());
    // 首帧显示后才启动停留计时，避免初始化耗时占用 Splash 的可见时间。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // 从应用名实际显示的首帧开始计时，离开页面时取消。
      _timer = Timer(const Duration(milliseconds: 500), _goNext);
    });
  }

  @override
  // 页面离开时释放本页面拥有的资源，避免重复进入后残留状态。
  void dispose() {
    // 提前离开页面时取消 Timer；回调中的 mounted 检查继续保护 BuildContext。
    _timer?.cancel();
    // 删除对应依赖并触发其 onClose；页面创建的 PageController 等资源另行释放。
    Get.delete<SplashController>();
    super.dispose();
  }

  /// 未看 welcome → welcome；有 token → home；否则 login。
  void _goNext() {
    if (!mounted) return;
    final hasSeenWelcome = Get.find<AppLaunchService>().hasSeenWelcome;
    final hasToken = Get.find<TokenService>().hasToken;
    if (!hasSeenWelcome) {
      context.go(AppRoutes.welcome);
    } else if (hasToken) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  // 根据当前参数与状态构建界面，交互通过回调交给状态拥有者。
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(AppConfig.appName, style: AppTextStyles.displayOn(context)),
      ),
    );
  }
}
