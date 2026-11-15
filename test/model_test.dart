// 用受控数据验证认证模型解析。

import 'package:flutter_getx_starter/common/index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('手写认证解析与不可变更新', () {
    final user = AuthUser.fromApiJson({'id': 'one', 'email': 'a@b.c'});
    expect(user.copyWith(id: 'two').id, 'two');
    expect(user.id, 'one');
    expect(
      () => AuthSession.fromApiJson({'accessToken': 5}),
      throwsA(isA<TypeError>()),
    );
  });
}
