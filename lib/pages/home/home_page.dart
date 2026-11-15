// 组织本页面布局与交互入口，业务动作交给控制器或服务。

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/index.dart';
import 'home_controller.dart';

import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  // 页面创建时接入本页面拥有的控制器或资源。
  void initState() {
    super.initState();
    // 在 GetX 容器中注册实例；页面 Controller 的注册应与 dispose 中的 Get.delete 配对。
    Get.put(HomeController());
  }

  @override
  // 页面离开时释放本页面拥有的资源，避免重复进入后残留状态。
  void dispose() {
    // 删除对应依赖并触发其 onClose；页面创建的 PageController 等资源另行释放。
    Get.delete<HomeController>();
    super.dispose();
  }

  @override
  // 根据当前参数与状态构建界面，交互通过回调交给状态拥有者。
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text(AppConfig.appName)),
    body: SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Text(TrKeys.ready.tr, style: AppTextStyles.body),
              FilledButton(
                key: const Key('open-counter'),
                // push 保留当前页面以供返回；流程切换用 go，返回用 pop。
                onPressed: () => context.push(AppRoutes.counter),
                child: Text(TrKeys.openCounter.tr),
              ),
              FilledButton(
                onPressed: () =>
                    Get.find<LocaleService>().change(const Locale('zh', 'CN')),
                child: Text(TrKeys.switchLanguage.tr),
              ),
              FilledButton(
                onPressed: () => showThemeModeSheet(context),
                child: Text(TrKeys.switchTheme.tr),
              ),
              FilledButton(
                // push 保留当前页面以供返回；流程切换用 go，返回用 pop。
                onPressed: () => context.push(AppRoutes.componentStyles),
                child: Text(TrKeys.componentStyles.tr),
              ),
              FilledButton(
                onPressed: () => Get.find<HomeController>().signOut(),
                child: Text(TrKeys.signOut.tr),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

