// 集中声明页面路径或导航规则，页面通过 go_router 访问。

import 'package:go_router/go_router.dart';

import '../../pages/index.dart';
import 'routes.dart';

import 'package:get/get.dart';

import '../services/index.dart';

class AppRouter {
  static final router = GoRouter(
    // 启动页
    initialLocation: AppRoutes.splash,
    // 监听身份变化后重新判定路由，登录和退出不需要每个按钮都手动跳页。
    refreshListenable: Get.find<SessionService>().revision,
    // 按下面的判断顺序分流；返回 null 表示放行，返回路径表示改去另一个页面。
    redirect: (context, state) {
      final path = state.matchedLocation;
      // 先放行 Splash，让启动页完成首帧展示与延迟分流。
      if (path == AppRoutes.splash) {
        return null;
      }
      final seen = Get.find<AppLaunchService>().hasSeenWelcome;
      final logged = Get.find<SessionService>().isLogin;
      // 未完成引导优先进入 Welcome；已在 Welcome 时返回 null，避免自我重定向。
      if (!seen) {
        return path == AppRoutes.welcome ? null : AppRoutes.welcome;
      }
      if (path == AppRoutes.welcome) {
        return logged ? AppRoutes.home : AppRoutes.login;
      }
      // 引导完成后才检查登录态；未登录只能停留在 Login，其他注册页面仍受守卫约束。
      if (!logged) {
        return path == AppRoutes.login ? null : AppRoutes.login;
      }
      // 已登录用户无需继续停在登录页；切回 Home 完成流程。
      if (path == AppRoutes.login) {
        return AppRoutes.home;
      }
      return null;
    },
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
