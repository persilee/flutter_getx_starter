// 集中定义可复用配置，调用方从公共入口读取。
abstract final class AppConfig {
  static const appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'GetX App',
  );
  // UI 设计稿尺寸，便于在不同屏幕上按比例缩放。
  static const ui = UiConfig(designWidth: 390, designHeight: 844);

  // 从 --dart-define 读取编译期配置；修改参数需要重新运行或构建。
  static const baseUrl = String.fromEnvironment('BASE_URL', defaultValue: '');

  // 从编译参数读取日志开关，传入 true / false；热重载不会重新编译环境变量。
  static const enableHttpLog = bool.fromEnvironment(
    'ENABLE_HTTP_LOG',
    defaultValue: true,
  );

  // 是否有有效的 baseUrl，便于在运行时判断是否需要提示用户配置。
  static bool get hasBaseUrl => baseUrl.trim().isNotEmpty;

  // 登录、刷新、图片代理等接口路径，便于在运行时判断是否需要附加 Token。
  static const authLoginPath = '/api/auth/login';
  static const authRefreshPath = '/api/auth/refresh';
  static const proxyImagePath = '/api/files/img';

  // 白名单与实际登录、刷新路径保持一致，否则可能给认证请求附加旧凭证。
  static const authWhitelist = [authLoginPath, authRefreshPath];

  // 测试账号，便于在开发阶段快速登录。
  static const demoEmail = "";
  static const demoPassword = "";
}

class UiConfig {
  const UiConfig({required this.designWidth, required this.designHeight});
  final double designWidth;
  final double designHeight;
}
