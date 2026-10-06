import 'package:flutter_test/flutter_test.dart';
import 'package:poster/services/lunar_service.dart';

void main() {
  test('2026 春节：丙午马年正月初一', () {
    final info = LunarService.infoFor(DateTime(2026, 2, 17));
    expect(info.ganzhiYear, '丙午');
    expect(info.zodiac, '马');
    expect(info.monthName, '正');
    expect(info.dayName, '初一');
    expect(info.label, contains('丙午年马'));
    expect(info.label, contains('农历正月初一'));
  });

  test('普通日期：2026-10-07 为八月廿七', () {
    final info = LunarService.infoFor(DateTime(2026, 10, 7));
    expect(info.ganzhiYear, '丙午');
    expect(info.monthName, '八');
    expect(info.dayName, '廿七');
  });

  test('跨年回退：2025-06-23 为乙巳蛇年', () {
    final info = LunarService.infoFor(DateTime(2025, 6, 23));
    expect(info.ganzhiYear, '乙巳');
    expect(info.zodiac, '蛇');
  });

  test('同日多次取用命中缓存（同一实例）', () {
    final a = LunarService.infoFor(DateTime(2026, 10, 7));
    final b = LunarService.infoFor(DateTime(2026, 10, 7));
    expect(identical(a, b), isTrue);
  });
}
