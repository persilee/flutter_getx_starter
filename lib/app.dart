// 装配根组件，将当前已经完成的主题、翻译与导航接入应用。
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'common/index.dart';
import 'pages/index.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  // 根据当前参数与状态构建界面，交互通过回调交给状态拥有者。
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppLabels.appName,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
