// 集中定义可复用配置，调用方从公共入口读取。

import 'package:flutter/material.dart';

abstract final class AppColors {
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
}
