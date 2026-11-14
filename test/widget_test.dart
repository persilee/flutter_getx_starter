// 用受控数据验证当前阶段应用挂载。
import 'package:flutter_getx_starter/app.dart';
import 'package:flutter_getx_starter/common/values/app_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(() => Get.reset());

  testWidgets('GetX 根组件保留首页', (tester) async {
    await tester.pumpWidget(const App());

    expect(find.byType(GetMaterialApp), findsOneWidget);
    expect(find.text(AppConfig.appName), findsOneWidget);
    expect(find.text('框架骨架已就绪'), findsOneWidget);
  });
}
