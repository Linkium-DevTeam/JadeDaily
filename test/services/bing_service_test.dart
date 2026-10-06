import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:poster/services/bing_service.dart';

void main() {
  group('BingService.fetchToday', () {
    test('正常解析', () async {
      final client = MockClient((request) async => http.Response.bytes(
            utf8.encode(jsonEncode({
              'images': [
                {
                  'url': '/th?id=OHR.Test_ZH-CN123.jpg',
                  'title': '黄山云海',
                  'copyright': '黄山日出 (© Test)',
                }
              ],
            })),
            200,
          ));
      final wp = await BingService(client: client).fetchToday();
      expect(wp?.title, '黄山云海');
      expect(wp?.imageUrl, 'https://www.bing.com/th?id=OHR.Test_ZH-CN123.jpg');
    });

    test('HTTP 500 返回 null 不抛异常', () async {
      final client = MockClient((request) async => http.Response('err', 500));
      expect(await BingService(client: client).fetchToday(), isNull);
    });

    test('响应体损坏返回 null', () async {
      final client =
          MockClient((request) async => http.Response('not json', 200));
      expect(await BingService(client: client).fetchToday(), isNull);
    });

    test('images 为空返回 null', () async {
      final client =
          MockClient((request) async => http.Response('{"images": []}', 200));
      expect(await BingService(client: client).fetchToday(), isNull);
    });
  });

  group('BingService.fetchRecent', () {
    test('解析多日壁纸并写入 n 参数', () async {
      Uri? captured;
      final client = MockClient((request) async {
        captured = request.url;
        return http.Response.bytes(
          utf8.encode(jsonEncode({
            'images': [
              {
                'url': '/th?id=OHR.A_1920x1080.jpg',
                'title': '今日之景',
                'enddate': '20261007',
              },
              {
                'url': 'https://www.bing.com/th?id=OHR.B_1920x1080.jpg',
                'title': '昨日之景',
                'enddate': '20261006',
              },
            ],
          })),
          200,
        );
      });
      final items = await BingService(client: client).fetchRecent(count: 8);
      expect(captured!.queryParameters['n'], '8');
      expect(items.length, 2);
      expect(items[0].date, DateTime(2026, 10, 7));
      expect(items[0].thumbnailUrl, contains('_640x360'));
      expect(items[1].thumbnailUrl, contains('_640x360'));
    });

    test('失败返回空列表', () async {
      final client = MockClient((request) async => http.Response('err', 500));
      expect(await BingService(client: client).fetchRecent(), isEmpty);
    });
  });

  group('BingService.downloadImage', () {
    test('200 返回字节', () async {
      final client = MockClient(
        (request) async => http.Response.bytes(
          Uint8List.fromList([1, 2, 3]),
          200,
        ),
      );
      final bytes = await BingService(client: client).downloadImage('https://x/a.jpg');
      expect(bytes, [1, 2, 3]);
    });

    test('持续失败返回 null 且不抛异常', () async {
      final client =
          MockClient((request) async => http.Response('nope', 404));
      final bytes =
          await BingService(client: client).downloadImage('https://x/a.jpg');
      expect(bytes, isNull);
    });
  });
}
