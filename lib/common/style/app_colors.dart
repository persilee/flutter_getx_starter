// 集中定义可复用配置，调用方从公共入口读取。

import 'package:flutter/material.dart';

import 'app_style.dart';

export 'app_style.dart';

/// 非主题变化的语义状态色；业务页通过主题扩展读取其它颜色。
abstract final class AppColors {
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
}

/// 保留简短的调用接口，但不再在每个getter里维护一套亮暗色值。
extension AppColorsX on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  AppStyle get appStyle =>
      Theme.of(this).extension<AppStyle>() ??
      (isDarkMode ? AppStyle.dark : AppStyle.light);
  Color get appBackground => appStyle.background;
  Color get appForeground => appStyle.foreground;
  Color get appCard => appStyle.glassEnabled ? appStyle.card : appStyle.surface;
  Color get appCardFg => appStyle.foreground;
  Color get appPrimary => appStyle.primary;
  Color get appPrimaryFg => appStyle.onPrimary;
  Color get appMuted => appStyle.muted;
  Color get appMutedFg => appStyle.mutedForeground;
  Color get appDestructive => appStyle.dangerAction;
  Color get appDestructiveFg => appStyle.onDanger;
  Color get appBorder => appStyle.border;
  Color get appSurface => appStyle.surface;
  Color get appErrorText => appStyle.errorText;
  Color get appFocus => appStyle.inputBorder;
}
