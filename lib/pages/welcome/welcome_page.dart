// 组织本页面布局与交互入口，业务动作交给控制器或服务。

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../common/index.dart';
import 'welcome_controller.dart';

/// 三页 PageView 引导，最后一页显示「开始」。
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  // initState 中赋值一次；Controller 管引导状态，Page 管导航和布局。
  late final WelcomeController _c;
  // PageController 只负责滑动与动画，由 Page 持有并在 dispose 释放。
  final _pages = PageController();

  @override
  // 页面创建时接入本页面拥有的控制器或资源。
  void initState() {
    super.initState();
    _c = Get.put(WelcomeController());
  }

  @override
  // 页面离开时释放本页面拥有的资源，避免重复进入后残留状态。
  void dispose() {
    // 先释放本页创建的翻页控制器，再删除 GetX Controller。
    _pages.dispose();
    Get.delete<WelcomeController>();
    super.dispose();
  }

  Future<void> _onStart() async {
    // Controller 负责保存完成标记；Page 等待结果，不直接写存储。
    final ok = await _c.complete();
    // 保存失败留在引导页；等待期间已离开页面时也不能继续导航。
    if (!ok || !mounted) return;
    // go 切换到下一流程的路由配置，不把 Splash 作为 push 的上一页保留。
    // 本节新增 Login 后，引导结束改为进入登录页；此处不建立登录会话。
    context.go(AppRoutes.login);
  }

  @override
  // 根据当前参数与状态构建界面，交互通过回调交给状态拥有者。
  Widget build(BuildContext context) {
    // Dart Record 保存每页的标题和正文；$1 为标题，$2 为正文。
    // 在 build 中读取 .tr，语言变化后重新构建时能使用最新翻译。
    final slides = [
      (TrKeys.welcomeTitle.tr, TrKeys.welcomeBody.tr),
      (TrKeys.welcomeThemeTitle.tr, TrKeys.welcomeThemeBody.tr),
      (TrKeys.welcomeReadyTitle.tr, TrKeys.welcomeReadyBody.tr),
    ];
    return PageScaffold(
      // id 必须与 Controller 的 update([idBody]) 一致，才会收到定向更新。
      body: GetBuilder<WelcomeController>(
        id: WelcomeController.idBody,
        builder: (c) => Column(
          children: [
            // 给 PageView 分配剩余高度，底部页码和按钮留在固定区域。
            Expanded(
              child: PageView(
                controller: _pages,
                // 以 PageView 实际切页结果更新索引，手势滑动和按钮翻页都走同一回调。
                onPageChanged: c.onPageChanged,
                // 保存完成标记时保持在最后一页。
                physics: c.busy ? const NeverScrollableScrollPhysics() : null,
                children: [
                  // 集合 for 为三组文案生成页面；每页可单独滚动，容纳较长翻译。
                  for (final slide in slides)
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slide.$1,
                            style: AppTextStyles.displayOn(context),
                          ),
                          const SizedBox(height: 12),
                          Text(slide.$2, style: AppTextStyles.bodyOn(context)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // 内部索引从 0 开始，展示给用户时加 1；最后一页的索引是 2。
            Text('${c.pageIndex + 1} / ${slides.length}'),
            // 仅保存失败时显示错误，下一次重试前 Controller 会清除旧错误。
            if (c.error != null) Text(c.error!),
            const SizedBox(height: 16),
            // 仅最后一页显示开始按钮，其余页面只允许继续翻页。
            if (c.pageIndex == slides.length - 1)
              PrimaryButton(
                label: TrKeys.start.tr,
                // 把保存状态映射为按钮加载态；Controller 还会阻止重复提交。
                loading: c.busy,
                onPressed: _onStart,
              )
            else
              PrimaryButton(
                label: TrKeys.next.tr,
                // 这里只启动翻页动画；pageIndex 由 onPageChanged 更新，不手动递增。
                onPressed: () => _pages.nextPage(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
