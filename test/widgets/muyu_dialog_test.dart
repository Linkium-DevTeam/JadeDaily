import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poster/services/muyu_service.dart';
import 'package:poster/services/settings_service.dart';
import 'package:poster/widgets/muyu_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('木鱼：敲击功德+1，上浮提示出现后消失', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final settings = SettingsService(await SharedPreferences.getInstance());
    // enabled=false 避免测试环境触碰音频插件通道
    final muyu = MuyuService(enabled: () => false);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () =>
                    showMuyuDialog(context, settings: settings, muyu: muyu),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('功德 0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.temple_buddhist));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('功德 1'), findsOneWidget);
    expect(find.text('功德 +1'), findsOneWidget);

    // 连击
    await tester.tap(find.byIcon(Icons.temple_buddhist));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('功德 2'), findsOneWidget);
    expect(find.text('功德 +1'), findsWidgets);

    await tester.pumpAndSettle();
    expect(find.text('功德 +1'), findsNothing);
  });
}
