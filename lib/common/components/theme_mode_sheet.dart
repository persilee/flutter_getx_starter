// 组合已完成的公共组件，提供可直接接入页面的交互入口。

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../i18n/index.dart';
import '../style/index.dart';
import '../widgets/index.dart';

/// 文件作用：
/// - 主题模式底部选择（亮 / 暗 / 系统）

/// 主题模式展示文案。
String themeModeLabel(AdaptiveThemeMode mode) {
  return switch (mode) {
    AdaptiveThemeMode.light => TrKeys.themeLight.tr,
    AdaptiveThemeMode.dark => TrKeys.themeDark.tr,
    AdaptiveThemeMode.system => TrKeys.themeSystem.tr,
  };
}

/// 弹出主题切换 sheet，选中后立刻 `setThemeMode` 并关闭。
Future<void> showThemeModeSheet(BuildContext context) {
  final current = AdaptiveTheme.of(context).mode;
  return AppBottomSheet.show<void>(
    context: context,
    isScrollControlled: false,
    builder: (context) => AppBottomSheet(
      title: TrKeys.switchTheme.tr,
      body: SettingsGroup(
        children: [
          for (final mode in AdaptiveThemeMode.values)
            SettingsTile(
              label: themeModeLabel(mode),
              trailing: mode == current
                  ? Icon(Icons.check_rounded, color: context.appPrimary)
                  : null,
              onTap: () {
                AdaptiveTheme.of(context).setThemeMode(mode);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    ),
  );
}
