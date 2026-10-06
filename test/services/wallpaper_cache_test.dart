import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:poster/services/wallpaper_cache.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('jade_cache_test');
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  WallpaperCache cacheWith(Directory dir) =>
      WallpaperCache(resolveDir: () async => dir);

  test('空缓存：load/latest 均为 null', () async {
    final cache = cacheWith(tempDir);
    final day = DateTime(2026, 10, 7);
    expect(await cache.load(day), isNull);
    expect(await cache.latest(), isNull);
  });

  test('save 后当日 load 命中', () async {
    final cache = cacheWith(tempDir);
    final day = DateTime(2026, 10, 7);
    final file = await cache.save(day, Uint8List.fromList([9, 9, 9]));

    final path = await cache.load(day);
    expect(path, file.path);
    expect(await File(path!).readAsBytes(), [9, 9, 9]);
  });

  test('latest 返回最新（字典序最大）的一张', () async {
    final cache = cacheWith(tempDir);
    await cache.save(DateTime(2026, 10, 5), Uint8List.fromList([1]));
    await cache.save(DateTime(2026, 10, 7), Uint8List.fromList([2]));
    await cache.save(DateTime(2026, 10, 6), Uint8List.fromList([3]));

    final latest = await cache.latest();
    expect(latest, contains('2026-10-07'));
  });

  test('0 字节文件不视为有效缓存', () async {
    final cache = cacheWith(tempDir);
    final day = DateTime(2026, 10, 7);
    final file = await cache.save(day, Uint8List(0));
    // 手动清空再验证
    await file.writeAsBytes([], flush: true);
    expect(await cache.load(day), isNull);
  });
}
