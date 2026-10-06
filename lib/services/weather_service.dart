import 'dart:convert';

import 'package:http/http.dart' as http;

/// 天气数据（Open-Meteo，免密钥）。
class Weather {
  final String city;
  final double temperature;
  final String description;

  const Weather({
    required this.city,
    required this.temperature,
    required this.description,
  });

  String get label => '$description · ${temperature.round()}°';
}

/// Open-Meteo 天气服务：先城市名地理编码，再取当前实况。
class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// 拉取城市当前天气；任一步失败返回 null（调用方静默降级）。
  Future<Weather?> fetchCurrent(
    String city, {
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final trimmed = city.trim();
    if (trimmed.isEmpty) return null;
    try {
      final geoUri = Uri.https(
        'geocoding-api.open-meteo.com',
        '/v1/search',
        {'name': trimmed, 'count': '1', 'language': 'zh', 'format': 'json'},
      );
      final geoRes = await _client.get(geoUri).timeout(timeout);
      if (geoRes.statusCode != 200) return null;
      final geo = jsonDecode(utf8.decode(geoRes.bodyBytes)) as Map<String, dynamic>;
      final results = geo['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) return null;
      final place = results.first as Map<String, dynamic>;
      final name = (place['name'] as String?) ?? trimmed;
      final lat = place['latitude'];
      final lon = place['longitude'];
      if (lat is! num || lon is! num) return null;

      final fcUri = Uri.https(
        'api.open-meteo.com',
        '/v1/forecast',
        {
          'latitude': lat.toString(),
          'longitude': lon.toString(),
          'current': 'temperature_2m,weather_code',
          'timezone': 'auto',
        },
      );
      final fcRes = await _client.get(fcUri).timeout(timeout);
      if (fcRes.statusCode != 200) return null;
      final fc = jsonDecode(utf8.decode(fcRes.bodyBytes)) as Map<String, dynamic>;
      final current = fc['current'] as Map<String, dynamic>?;
      final temp = current?['temperature_2m'];
      final code = current?['weather_code'];
      if (temp is! num || code is! int) return null;
      return Weather(
        city: name,
        temperature: temp.toDouble(),
        description: describeWmo(code),
      );
    } catch (_) {
      return null;
    }
  }

  /// WMO 天气代码 -> 中文描述。
  static String describeWmo(int code) {
    if (code == 0) return '晴';
    if (code == 1) return '晴间少云';
    if (code == 2) return '局部多云';
    if (code == 3) return '阴';
    if (code == 45 || code == 48) return '雾';
    if (code >= 51 && code <= 57) return '毛毛雨';
    if (code >= 61 && code <= 67) return '雨';
    if (code >= 71 && code <= 77) return '雪';
    if (code >= 80 && code <= 82) return '阵雨';
    if (code == 85 || code == 86) return '阵雪';
    if (code >= 95) return '雷阵雨';
    return '多云';
  }

  void close() => _client.close();
}
