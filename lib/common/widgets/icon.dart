// 封装可复用界面组件，通过参数和回调接入页面。

import 'package:flutter/material.dart';

class IconWidget extends StatelessWidget {
  const IconWidget.icon(this.icon, {super.key, this.size = 24});
  final IconData icon;
  final double size;
  @override
  // 根据当前参数与状态构建界面，交互通过回调交给状态拥有者。
  Widget build(BuildContext context) => Icon(icon, size: size);
}
