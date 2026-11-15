// 用受控数据验证凭证写入顺序。

import 'package:flutter_getx_starter/common/index.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  // 初始化测试绑定，后续使用 Flutter 插件或模拟平台通道前先准备运行环境。
  TestWidgetsFlutterBinding.ensureInitialized();
  // 每个用例前重置受控存储和环境，不依赖开发设备上的历史登录记录。
  setUp(prepare);
  test('保存后清除不会被较早落盘复活', () async {
    final storage = await StorageService().init();
    final token = TokenService(storage);
    final save = token.save(accessToken: 'a', refreshToken: 'r', userId: 'u');
    final clear = token.clear();
    expect(token.hasToken, isFalse);
    await Future.wait([save, clear]);
    expect(TokenService(storage).hasToken, isFalse);
  });
}
