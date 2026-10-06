import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:poster/services/quote_service.dart';

void main() {
  test('正常解析一言', () async {
    final client = MockClient(
      (request) async => http.Response.bytes(
        utf8.encode(jsonEncode({'hitokoto': '春风又绿江南岸', 'from': '泊船瓜洲'})),
        200,
      ),
    );
    final quote = await QuoteService(client: client).fetch();
    expect(quote?.text, '春风又绿江南岸');
    expect(quote?.source, '泊船瓜洲');
  });

  test('from 为空时署名佚名', () async {
    final client = MockClient(
      (request) async => http.Response.bytes(
        utf8.encode(jsonEncode({'hitokoto': '静水流深', 'from': ''})),
        200,
      ),
    );
    final quote = await QuoteService(client: client).fetch();
    expect(quote?.source, '佚名');
  });

  test('HTTP 500 返回 null 不抛异常', () async {
    final client = MockClient((request) async => http.Response('err', 500));
    expect(await QuoteService(client: client).fetch(), isNull);
  });

  test('hitokoto 为空返回 null', () async {
    final client = MockClient(
      (request) async => http.Response(jsonEncode({'hitokoto': ''}), 200),
    );
    expect(await QuoteService(client: client).fetch(), isNull);
  });
}
