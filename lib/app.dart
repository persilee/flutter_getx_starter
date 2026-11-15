// 装配根组件，将当前已经完成的主题、翻译与导航接入应用。

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'common/index.dart';
import 'pages/index.dart';

class App extends StatelessWidget {
  const App({super.key});
  @override
  // 根据当前参数与状态构建界面，交互通过回调交给状态拥有者。
  Widget build(BuildContext context) => GetMaterialApp(
    title: AppConfig.appName,
    debugShowCheckedModeBanner: false,
    // 翻译
    translations: AppTranslations(),
    // 当前语言
    // 如果 LocaleService 已注册，则使用 LocaleService 的 locale，否则使用回退语言
    locale: Get.isRegistered<LocaleService>()
        ? Get.find<LocaleService>().locale
        : AppTranslations.fallbackLocale,
    // 回退语言
    fallbackLocale: AppTranslations.fallbackLocale,
    // 支持的语言
    supportedLocales: AppTranslations.supportedLocales,
    // 本地化
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    // 首页
    home: const HomePage(),
  );
}
