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
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _password = TextEditingController();
  final _search = TextEditingController();
  bool _checked = false;
  bool _blur = true;
  int _tab = 0;
  int _underline = 0;
  int _bottom = 0;
  String _filter = 'all';

  @override
  void dispose() {
    _name.dispose();
    _password.dispose();
    _search.dispose();
    super.dispose();
  }

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
        ..._inputs(),
        ..._choices(),
        ..._navigation(),
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
      CheckboxWidget(
        title: '启用示例模糊',
        checked: _blur,
        onChanged: (value) => setState(() => _blur = value ?? false),
      ),
      GlassSurface(
        enableBlur: _blur,
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
        footer: const AppCategoryChip(label: '示例分类'),
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
  List<Widget> _inputs() => [
    _section('InputWidget / GlassSearchField', [
      InputWidget(
        controller: _password,
        placeholder: '密码：支持显隐与清空',
        obscureText: true,
      ),
      GlassSearchField(
        controller: _search,
        hintText: '输入搜索内容',
        onChanged: (value) => _report('搜索内容：$value'),
      ),
    ]),
    _section('AppFormField / InputFormFieldWidget', [
      const AppFormField(label: '只读状态', hint: '此处不可编辑', readOnly: true),
      const AppFormField(
        label: '错误状态',
        hint: '输入内容',
        errorText: '这是错误样式示例',
        helper: '辅助说明',
      ),
      Form(
        key: _formKey,
        child: InputFormFieldWidget(
          controller: _name,
          labelText: '名称（必填）',
          placeholder: '至少输入两个字符',
          validator: (value) =>
              (value?.trim().length ?? 0) < 2 ? '名称至少需要两个字符' : null,
        ),
      ),
      PrimaryButton(
        label: '校验表单',
        onPressed: () =>
            _report(_formKey.currentState!.validate() ? '表单校验通过' : '请修正表单错误'),
      ),
      GhostButton(
        label: '重置表单',
        onPressed: () {
          _formKey.currentState!.reset();
          // 外部控制器在重建后可能成为新的初值，显式清空演示输入。
          _name.clear();
          _report('表单已重置');
        },
      ),
    ]),
  ];
  List<Widget> _choices() => [
    _section('CheckboxWidget', [
      CheckboxWidget(
        title: '接收提醒',
        description: '点击整行测试选中状态',
        checked: _checked,
        onChanged: (value) => setState(() => _checked = value ?? false),
      ),
      const CheckboxWidget(title: '禁用复选框', checked: true),
    ]),
  ];
  List<Widget> _navigation() => [
    _section('AppCategoryChip / FilterChipRow', [
      const Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          AppCategoryChip(label: '默认'),
          AppCategoryChip(label: '已选中', selected: true, showDot: false),
          AppCategoryChip(label: '成功色', color: AppColors.success),
        ],
      ),
      FilterChipRow(
        items: const [
          FilterChipItem(value: 'all', label: '全部'),
          FilterChipItem(value: 'unread', label: '未读'),
        ],
        selectedValue: _filter,
        onSelected: (value) => setState(() {
          _filter = value;
          _feedback = '筛选：$value';
        }),
      ),
    ]),
    _section('SegmentedTabs / UnderlineTabs', [
      SegmentedTabs(
        labels: const ['视频', '频道'],
        selectedIndex: _tab,
        onChanged: (value) => setState(() => _tab = value),
      ),
      TextWidget.body('当前分段：${_tab == 0 ? '视频' : '频道'}'),
      UnderlineTabs(
        labels: const ['未读', '收藏', '稍后'],
        selectedIndex: _underline,
        onChanged: (value) => setState(() => _underline = value),
      ),
      TextWidget.body('当前下划线选项：${_underline + 1}'),
    ]),
    _section('TopBar / SectionHeader / AppBottomTabBar', [
      TopBar(
        title: '示例导航栏',
        onBack: () => _report('点击示例返回'),
        trailing: [TopBarAction(label: '编辑', onPressed: () => _report('点击编辑'))],
      ),
      AppBottomTabBar(
        items: const [
          AppBottomTabBarItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: '首页',
          ),
          AppBottomTabBarItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: '我的',
          ),
        ],
        activeIndex: _bottom,
        onChanged: (value) => setState(() {
          _bottom = value;
          _feedback = '底部导航：${value + 1}';
        }),
      ),
    ]),
  ];
}
