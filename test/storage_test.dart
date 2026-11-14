// 用受控数据验证持久化存储。

import 'package:flutter_getx_starter/common/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('存储初始化与读写删除', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService();
    expect(await storage.init(), same(storage));
    expect(await storage.prefs.setString('course', 'value'), isTrue);
    expect(storage.prefs.getString('course'), 'value');
    await storage.prefs.remove('course');
    expect(storage.prefs.getString('course'), isNull);
  });
}
