import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/daily_content.dart';

/// 一言 Hitokoto API（诗词 / 文学分类）。
class QuoteService {
  QuoteService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _endpoint = 'https://v1.hitokoto.cn/?c=i&c=d';

  /// 拉取每日一句；失败返回 null，由调用方落到古诗文兜底池。
  Future<DailyQuote?> fetch({
    Duration timeout = const Duration(seconds: 6),
  }) async {
    try {
      final res = await _client
          .get(Uri.parse(_endpoint))
          .timeout(timeout);
      if (res.statusCode != 200) return null;
      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final text = data['hitokoto'] as String?;
      if (text == null || text.isEmpty) return null;
      final source = (data['from'] as String?) ?? '';
      return DailyQuote(text, source.isEmpty ? '佚名' : source);
    } catch (_) {
      return null;
    }
  }

  void close() => _client.close();
}
