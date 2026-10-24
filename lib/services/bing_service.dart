import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/daily_content.dart';

/// 必应每日一图 API。
class BingService {
  BingService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// 拉取最近 [count] 天的壁纸元信息（回廊用），按日期从新到旧。
  Future<DailyWallpaper?> fetchToday({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final list = await fetchRecent(count: 1, timeout: timeout);
    return list.isEmpty ? null : list.first;
  }

  /// 拉取最近 [count] 天的壁纸元信息（回廊用），按日期从新到旧。
  Future<List<DailyWallpaper>> fetchRecent({
    int count = 8,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    try {
      final uri = Uri.https('www.bing.com', '/HPImageArchive.aspx', {
        'format': 'js',
        'idx': '0',
        'n': '$count',
        'mkt': 'zh-CN',
      });
      final res = await _client.get(uri).timeout(timeout);
      if (res.statusCode != 200) return const [];
      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final images = data['images'] as List<dynamic>?;
      if (images == null) return const [];
      return images
          .whereType<Map<String, dynamic>>()
          .map(DailyWallpaper.fromBingJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// 下载壁纸原图，失败自动重试一次；仍失败返回 null。
  Future<Uint8List?> downloadImage(
    String url, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final res = await _client.get(Uri.parse(url)).timeout(timeout);
        if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
          return res.bodyBytes;
        }
      } catch (_) {
        // 重试一次再放弃。
      }
    }
    return null;
  }

  void close() => _client.close();
}
