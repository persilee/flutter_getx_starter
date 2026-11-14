// 集中定义可复用配置，调用方从公共入口读取。
abstract final class AppConfig {
  // 从环境变量中读取，默认值 'GetX App'
  static const appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'GetX App',
  );
}
