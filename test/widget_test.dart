// 用受控数据验证当前阶段应用挂载。
import 'package:flutter/material.dart';
import 'package:flutter_getx_starter/app.dart';
import 'package:flutter_getx_starter/global.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'support.dart';

void main() {
  setUp(prepare);
  tearDown(() => Get.reset());
  testWidgets('当前阶段应用可以挂载', (tester) async {
    await tester.runAsync(Global.init);
    await tester.pumpWidget(const App());
    await tester.pump();
    expect(find.byType(Scaffold), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
