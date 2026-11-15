// 组织本页面布局与交互入口，业务动作交给控制器或服务。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../common/index.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  // 根据当前参数与状态构建界面，交互通过回调交给状态拥有者。
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text(AppConfig.appName)),
    // 避开系统状态栏等区域；内层滚动容器让小屏幕也能访问全部按钮。
    body: SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Text(TrKeys.ready.tr, style: AppTextStyles.body),
              FilledButton(
                // 为测试提供稳定定位标识，不依赖按钮当前显示的翻译。
                key: const Key('open-counter'),
                // push 在当前页面之上打开新页，返回时仍保留首页。
                // 流程切换用 go；返回可用 context.pop()，两者不要与 push 混淆。
                onPressed: () => context.push(AppRoutes.counter),
                child: Text(TrKeys.openCounter.tr),
              ),
              FilledButton(
                onPressed: () =>
                    // 复用语言服务保存选择并刷新翻译，页面不直接操作 SharedPreferences。
                    Get.find<LocaleService>().change(const Locale('zh', 'CN')),
                child: Text(TrKeys.switchLanguage.tr),
              ),
              FilledButton(
                // 复用公共主题选择面板，使主题切换逻辑保持集中。
                onPressed: () => showThemeModeSheet(context),
                child: Text(TrKeys.switchTheme.tr),
              ),
              FilledButton(
                // push 在当前页面之上打开新页，返回时仍保留首页。
                // 流程切换用 go；返回可用 context.pop()，两者不要与 push 混淆。
                onPressed: () => context.push(AppRoutes.componentStyles),
                child: Text(TrKeys.componentStyles.tr),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
