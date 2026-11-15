// 应用根组件：接入自适应主题、多语言和首页。

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'common/index.dart';
import 'global.dart';
import 'pages/index.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => AdaptiveTheme(
    // 浅色主题
    light: AppTheme.lightTheme,
    // 深色主题
    dark: AppTheme.darkTheme,
    // 优先用上次保存的主题，没有则跟随系统
    initial: Global.savedThemeMode ?? AdaptiveThemeMode.system,
    builder: (theme, darkTheme) => GetMaterialApp(
      title: AppConfig.appName,
      // 去掉右上角 debug 角标
      debugShowCheckedModeBanner: false,

      // 文案表
      translations: AppTranslations(),
      // 已注册语言服务则用其语言，否则回退英文
      locale: Get.isRegistered<LocaleService>()
          ? Get.find<LocaleService>().locale
          : AppTranslations.fallbackLocale,
      // 找不到翻译时的兜底语言
      fallbackLocale: AppTranslations.fallbackLocale,
      // 声明支持的语言，供系统本地化组件使用
      supportedLocales: AppTranslations.supportedLocales,
      // Material 组件的系统文案（日期、对话框等）
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      // 浅色主题
      theme: theme,
      // 深色主题
      darkTheme: darkTheme,
      // UI 适配
      builder: (context, child) {
        ScreenUtil.init(
          context,
          designSize: Size(AppConfig.ui.designWidth, AppConfig.ui.designHeight),
        );
        return child ?? const SizedBox.shrink();
      },
      // 启动页
      home: const HomePage(),
    ),
  );
}
