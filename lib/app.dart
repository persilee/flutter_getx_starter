// 装配根组件，将当前已经完成的主题、翻译与导航接入应用。

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'common/index.dart';
import 'global.dart';

class App extends StatelessWidget {
  const App({super.key});
  @override
  // 根据当前参数与状态构建界面，交互通过回调交给状态拥有者。
  Widget build(BuildContext context) => AdaptiveTheme(
    // AdaptiveTheme 提供两套主题，切换时将当前主题传给内层应用。
    light: AppTheme.lightTheme,
    dark: AppTheme.darkTheme,
    // 优先恢复持久化的主题模式；没有记录时跟随系统。
    initial: Global.savedThemeMode ?? AdaptiveThemeMode.system,
    // GetX 继续负责翻译和依赖；.router 构造方式把导航交给 go_router。
    builder: (theme, darkTheme) => GetMaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      // 读取初始化后的语言服务；未注册时使用回退语言，避免 Get.find 抛错。
      locale: Get.isRegistered<LocaleService>()
          ? Get.find<LocaleService>().locale
          : AppTranslations.fallbackLocale,
      fallbackLocale: AppTranslations.fallbackLocale,
      supportedLocales: AppTranslations.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: theme,
      darkTheme: darkTheme,
      // 这是应用内容的构建回调；使用这里的约束初始化尺寸适配。
      builder: (context, child) {
        ScreenUtil.init(
          context,
          designSize: Size(AppConfig.ui.designWidth, AppConfig.ui.designHeight),
        );
        // 必须保留路由生成的 child，否则路由虽已匹配，页面也不会显示。
        return child ?? const SizedBox.shrink();
      },
      // 以下四项来自同一个 GoRouter，分别负责页面栈、地址解析、
      // 地址变化通知和返回事件分发，不能混用其他路由实例。
      routerDelegate: AppRouter.router.routerDelegate,
      routeInformationParser: AppRouter.router.routeInformationParser,
      routeInformationProvider: AppRouter.router.routeInformationProvider,
      backButtonDispatcher: AppRouter.router.backButtonDispatcher,
    ),
  );
}
