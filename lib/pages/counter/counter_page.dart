// 组织本页面布局与交互入口，业务动作交给控制器或服务。

import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    // 创建控制器
    Get.put(CounterController());
  }

  @override
  // 页面离开时释放本页面拥有的资源，避免重复进入后残留状态。
  void dispose() {
    // 删除控制器
    Get.delete<CounterController>();
    super.dispose();
  }

  @override
  // 根据当前参数与状态构建界面，交互通过回调交给状态拥有者。
  Widget build(BuildContext context) {
    // 获取控制对象
    final controller = Get.find<CounterController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Controller 示例'),
        leading: const BackButton(key: Key('counter-back')),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('只有计数区域需要更新'),
            const SizedBox(height: 16),
            // getx builder 手动更新
            GetBuilder<CounterController>(
              // 更新点 id
              id: CounterController.idCounter,
              // 动态构建函数, c 是控制器对象
              builder: (c) => Text('计数：${c.count}'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('increment-counter'),
              // 控制器触发 加法计算
              onPressed: controller.increment,
              child: const Text('增加一次'),
            ),
          ],
        ),
      ),
    );
  }
}
