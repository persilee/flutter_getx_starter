// 用受控数据验证状态流，并验证页面确实复用公共组件。
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_starter/common/index.dart';
import 'package:flutter_getx_starter/pages/component_styles/state_demo_controller.dart';
import 'package:flutter_getx_starter/pages/component_styles/state_demo_page.dart';

void main() {
  test('四态转换及重试', () async {
    final c = StateDemoController();
    addTearDown(() => c.onDelete());
    final pending = Completer<List<String>>();
    final task = c.load(() => pending.future);
    expect(c.status, DemoStatus.loading);
    pending.complete([]);
    await task;
    expect(c.status, DemoStatus.empty);
    await c.load(() => Future.error(StateError('controlled')));
    expect(c.status, DemoStatus.error);
    await c.load(() async => ['ok']);
    expect(c.status, DemoStatus.success);
    expect(c.items, ['ok']);
  });

  test('加载中不重复请求，关闭后不提交结果', () async {
    final c = StateDemoController();
    final pending = Completer<List<String>>();
    final task = c.load(() => pending.future);
    var duplicateCalled = false;
    await c.load(() async {
      duplicateCalled = true;
      return ['duplicate'];
    });
    expect(duplicateCalled, isFalse);
    c.onDelete();
    pending.complete(['late']);
    await task;
    expect(c.items, isEmpty);
    expect(c.status, DemoStatus.loading);
  });

  testWidgets('公共空态、加载、失败与卡片内重试', (tester) async {
    addTearDown(Get.reset);
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('zh', 'CN'),
        theme: AppTheme.lightTheme,
        home: const StateDemoPage(),
      ),
    );
    expect(find.byType(PageScaffold), findsOneWidget);
    expect(find.byType(EmptyStateView), findsOneWidget);

    await tester.tap(find.widgetWithText(PrimaryButton, TrKeys.failure.tr));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<ResultStateCard>(find.byType(ResultStateCard)).status,
      ResultStatus.loading,
    );
    expect(
      tester
          .widget<PrimaryButton>(
            find.widgetWithText(PrimaryButton, TrKeys.empty.tr),
          )
          .enabled,
      isFalse,
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(
      tester.widget<ResultStateCard>(find.byType(ResultStateCard)).status,
      ResultStatus.error,
    );

    // 点击公共结果卡片自己的重试按钮，而不是页面外的成功入口。
    final retry = find.descendant(
      of: find.byType(ResultStateCard),
      matching: find.widgetWithText(PrimaryButton, TrKeys.retry.tr),
    );
    await tester.tap(retry);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byType(ResultStateCard), findsNothing);
    expect(find.widgetWithText(ListTile, 'ok'), findsOneWidget);

    await tester.tap(find.widgetWithText(PrimaryButton, TrKeys.empty.tr));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byType(EmptyStateView), findsOneWidget);
    expect(find.text('ok'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
