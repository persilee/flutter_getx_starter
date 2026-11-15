// 集中声明页面路径或导航规则，页面通过 go_router 访问。
// 只作为常量命名空间，不需要实例化或继承。
// 统一修改路径后，路由表和按钮会引用同一份值，减少字符串拼写错误。
abstract final class AppRoutes {
  static const home = '/home';
  static const counter = '/counter';
  static const componentStyles = '/component-styles';
  static const splash = '/splash';
}
