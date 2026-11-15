// 页面把 Controller 的业务状态映射到公共展示组件。
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/index.dart';
import 'state_demo_controller.dart';

class StateDemoPage extends StatefulWidget {
  const StateDemoPage({super.key});

  @override
  State<StateDemoPage> createState() => _StateDemoPageState();
}

class _StateDemoPageState extends State<StateDemoPage> {
  final c = StateDemoController();

  // 本地异步替身：保留一秒等待，确保能观察到加载组件。
  Future<void> _simulate(DemoStatus result) => c.load(() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return switch (result) {
      DemoStatus.empty => <String>[],
      DemoStatus.error => throw StateError('controlled'),
      DemoStatus.success => ['ok'],
      DemoStatus.loading => throw ArgumentError('loading 不是请求结果'),
    };
  });

  @override
  void dispose() {
    c.onDelete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageScaffold(
    topBar: TopBar(
      title: TrKeys.load.tr,
      onBack: () => Navigator.of(context).pop(),
    ),
    body: GetBuilder<StateDemoController>(
      init: c,
      global: false,
      // Controller 由本页面创建并在 dispose 中释放。
      autoRemove: false,
      builder: (controller) {
        final loading = controller.status == DemoStatus.loading;
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          children: [
            switch (controller.status) {
              DemoStatus.loading => ResultStateCard(
                icon: Icons.hourglass_empty,
                title: TrKeys.processing.tr,
                status: ResultStatus.loading,
                tone: ResultTone.neutral,
              ),
              DemoStatus.empty => EmptyStateView(message: TrKeys.empty.tr),
              DemoStatus.error => ResultStateCard(
                icon: Icons.error_outline,
                title: TrKeys.failure.tr,
                status: ResultStatus.error,
                tone: ResultTone.danger,
                onRetry: () => _simulate(DemoStatus.success),
              ),
              DemoStatus.success => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    TrKeys.ready.tr,
                    style: AppTextStyles.pageTitleOn(context),
                  ),
                  for (final item in controller.items)
                    ListTile(title: Text(item)),
                ],
              ),
            },
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: TrKeys.empty.tr,
              enabled: !loading,
              onPressed: () => _simulate(DemoStatus.empty),
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: TrKeys.failure.tr,
              enabled: !loading,
              onPressed: () => _simulate(DemoStatus.error),
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: TrKeys.ready.tr,
              enabled: !loading,
              onPressed: () => _simulate(DemoStatus.success),
            ),
          ],
        );
      },
    ),
  );
}
