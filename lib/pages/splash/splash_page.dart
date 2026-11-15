// 组织本页面布局与交互入口，业务动作交给控制器或服务。

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../common/index.dart';
import 'splash_controller.dart';

/// 启动页：首帧显示应用名后停留 0.5 秒，固定进入首页；本节尚未实现引导和认证分流。
///
/// Get.put / Get.delete 配对。跳转只用 context.go。
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  // 保存 Timer 引用才能在 dispose 中取消；首帧之前它仍为 null。
  Timer? _timer;

  @override
  // 页面创建时接入本页面拥有的控制器或资源。
  void initState() {
    super.initState();
    // 注册本页 Controller；离开时用相同类型 Get.delete 配对清理。
    Get.put(SplashController());
    // 等待首帧绘制后再开始计时，让用户先看到应用名。
    // 首帧回调本身不能在这里取消，所以回调内仍要检查 mounted。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 异步回调执行时页面可能已被移除，此时不能再操作页面资源。
      if (!mounted) return;
      // 从应用名实际显示的首帧开始计时，离开页面时取消。
      _timer = Timer(const Duration(milliseconds: 500), _goNext);
    });
  }

  @override
  // 页面离开时释放本页面拥有的资源，避免重复进入后残留状态。
  void dispose() {
    // 提前离开 Splash 时取消尚未触发的跳转，避免旧页面再次导航。
    _timer?.cancel();
    Get.delete<SplashController>();
    super.dispose();
  }

  /// 固定进入首页；本节尚未实现引导和认证分流。
  void _goNext() {
    // 再次检查页面是否仍在树中，安全使用下面的 BuildContext。
    if (!mounted) return;
    // go 切换到下一流程的路由配置，不把 Splash 作为 push 的上一页保留。
    // 当前阶段固定进入首页；go 切换流程，返回不会恢复这个 Splash 页面。
    context.go(AppRoutes.home);
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
