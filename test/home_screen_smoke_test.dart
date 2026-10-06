import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:poster/screens/home_screen.dart';
import 'package:poster/services/bing_service.dart';
import 'package:poster/services/clock_service.dart';
import 'package:poster/services/quote_service.dart';
import 'package:poster/services/settings_service.dart';
import 'package:poster/services/wallpaper_cache.dart';
import 'package:poster/widgets/poetry_scroll.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 内存版缓存桩：widget 测试跑在 fake async 里，真实文件 IO 永远不会完成。
class _MemoryCache extends WallpaperCache {
  _MemoryCache() : super(resolveDir: () async => Directory.systemTemp);

  @override
  Future<String?> load(DateTime day) async => null;

  @override
  Future<File> save(DateTime day, Uint8List bytes) async => File('unused');

  @override
  Future<String?> latest() async => null;
}

void main() {
  setUpAll(() async {
    // 测试环境禁止 google_fonts 联网取字体，直接走本地回退。
    GoogleFonts.config.allowRuntimeFetching = false;
    await initializeDateFormatting('zh_CN', null);
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('离线兜底：无网络时正常渲染时钟玉牌与古诗词兜底', (tester) async {
    final failing = MockClient((request) async => http.Response('err', 500));
    final clock = ClockService(source: () => DateTime(2026, 10, 7, 9, 8));
    final settings = SettingsService(await SharedPreferences.getInstance());

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          settings: settings,
          clock: clock,
          bing: BingService(client: failing),
          quotes: QuoteService(client: failing),
          cache: _MemoryCache(),
        ),
      ),
    );

    // 内存桩下数据秒达，直接进入最终状态
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('九点'), findsOneWidget);
    expect(find.text('零八分'), findsOneWidget);
    expect(find.text('巳时'), findsOneWidget);
    expect(find.text('凝脂画报'), findsOneWidget);
    expect(find.text('离线雅坐 · 暂无网络，且赏旧时景。'), findsOneWidget);
    expect(find.text('雅趣'), findsOneWidget);
    expect(find.byType(PoetryScroll), findsOneWidget);
  });

  testWidgets('设置面板：关闭诗词玉简后右侧玉简隐藏', (tester) async {
    final quoteOk = MockClient(
      (request) async =>
          http.Response(jsonEncode({'hitokoto': '测试一句', 'from': '测试'}), 200),
    );
    final failing = MockClient((request) async => http.Response('err', 500));
    final clock = ClockService(source: () => DateTime(2026, 10, 7, 9, 8));
    final settings = SettingsService(await SharedPreferences.getInstance());

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          settings: settings,
          clock: clock,
          bing: BingService(client: failing),
          quotes: QuoteService(client: quoteOk),
          cache: _MemoryCache(),
        ),
      ),
    );
    // 单次 pump 推进 1 秒：内存桩下数据已就绪，直接断言最终状态
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(PoetryScroll), findsOneWidget);

    await tester.tap(find.byTooltip('雅设'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('诗词玉简'));
    await tester.pumpAndSettle();
    expect(find.byType(PoetryScroll), findsNothing);

    // 点击遮罩关闭面板
    await tester.tapAt(const Offset(30, 30));
    await tester.pumpAndSettle();
  });
}
