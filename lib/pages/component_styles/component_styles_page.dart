import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/index.dart';

/// 公共组件调试目录：直接渲染真实组件，所有操作仅修改页面内的演示状态。
class ComponentStylesPage extends StatefulWidget {
  const ComponentStylesPage({super.key});

  @override
  State<ComponentStylesPage> createState() => _ComponentStylesPageState();
}

class _ComponentStylesPageState extends State<ComponentStylesPage> {
  bool _loading = false;
  String _feedback = '点击组件查看交互结果';

  void _report(String message) {
    if (mounted) setState(() => _feedback = message);
  }

  /// 模拟异步等待并阻止重复触发，退出页面后不再更新状态。
  Future<void> _simulate() async {
    if (_loading) return;
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _feedback = '模拟操作完成';
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(TrKeys.componentStyles.tr)),
    body: ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        Semantics(liveRegion: true, child: TextWidget.muted(_feedback)),
        const SizedBox(height: AppSpacing.md),
        ..._basics(context),
        ..._buttons(),
        ..._cards(),
      ],
    ),
  );

  /// 示例分区保留组件名称，方便从界面定位到公共组件源码。
  Widget _section(String title, List<Widget> children) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.sm,
      children: [
        SectionHeader(title: title),
        ...children,
      ],
    ),
  );

  List<Widget> _basics(BuildContext context) => [
    _section('主题语义色', [
      Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final entry in {
            'Primary': context.appPrimary,
            'Surface': context.appSurface,
            'Muted': context.appMuted,
            'Border': context.appBorder,
            'Error': context.appErrorText,
            'Success': AppColors.success,
            'Warning': AppColors.warning,
          }.entries)
            SizedBox(
              width: 96,
              child: Column(
                spacing: AppSpacing.xs,
                children: [
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: entry.value,
                      border: Border.all(color: context.appBorder),
                      borderRadius: BorderRadius.circular(AppRadius.input),
                    ),
                  ),
                  TextWidget.label(entry.key),
                ],
              ),
            ),
        ],
      ),
    ]),
    _section('TextWidget · 排版与尺寸', [
      for (final type in TextWidgetType.values)
        TextWidget(text: '${type.name} · 组件样式', type: type),
      for (final scale in WidgetScale.values)
        TextWidget.body('字号档位 ${scale.name}', scale: scale),
      const TextWidget.muted('页面留白 20 · 卡片留白 16\n卡片圆角 16 · 输入/按钮圆角 12'),
    ]),
    _section('IconWidget · 图标与尺寸', [
      Wrap(
        spacing: AppSpacing.md,
        children: [
          const IconWidget.icon(Icons.notifications_outlined, size: 24),
          const IconWidget.icon(Icons.favorite_outline, size: 32),
        ],
      ),
    ]),
  ];
  List<Widget> _buttons() => [
    _section('ButtonWidget · 全部变体', [
      // 不同尺寸的示例按钮按中心对齐，避免大按钮向下突出。
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final variant in ButtonWidgetVariant.values)
            ButtonWidget(
              variant: variant,
              text: variant == ButtonWidgetVariant.icon ? null : variant.name,
              icon: variant == ButtonWidgetVariant.icon
                  ? const Icon(Icons.add, semanticLabel: '添加')
                  : null,
              onTap: () => _report('点击 ${variant.name}'),
            ),
        ],
      ),
      // 不同尺寸的示例按钮按中心对齐，避免大按钮向下突出。
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final scale in WidgetScale.values)
            ButtonWidget.primary(scale.name, scale: scale, onTap: _simulate),
        ],
      ),
      const ButtonWidget.primary('禁用按钮', enabled: false),
      ButtonWidget.primary('模拟加载', loading: _loading, onTap: _simulate),
    ]),
    _section('AppButton / PrimaryButton / GhostButton', [
      for (final variant in AppButtonVariant.values)
        AppButton(label: variant.name, variant: variant, onPressed: _simulate),
      PrimaryButton(
        label: '主要操作 · 点击加载',
        size: AppButtonSize.prominent,
        loading: _loading,
        onPressed: _simulate,
      ),
      const GhostButton(label: '禁用次要操作', enabled: false),
      // 不同尺寸的示例按钮按中心对齐，避免大按钮向下突出。
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.sm,
        children: [
          GlassIconButton(
            icon: Icons.add,
            semanticLabel: '添加示例',
            onPressed: () => _report('点击玻璃图标按钮'),
          ),
          TopBarAction(label: '保存', onPressed: () => _report('点击顶部保存')),
        ],
      ),
    ]),
  ];
  List<Widget> _cards() => [
    _section('GlassSurface / GlassCard / StatCard', [
      GlassSurface(
        enableBlur: true,
        padding: const EdgeInsets.all(AppSpacing.card),
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: const TextWidget.body('玻璃表面：跟随当前主题'),
      ),
      GlassCard(
        // 使用规范卡片留白，文字与点击反馈共用完整的卡片区域。
        padding: const EdgeInsets.all(AppSpacing.card),
        child: const TextWidget.body('可点击卡片'),
        onTap: () => _report('点击 GlassCard'),
      ),
      const StatCard(value: '128', label: '演示统计'),
    ]),
    _section('ListTileWidget / ListRowCard', [
      ListTileWidget(
        title: const TextWidget.body('基础列表项'),
        subtitle: const TextWidget.muted('支持点击和长按'),
        onTap: () => _report('点击基础列表项'),
        onLongPress: () => _report('长按基础列表项'),
      ),
      ListRowCard(
        title: '项目列表卡片',
        subtitle: '标题、说明、尾部与底部内容',
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _report('点击 ListRowCard'),
      ),
      SettingsGroup(
        children: [
          SettingsTile(
            label: '设置项 A',
            leading: const Icon(Icons.settings_outlined),
            onTap: () => _report('点击设置项 A'),
          ),
          SettingsTile(
            label: '设置项 B',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _report('点击设置项 B'),
          ),
        ],
      ),
    ]),
  ];
}
