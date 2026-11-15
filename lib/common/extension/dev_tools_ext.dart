part of 'app_extensions.dart';

/// 开发工具
extension DevTools on Object {
  /// 打印日志
  void log() => devtools.log(toString());
}
