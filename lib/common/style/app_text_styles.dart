// 集中定义可复用配置，调用方从公共入口读取。

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 规范文字档位：所有样式支持系统文字缩放，不以固定容器高度裁剪。
abstract final class AppTextStyles {
  static const display = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  static const pageTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );
  static const sectionTitle = pageTitle;
  static const cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  static const body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.65,
  );
  static const secondary = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static const meta = secondary;
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static const label = caption;
  static const mono = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    fontFamily: 'monospace',
  );
  static TextStyle displayOn(BuildContext c) =>
      display.copyWith(color: c.appForeground);
  static TextStyle pageTitleOn(BuildContext c) =>
      pageTitle.copyWith(color: c.appForeground);
  static TextStyle sectionTitleOn(BuildContext c) =>
      sectionTitle.copyWith(color: c.appForeground);
  static TextStyle cardTitleOn(BuildContext c) =>
      cardTitle.copyWith(color: c.appForeground);
  static TextStyle bodyOn(BuildContext c) =>
      body.copyWith(color: c.appForeground);
  static TextStyle secondaryOn(BuildContext c) =>
      secondary.copyWith(color: c.appMutedFg);
  static TextStyle metaOn(BuildContext c) => meta.copyWith(color: c.appMutedFg);
  static TextStyle captionOn(BuildContext c) =>
      caption.copyWith(color: c.appMutedFg);
  static TextStyle labelOn(BuildContext c) =>
      label.copyWith(color: c.appMutedFg);

  /// Material槽位与项目命名使用同一份样式，无重复亮暗TextTheme。
  static TextTheme theme(AppStyle s) => TextTheme(
    displaySmall: display.copyWith(color: s.foreground),
    headlineSmall: pageTitle.copyWith(color: s.foreground),
    titleLarge: sectionTitle.copyWith(color: s.foreground),
    titleMedium: cardTitle.copyWith(color: s.foreground),
    bodyLarge: body.copyWith(color: s.foreground),
    bodyMedium: secondary.copyWith(color: s.foreground),
    bodySmall: caption.copyWith(color: s.mutedForeground),
    labelSmall: label.copyWith(color: s.mutedForeground),
  );
}
