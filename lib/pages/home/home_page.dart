// 组织本页面布局与交互入口，业务动作交给控制器或服务。

import 'package:flutter/material.dart';
import 'package:flutter_getx_starter/common/values/app_labels.dart';
import 'package:flutter_getx_starter/pages/counter/counter_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  // 根据当前参数与状态构建界面，交互通过回调交给状态拥有者。
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppLabels.appName)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('框架骨架已就绪'),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('open-counter'),
              onPressed: () {
                // 导航控制器，压入 计算器页面
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(builder: (_) => const CounterPage()),
                );
              },
              child: const Text('打开 Controller 示例'),
            ),
          ],
        ),
      ),
    );
  }
}
