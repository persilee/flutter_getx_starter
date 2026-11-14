// 集中管理翻译键及支持的语言，界面通过统一入口读取文案。

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'translations/index.dart';

/// GetX 三语翻译资源。英语是缺失配置和未知 key 的回退语言。
class AppTranslations extends Translations {
  static const fallbackLocale = Locale('en', 'US');
  static const supportedLocales = [
    fallbackLocale,
    Locale('zh', 'CN'),
    Locale('zh', 'TW'),
  ];

  @override
  Map<String, Map<String, String>> get keys => const {
    'en_US': enUsTranslations,
    'zh_CN': zhCnTranslations,
    'zh_TW': zhTwTranslations,
  };
}

/// 在未装配 GetMaterialApp 的独立组件测试中保留传入的默认文案。
String trOr(String key, String fallback) =>
    Get.locale == null ? fallback : key.tr;
