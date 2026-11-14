// 用受控数据验证计数页面生命周期。

import 'package:flutter/material.dart';
import 'package:flutter_getx_starter/app.dart';
import 'package:flutter_getx_starter/pages/index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(() => Get.reset());

  testWidgets('更新计数，退出释放，再进入创建新实例', (tester) async {
    await tester.pumpWidget(const App());
    await tester.tap(find.byKey(const Key('open-counter')));
    await tester.pumpAndSettle();

    final first = Get.find<CounterController>();
    expect(find.text('计数：0'), findsOneWidget);

    await tester.tap(find.byKey(const Key('increment-counter')));
    await tester.pump();
    expect(first.count, 1);
    expect(find.text('计数：1'), findsOneWidget);

    await tester.tap(find.byKey(const Key('counter-back')));
    await tester.pumpAndSettle();
    expect(Get.isRegistered<CounterController>(), isFalse);
    expect(first.isClosed, isTrue);

    await tester.tap(find.byKey(const Key('open-counter')));
    await tester.pumpAndSettle();
    final second = Get.find<CounterController>();
    expect(identical(first, second), isFalse);
    expect(find.text('计数：0'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
