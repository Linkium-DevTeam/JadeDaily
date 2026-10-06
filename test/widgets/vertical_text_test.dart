import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poster/widgets/vertical_text.dart';

void main() {
  Future<void> pumpText(WidgetTester tester, String text) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 400,
            child: VerticalText(
              text: text,
              fontSize: 20,
              color: const Color(0xFF222222),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('逐字竖排渲染', (tester) async {
    await pumpText(tester, '春眠不觉晓');
    expect(find.text('春'), findsOneWidget);
    expect(find.text('眠'), findsOneWidget);
    expect(find.text('晓'), findsOneWidget);
  });

  testWidgets('标点也参与排版', (tester) async {
    await pumpText(tester, '春风。');
    expect(find.text('春'), findsOneWidget);
    expect(find.text('。'), findsOneWidget);
  });

  testWidgets('超长文本不溢出（可滚动）', (tester) async {
    await pumpText(tester, '长' * 200);
    expect(tester.takeException(), isNull);
  });
}
