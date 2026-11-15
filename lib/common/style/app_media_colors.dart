// 集中定义可复用配置，调用方从公共入口读取。

import 'package:flutter/material.dart';

/// 图片遮罩和播放器局部暗色独立于亮暗主题，避免主色污染视频内容。
abstract final class AppMediaColors {
  static const background = Color(0xFF17150F);
  static const black = Colors.black;
  static const foreground = Colors.white;
  static const secondary = Colors.white70;
  static const caption = Colors.white60;
  static const border = Colors.white12;
  static const track = Colors.white24;
  static const progress = Colors.redAccent;
  static const scrim = Color(0xCC000000);
  static const headerScrim = Color(0x99000000);
  static const transparent = Color(0x00000000);
  static const watchLater = Color(0xFFEF8A4E);
}

/// 品牌登录例外集中定义，页面和按钮不再内联品牌HEX。
abstract final class AppBrandColors {
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const googleDark = Color(0xFF131314);
  static const googleOnDark = Color(0xFFE3E3E3);
  static const googleOnLight = Color(0xFF1A1A1A);
  static const googleDarkBorder = Color(0xFF8E918F);
  static const googleLightBorder = Color(0xFFDDDDDD);
  static const googleMark = Color(0xFF4285F4);
}
