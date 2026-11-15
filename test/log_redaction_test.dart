// 用受控数据验证日志脱敏。

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_getx_starter/common/index.dart';

import 'fake_adapter.dart';

// 用内存列表接收 Logger 输出，断言日志中不再出现原始敏感值。
class CaptureOutput extends LogOutput {
  final lines = <String>[];
  @override
  void output(OutputEvent event) => lines.addAll(event.lines);
}

class AlwaysLog extends LogFilter {
  @override
  // 测试中强制允许日志，避免运行模式的过滤规则使脱敏断言没有实际输入。
  bool shouldLog(LogEvent event) => true;
}

void main() {
  test('嵌套日志与Bearer脱敏', () async {
    final output = CaptureOutput();
    final logger = Logger(
      output: output,
      filter: AlwaysLog(),
      printer: SimplePrinter(),
    );
    final dio = Dio(BaseOptions(baseUrl: 'https://controlled.test'));
    dio.httpClientAdapter = FakeAdapter(
      (_) async => jsonResponse({'accessToken': 'secret-response'}),
    );
    dio.interceptors.add(LoggingInterceptor(logger: logger));
    await dio.post(
      '/items',
      data: {
        'nested': {'refreshToken': 'secret-refresh'},
      },
      options: Options(headers: {'Authorization': 'Bearer secret-header'}),
    );
    // 合并全部日志检查：既要出现遮蔽标识，也要确保请求头、嵌套字段和响应中的秘密消失。
    final text = output.lines.join('\n');
    expect(text, contains('<redacted>'));
    expect(text, isNot(contains('secret-response')));
    expect(text, isNot(contains('secret-refresh')));
    expect(text, isNot(contains('secret-header')));
  });
}
