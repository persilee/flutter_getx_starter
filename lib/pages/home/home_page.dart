// 组织本页面布局与交互入口，业务动作交给控制器或服务。

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/index.dart';
import '../component_styles/index.dart';
import '../counter/index.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
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
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const CounterPage()),
                ),
                child: Text(TrKeys.openCounter.tr),
              ),
              FilledButton(
                onPressed: () =>
                    Get.find<LocaleService>().change(const Locale('zh', 'CN')),
                child: Text(TrKeys.switchLanguage.tr),
              ),
              FilledButton(
                onPressed: () =>
                    AdaptiveTheme.of(context)
                        .setThemeMode(AdaptiveThemeMode.light),
                child: Text(TrKeys.themeLight.tr),
              ),
              FilledButton(
                onPressed: () =>
                    AdaptiveTheme.of(context)
                        .setThemeMode(AdaptiveThemeMode.dark),
                child: Text(TrKeys.themeDark.tr),
              ),
              FilledButton(
                onPressed: () =>
                    AdaptiveTheme.of(context)
                        .setThemeMode(AdaptiveThemeMode.system),
                child: Text(TrKeys.themeSystem.tr),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ComponentStylesPage(),
                  ),
                ),
                child: Text(TrKeys.componentStyles.tr),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
