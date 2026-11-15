// 用受控数据验证主题持久化恢复。

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_getx_starter/app.dart';
import 'package:flutter_getx_starter/global.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'support.dart';

void main() {
  setUp(prepare);
  tearDown(() => Get.reset());
  testWidgets('主题切换后保存模式', (tester) async {
    await tester.runAsync(Global.init);
    await tester.pumpWidget(const App());
    final context = tester.element(find.byType(Scaffold).first);
    AdaptiveTheme.of(context).setDark();
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      expect(await AdaptiveTheme.getThemeMode(), AdaptiveThemeMode.dark);
    });
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
