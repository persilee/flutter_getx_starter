// 用受控数据验证启动失败与重试。

import 'package:flutter/material.dart';
import 'package:flutter_getx_starter/app_bootstrap.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('初始化失败后重试就绪', (tester) async {
    var attempts = 0;
    await tester.pumpWidget(
      AppBootstrap(
        initialize: () async {
          if (++attempts == 1) throw StateError('controlled');
        },
        readyBuilder: (_) => const MaterialApp(home: Text('ready')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('controlled'), findsOneWidget);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.text('ready'), findsOneWidget);
    expect(attempts, 2);
  });
}
