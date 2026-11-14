// 组织本页面布局与交互入口，业务动作交给控制器或服务。

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/index.dart';
import 'counter_controller.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  @override
  // 页面创建时接入本页面拥有的控制器或资源。
  void initState() {
    super.initState();
    Get.put(CounterController());
  }

  @override
  // 页面离开时释放本页面拥有的资源，避免重复进入后残留状态。
  void dispose() {
    Get.delete<CounterController>();
    super.dispose();
  }

  @override
  // 根据当前参数与状态构建界面，交互通过回调交给状态拥有者。
  Widget build(BuildContext context) {
    final controller = Get.find<CounterController>();
    return Scaffold(
      appBar: AppBar(
        title: Text(TrKeys.counterTitle.tr),
        leading: const BackButton(key: Key('counter-back')),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(TrKeys.counterHint.tr),
            const SizedBox(height: 16),
            GetBuilder<CounterController>(
              id: CounterController.idCounter,
              builder: (c) => Text('${TrKeys.counterValue.tr}${c.count}'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('increment-counter'),
              onPressed: controller.increment,
              child: Text(TrKeys.increment.tr),
            ),
          ],
        ),
      ),
    );
  }
}
