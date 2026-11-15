// 集中定义可复用配置，调用方从公共入口读取。

/// 文件作用：
/// - 页面留白节奏（xs ~ xxl）
///
/// 间距 token。
///
/// 页面布局优先使用这些尺寸，保证列表、卡片、表单之间的留白节奏一致。
abstract final class AppSpacing {
  /// App布局基准，区别于HTML文档的桌面展示留白。
  static const double page = 20;
  static const double card = 16;
  static const double sheetTop = 14;
  static const double sheetBottom = 30;
  static const double touch = 48;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
}
