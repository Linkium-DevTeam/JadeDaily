import 'package:flutter_test/flutter_test.dart';
import 'package:poster/models/daily_content.dart';

void main() {
  group('DailyWallpaper.fromBingJson', () {
    test('相对路径自动补全域名', () {
      final wp = DailyWallpaper.fromBingJson({
        'url': '/th?id=OHR.Test_ZH-CN1234567.jpg',
        'title': '西湖晨雾',
        'copyright': '杭州西湖 (© Someone/Getty)',
      });
      expect(
        wp.imageUrl,
        'https://www.bing.com/th?id=OHR.Test_ZH-CN1234567.jpg',
      );
      expect(wp.title, '西湖晨雾');
      expect(wp.copyright, '杭州西湖 (© Someone/Getty)');
    });

    test('绝对地址原样保留', () {
      final wp = DailyWallpaper.fromBingJson({
        'url': 'https://example.com/a.jpg',
      });
      expect(wp.imageUrl, 'https://example.com/a.jpg');
    });

  test('字段缺失时兜底为空串', () {
    final wp = DailyWallpaper.fromBingJson({});
    expect(wp.imageUrl, 'https://www.bing.com');
    expect(wp.title, '');
    expect(wp.copyright, '');
    expect(wp.date, isNull);
  });

  test('enddate 解析为日期，非法值安全为 null', () {
    expect(
      DailyWallpaper.fromBingJson({'url': '/a', 'enddate': '20261007'}).date,
      DateTime(2026, 10, 7),
    );
    expect(
      DailyWallpaper.fromBingJson({'url': '/a', 'enddate': 'bad'}).date,
      isNull,
    );
  });

  test('缩略图地址替换分辨率，无标记时原样返回', () {
    expect(
      DailyWallpaper.fromBingJson({
        'url': '/th?id=OHR.A_1920x1080.jpg',
      }).thumbnailUrl,
      contains('_640x360'),
    );
    expect(
      DailyWallpaper.fromBingJson({'url': 'https://x.com/a.jpg'}).thumbnailUrl,
      'https://x.com/a.jpg',
    );
  });
  });

  group('DailyQuote.fallback', () {
    test('兜底池非空且字段完整', () {
      for (final q in DailyQuote.fallbacks) {
        expect(q.text, isNotEmpty);
        expect(q.source, isNotEmpty);
      }
    });

    test('随机兜底总在池内', () {
      for (var i = 0; i < 20; i++) {
        expect(DailyQuote.fallbacks, contains(DailyQuote.fallback()));
      }
    });
  });
}
