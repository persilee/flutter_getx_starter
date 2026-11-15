// 集中定义可复用配置，调用方从公共入口读取。
abstract final class AppConfig {
  // 从环境变量中读取，默认值 'GetX App'
  static const appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'GetX App',
  );

  /// UI 设计稿配置
  /// [UiConfig.designWidth] 设计稿宽度
  /// [UiConfig.designHeight] 设计稿高度
  static const ui = UiConfig(designWidth: 390, designHeight: 844);
}

class UiConfig {
  const UiConfig({required this.designWidth, required this.designHeight});

  final double designWidth;
  final double designHeight;
}
