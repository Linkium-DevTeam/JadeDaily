import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:poster/services/weather_service.dart';

http.Client _mock({
  Object? geocodeBody,
  int geocodeStatus = 200,
  Object? forecastBody,
  int forecastStatus = 200,
  void Function(Uri)? onCapture,
}) {
  return MockClient((request) async {
    onCapture?.call(request.url);
    final isGeocode = request.url.host == 'geocoding-api.open-meteo.com';
    final body = isGeocode ? geocodeBody : forecastBody;
    final status = isGeocode ? geocodeStatus : forecastStatus;
    return http.Response.bytes(utf8.encode(jsonEncode(body)), status);
  });
}

void main() {
  test('地理编码 + 实况两步取数', () async {
    final client = _mock(
      geocodeBody: {
        'results': [
          {'name': '杭州市', 'latitude': 30.25, 'longitude': 120.17},
        ],
      },
      forecastBody: {
        'current': {'temperature_2m': 23.4, 'weather_code': 0},
      },
    );
    final weather = await WeatherService(client: client).fetchCurrent('杭州');
    expect(weather?.city, '杭州市');
    expect(weather?.description, '晴');
    expect(weather?.label, '晴 · 23°');
  });

  test('城市为空直接返回 null', () async {
    final client = _mock();
    expect(await WeatherService(client: client).fetchCurrent('  '), isNull);
  });

  test('地理编码无结果返回 null', () async {
    final client = _mock(geocodeBody: {'results': []});
    expect(await WeatherService(client: client).fetchCurrent('不存在的地方'), isNull);
  });

  test('地理编码失败返回 null', () async {
    final client = _mock(geocodeStatus: 500, geocodeBody: {});
    expect(await WeatherService(client: client).fetchCurrent('杭州'), isNull);
  });

  test('实况接口失败返回 null', () async {
    final client = _mock(
      geocodeBody: {
        'results': [
          {'name': '杭州', 'latitude': 30, 'longitude': 120},
        ],
      },
      forecastStatus: 500,
      forecastBody: {},
    );
    expect(await WeatherService(client: client).fetchCurrent('杭州'), isNull);
  });

  test('WMO 天气代码映射', () {
    expect(WeatherService.describeWmo(0), '晴');
    expect(WeatherService.describeWmo(3), '阴');
    expect(WeatherService.describeWmo(48), '雾');
    expect(WeatherService.describeWmo(63), '雨');
    expect(WeatherService.describeWmo(75), '雪');
    expect(WeatherService.describeWmo(81), '阵雨');
    expect(WeatherService.describeWmo(95), '雷阵雨');
    expect(WeatherService.describeWmo(33), '多云');
  });
}
