// 管理本页面的数据与加载状态，不依赖展示组件。
import 'package:get/get.dart';

enum DemoStatus { loading, empty, error, success }

class StateDemoController extends GetxController {
  DemoStatus status = DemoStatus.empty;
  List<String> items = const [];

  Future<void> load(Future<List<String>> Function() fetch) async {
    if (isClosed || status == DemoStatus.loading) return;
    status = DemoStatus.loading;
    items = const [];
    update();
    try {
      final result = await fetch();
      if (isClosed) return;
      items = List.unmodifiable(result);
      status = items.isEmpty ? DemoStatus.empty : DemoStatus.success;
    } catch (_) {
      if (isClosed) return;
      status = DemoStatus.error;
    }
    update();
  }
}
