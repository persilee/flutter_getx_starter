// 用受控数据验证主题配置。

import 'package:flutter/material.dart';
import 'package:flutter_getx_starter/common/index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('亮暗主题与扩展回退', () {
    expect(
      AppTheme.lightTheme.extension<AppStyle>()!.background,
      isNot(AppTheme.darkTheme.extension<AppStyle>()!.background),
    );
    final fallback = AppTheme.build(
      Brightness.light,
      glassEnabled: false,
    ).extension<AppStyle>()!;
    expect(fallback.glassEnabled, isFalse);
    expect(
      AppStyle.light.lerp(AppStyle.dark, 0).background,
      AppStyle.light.background,
    );
  });
}
