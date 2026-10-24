import 'package:lunar/lunar.dart';

/// 农历信息（干支年、生肖、农历月日）。
class LunarInfo {
  final String ganzhiYear;
  final String zodiac;
  final String monthName;
  final String dayName;

  const LunarInfo({
    required this.ganzhiYear,
    required this.zodiac,
    required this.monthName,
    required this.dayName,
  });

  /// 如「丙午年马 · 农历八月初三」。
  String get label => '$ganzhiYear年$zodiac · 农历$monthName月$dayName';
}

/// 农历换算（基于 lunar 包），按日缓存，供每秒重建的时钟牌取用。
abstract final class LunarService {
  static final Map<String, LunarInfo> _cache = {};

  static LunarInfo infoFor(DateTime day) {
    final key = '${day.year}-${day.month}-${day.day}';
    return _cache.putIfAbsent(key, () {
      final lunar = Solar.fromDate(day).getLunar();
      return LunarInfo(
        ganzhiYear: lunar.getYearInGanZhi(),
        zodiac: lunar.getYearShengXiao(),
        monthName: lunar.getMonthInChinese(),
        dayName: lunar.getDayInChinese(),
      );
    });
  }
}
