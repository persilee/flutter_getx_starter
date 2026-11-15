// 维护跨页面共享能力，由初始化入口统一注册。

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../i18n/index.dart';
import 'storage_service.dart';

/// 管理应用语言的持久化和运行时切换；不跟随系统，默认英语。
class LocaleService extends GetxService {
  LocaleService(this._storage);

  static const _storageKey = 'app_locale';
  final StorageService _storage;
  Locale _locale = AppTranslations.fallbackLocale;

  Locale get locale => _locale;

  /// 从本地读取合法语言；旧值或非法值均安全回退至英语。
  Future<LocaleService> init() async {
    final value = _storage.prefs.getString(_storageKey);
    _locale = AppTranslations.supportedLocales.firstWhere(
      (locale) => _localeKey(locale) == value,
      orElse: () => AppTranslations.fallbackLocale,
    );
    return this;
  }

  /// 保存成功后才切换界面，避免持久化失败与当前状态不一致。
  Future<void> change(Locale value) async {
    // 如果语言不支持或与当前语言相同，则不切换
    if (!AppTranslations.supportedLocales.contains(value) || value == _locale) {
      return;
    }
    // 保存语言偏好
    final saved = await _storage.prefs.setString(
      _storageKey,
      _localeKey(value),
    );
    // 如果保存失败，则抛出异常
    if (!saved) throw StateError('Unable to save language preference');
    // 更新当前语言
    _locale = value;
    // 更新界面语言
    await Get.updateLocale(value);
  }

  static String _localeKey(Locale locale) =>
      '${locale.languageCode}_${locale.countryCode}';
}
