// 集中声明页面路径或导航规则，页面通过 go_router 访问。

import 'package:go_router/go_router.dart';

import '../../pages/index.dart';
import 'routes.dart';

// 路由表集中在这里，页面只引用路径常量，不各自创建 GoRouter。
// 本章尚无 redirect 登录守卫；注册路径仅表示该页面可以被导航访问。
class AppRouter {
  // static final 在首次访问时创建一个路由实例，后续构建复用它。
  // 不要在 build 中反复创建，否则导航状态可能随重建丢失。
  static final router = GoRouter(
    // 默认启动位置；Web 外部传入的地址也可能影响实际初始位置。
    initialLocation: AppRoutes.splash,
    // 每个 GoRoute 把路径映射为页面；builder 的两个 _ 表示暂不使用 context 和 state。
    // 只注册当前已完成的页面，避免依赖后续课节尚未创建的类型。
    routes: [
      GoRoute(path: AppRoutes.home, builder: (_, _) => const HomePage()),
      GoRoute(path: AppRoutes.counter, builder: (_, _) => const CounterPage()),
      GoRoute(
        path: AppRoutes.componentStyles,
        builder: (_, _) => const ComponentStylesPage(),
      ),
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashPage()),
      GoRoute(path: AppRoutes.welcome, builder: (_, _) => const WelcomePage()),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginPage()),
    ],
  );
}
