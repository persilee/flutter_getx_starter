// 用受控数据验证表单校验与控制器归属。

import 'package:flutter/material.dart';
import 'package:flutter_getx_starter/common/widgets/form/input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('表单验证并保留外部输入控制器', (tester) async {
    final controller = TextEditingController();
    final form = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: form,
            child: InputFormFieldWidget(
              labelText: 'name',
              controller: controller,
              validator: (value) => value!.isEmpty ? 'required' : null,
            ),
          ),
        ),
      ),
    );
    expect(form.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('required'), findsOneWidget);
    controller.text = 'ready';
    expect(form.currentState!.validate(), isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.text = 'still usable';
    expect(controller.text, 'still usable');
    controller.dispose();
  });
}
