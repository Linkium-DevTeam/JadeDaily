import 'dart:math' as math;

/// 每日壁纸（来自 Bing 必应每日一图）。
class DailyWallpaper {
  final String imageUrl;
  final String title;
  final String copyright;

  /// 壁纸所属日期（来自 Bing 的 enddate，yyyyMMdd）。
  final DateTime? date;

  const DailyWallpaper({
    required this.imageUrl,
    required this.title,
    required this.copyright,
    this.date,
  });

  factory DailyWallpaper.fromBingJson(Map<String, dynamic> json) {
    final rawUrl = (json['url'] as String?) ?? '';
    final url = rawUrl.startsWith('http') ? rawUrl : 'https://www.bing.com$rawUrl';
    return DailyWallpaper(
      imageUrl: url,
      title: (json['title'] as String?) ?? '',
      copyright: (json['copyright'] as String?) ?? '',
      date: _parseDate(json['enddate'] as String?),
    );
  }

  /// 低分辨率缩略图，供回廊九宫格使用；无分辨率标记时退回原图。
  String get thumbnailUrl {
    const marker = '_1920x1080';
    if (!imageUrl.contains(marker)) return imageUrl;
    return imageUrl.replaceFirst(marker, '_640x360');
  }

  static DateTime? _parseDate(String? raw) {
    if (raw == null || raw.length != 8) return null;
    final y = int.tryParse(raw.substring(0, 4));
    final m = int.tryParse(raw.substring(4, 6));
    final d = int.tryParse(raw.substring(6, 8));
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }
}

/// 每日一句（一言 Hitokoto，离线时落到古诗文池）。
class DailyQuote {
  final String text;
  final String source;

  const DailyQuote(this.text, this.source);

  /// 断网时的雅集存货。
  static const List<DailyQuote> fallbacks = [
    DailyQuote('行到水穷处，坐看云起时。', '王维·终南别业'),
    DailyQuote('清风徐来，水波不兴。', '苏轼·赤壁赋'),
    DailyQuote('采菊东篱下，悠然见南山。', '陶渊明·饮酒'),
    DailyQuote('明月松间照，清泉石上流。', '王维·山居秋暝'),
    DailyQuote('落霞与孤鹜齐飞，秋水共长天一色。', '王勃·滕王阁序'),
    DailyQuote('疏影横斜水清浅，暗香浮动月黄昏。', '林逋·山园小梅'),
    DailyQuote('山中何事？松花酿酒，春水煎茶。', '张可久·人月圆'),
    DailyQuote('静水流深，大音希声。', '佚名'),
  ];

  static final math.Random _rng = math.Random();

  factory DailyQuote.fallback([math.Random? rng]) {
    final pool = fallbacks;
    return pool[(rng ?? _rng).nextInt(pool.length)];
  }
}
