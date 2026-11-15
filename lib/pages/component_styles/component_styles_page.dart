// 组织本页面布局与交互入口，业务动作交给控制器或服务。

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/index.dart';
import 'state_demo_page.dart';

class ComponentStylesPage extends StatefulWidget {
  const ComponentStylesPage({super.key});
  @override
  State<ComponentStylesPage> createState() => _ComponentStylesPageState();
}

class _ComponentStylesPageState extends State<ComponentStylesPage> {
  // 文本控制器由此 State 创建，因此也必须由此 State 释放。
  final input = TextEditingController();
  bool checked = false;
  int tab = 0;
  @override
  // 页面离开时释放本页面拥有的资源，避免重复进入后残留状态。
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  // 根据当前参数与状态构建界面，交互通过回调交给状态拥有者。
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(TrKeys.componentStyles.tr)),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 分段选择与勾选只用于本页展示，由 setState 更新局部演示状态。
          SegmentedTabs(
            labels: [TrKeys.sample.tr, TrKeys.choose.tr],
            selectedIndex: tab,
            onChanged: (index) => setState(() => tab = index),
          ),
          AppCategoryChip(label: TrKeys.sample.tr, selected: checked),
          TextWidget.body(TrKeys.sample.tr),
          const IconWidget.icon(Icons.widgets_outlined),
          PrimaryButton(label: TrKeys.confirm.tr, onPressed: () {}),
          GlassCard(child: Text(TrKeys.sample.tr)),
          SettingsGroup(
            children: [SettingsTile(label: TrKeys.sample.tr, onTap: () {})],
          ),
          // 复用公共输入组件的主题和密码显隐行为，而不是在页面重复实现。
          InputWidget(
            controller: input,
            placeholder: TrKeys.inputName.tr,
            obscureText: true,
          ),
          // 回调可能返回 null；这里按未选中处理，再重建页面显示结果。
          CheckboxWidget(
            checked: checked,
            title: TrKeys.choose.tr,
            onChanged: (value) => setState(() => checked = value ?? false),
          ),
          PrimaryButton(
            label: TrKeys.confirm.tr,
            // 弹窗需要当前 BuildContext；这里只演示交互，不执行真实业务。
            onPressed: () => AppConfirmDialog.show(
              context: context,
              title: TrKeys.confirm.tr,
              message: TrKeys.sample.tr,
              onConfirm: () async {},
            ),
          ),
          PrimaryButton(
            label: TrKeys.switchTheme.tr,
            onPressed: () => showThemeModeSheet(context),
          ),
          ResultStateCard(
            icon: Icons.check,
            title: TrKeys.sample.tr,
            status: ResultStatus.success,
          ),
          PrimaryButton(
            label: TrKeys.load.tr,
            // 这是局部状态演示页的原生临时入口，不属于本章集中管理的业务路由。
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const StateDemoPage()),
            ),
          ),
        ],
      ),
    ),
  );
}
