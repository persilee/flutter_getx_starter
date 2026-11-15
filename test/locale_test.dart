// 用受控数据验证语言保存与恢复。

import 'package:flutter/material.dart';
import 'package:flutter_getx_starter/common/index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(() => Get.reset());
  testWidgets('保存语言并恢复，非法值回退', (tester) async {
    SharedPreferences.setMockInitialValues({'app_locale': 'invalid'});
    final storage = await tester.runAsync(() => StorageService().init());
    final locale = await tester.runAsync(() => LocaleService(storage!).init());
    expect(locale!.locale, const Locale('en', 'US'));
    await tester.pumpWidget(
      GetMaterialApp(home: const Scaffold(body: Text('locale'))),
    );
    final changed = locale.change(const Locale('zh', 'CN'));
    await tester.pumpAndSettle();
    await changed;
    final restored = await tester.runAsync(
      () => LocaleService(storage!).init(),
    );
    expect(restored!.locale, const Locale('zh', 'CN'));
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
