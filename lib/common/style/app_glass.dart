// 集中定义可复用配置，调用方从公共入口读取。

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 玻璃样式参数入口，只提供数据，不执行模糊或绘制。
///
/// 固定规格使用常量；颜色与阴影从调用位置的 AppStyle 读取，跟随当前主题。
/// abstract final 禁止实例化、继承和实现，调用方直接使用静态成员。
abstract final class AppGlass {
  /// 顶部区域使用的较强模糊规格，作为 ImageFilter.blur 的 sigma 值。
  static const double blurHeader = 22;

  /// 普通玻璃表面使用的较轻模糊规格；数值不是透明度或圆角半径。
  static const double blurLight = 10;

  /// 读取当前主题的顶部渐变色；关闭玻璃时由绘制组件跳过渐变。
  static List<Color> headerGradientOf(BuildContext context) =>
      context.appStyle.headerGradient;

  /// 读取当前主题的玻璃边框颜色。
  static Color borderOf(BuildContext context) => context.appStyle.glassBorder;

  /// 卡片填充色；玻璃开启时读取 card，关闭时通过 appCard 回退到 surface。
  static Color cardFillOf(BuildContext context) => context.appCard;

  /// 标签填充色，复用当前主题的 muted 色，不在此方法中判断玻璃开关。
  static Color chipFillOf(BuildContext context) => context.appMuted;

  /// 底部面板填充色，读取当前主题的 surface。
  static Color sheetFillOf(BuildContext context) => context.appSurface;

  /// 图标容器填充色；与卡片共用 appCard 的玻璃开关回退规则。
  static Color iconFillOf(BuildContext context) => context.appCard;

  /// 读取当前主题的卡片柔和阴影，供普通表面复用。
  static List<BoxShadow> softShadowOf(BuildContext context) =>
      context.appStyle.cardShadow;

  /// 读取当前主题的底部面板阴影。
  static List<BoxShadow> sheetShadowOf(BuildContext context) =>
      context.appStyle.sheetShadow;
}
