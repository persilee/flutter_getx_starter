// 集中定义可复用配置，调用方从公共入口读取。

import 'package:flutter/widgets.dart';

/// 文件作用：
/// - 圆角尺寸 token 与 BorderRadius 快捷值
///
/// 圆角 token。
///
/// 职责：
/// - 将常用圆角尺寸集中命名，形成一致的组件形态。
/// - 提供 BorderRadius 快捷 getter，减少页面重复 `BorderRadius.circular(...)`。
abstract final class AppRadius {
  // 语义名不会随其它控件改版一起变化；旧尺寸仅供特殊小元素使用。
  static const double card = 16;
  static const double button = 12;
  static const double input = 12;
  static const double sheet = 28;
  static const double sm = 4;
  static const double md = 6;
  static const double lg = 8;
  static const double xl = 12;
  static const double modal = 28;
  static const double pill = 999;

  static BorderRadius get cardBorderRadius => BorderRadius.circular(card);
  static BorderRadius get modalBorderRadius => BorderRadius.circular(sheet);
  static BorderRadius get chipBorderRadius => BorderRadius.circular(lg);
  static BorderRadius get pillBorderRadius => BorderRadius.circular(pill);
}
