// 将异步初始化与页面渲染分开，提供加载、失败重试和就绪状态。

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app.dart';
import 'common/index.dart';
import 'global.dart';

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key, this.initialize, this.readyBuilder});
  final Future<void> Function()? initialize;
  final WidgetBuilder? readyBuilder;
  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  Object? error;
  bool ready = false;
  bool loading = true;
  @override
  // 页面创建时接入本页面拥有的控制器或资源。
  void initState() {
    super.initState();
    start();
  }

  Future<void> start() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await (widget.initialize ?? Global.init)();
      if (!mounted) return;
      setState(() {
        ready = true;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e;
        loading = false;
      });
    }
  }

  @override
  // 根据当前参数与状态构建界面，交互通过回调交给状态拥有者。
  Widget build(BuildContext context) {
    if (ready) return widget.readyBuilder?.call(context) ?? const App();
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: loading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(TrKeys.initializationFailed.tr),
                    Text('$error'),
                    FilledButton(
                      onPressed: start,
                      child: Text(TrKeys.retry.tr),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
