import 'package:flutter/widgets.dart';

/// 文件作用：
/// - 快捷读取刘海 / 手势条安全区
///
/// 适用于自定义全屏布局、底部按钮、沉浸式 AppBar。
extension SafeAreaExt on BuildContext {
  EdgeInsets get safeAreaPadding => MediaQuery.paddingOf(this);
  double get safeTop => safeAreaPadding.top;
  double get safeBottom => safeAreaPadding.bottom;
  double get safeLeft => safeAreaPadding.left;
  double get safeRight => safeAreaPadding.right;
}
