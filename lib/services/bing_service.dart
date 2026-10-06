import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/daily_content.dart';

/// 必应每日一图 API。
class BingService {
  BingService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _endpoint =
      'https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=zh-CN';

  /// 拉取今日壁纸元信息；网络或解析失败返回 null（不抛异常，由调用方兜底）。
  Future<DailyWallpaper?> fetchToday({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    try {
      final res = await _client
          .get(Uri.parse(_endpoint))
          .timeout(timeout);
      if (res.statusCode != 200) return null;
      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final images = data['images'] as List<dynamic>?;
      if (images == null || images.isEmpty) return null;
      return DailyWallpaper.fromBingJson(
        images.first as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
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
