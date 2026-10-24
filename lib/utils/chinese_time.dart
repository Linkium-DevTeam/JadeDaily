/// 汉字数字与时辰换算。
library;

const List<String> _cnNums = [
  '零', '一', '二', '三', '四', '五', '六', '七', '八', '九', '十',
];

const List<String> _shichenNames = [
  '子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥',
];

/// 0-99 的汉字数字，如 25 -> "二十五"。超出范围抛 ArgumentError。
String numberToChinese(int n) {
  if (n < 0 || n > 99) throw ArgumentError.value(n, 'n', '仅支持 0-99');
  if (n <= 10) return _cnNums[n];
  if (n < 20) return '十${n % 10 == 0 ? '' : _cnNums[n % 10]}';
  return '${_cnNums[n ~/ 10]}十${n % 10 == 0 ? '' : _cnNums[n % 10]}';
}

/// 时针文案：0 -> "零点"，9 -> "九点"，21 -> "二十一点"。
String hourText(int hour) {
  if (hour < 0 || hour > 23) throw ArgumentError.value(hour, 'hour');
  return '${numberToChinese(hour)}点';
}

/// 分针文案：0 -> "整"，5 -> "零五分"，30 -> "三十分"。
String minuteText(int minute) {
  if (minute < 0 || minute > 59) throw ArgumentError.value(minute, 'minute');
  if (minute == 0) return '整';
  if (minute < 10) return '零${_cnNums[minute]}分';
  return '${numberToChinese(minute)}分';
}

/// 十二时辰：23-1 -> 子时，1-3 -> 丑时…… 21-23 -> 亥时。
String shichenText(int hour) {
  if (hour < 0 || hour > 23) throw ArgumentError.value(hour, 'hour');
  return '${_shichenNames[((hour + 1) ~/ 2) % 12]}时';
}
