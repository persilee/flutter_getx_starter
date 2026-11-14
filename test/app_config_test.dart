// 用受控数据验证编译配置接入。

import 'package:flutter_getx_starter/app.dart';
import 'package:flutter_getx_starter/common/index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(() => Get.reset());

  testWidgets('编译配置同时进入应用标题与首页标题', (tester) async {
    await tester.pumpWidget(const App());

    final app = tester.widget<GetMaterialApp>(find.byType(GetMaterialApp));
    expect(app.title, AppConfig.appName);
    expect(find.text(AppConfig.appName), findsOneWidget);
  });
}
