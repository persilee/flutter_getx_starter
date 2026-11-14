// 初始化 Flutter 运行环境，并启动当前阶段的应用入口。

import 'package:flutter/material.dart';

import 'app_bootstrap.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppBootstrap());
}
