import 'package:flutter_test/flutter_test.dart';
import 'package:poster/utils/chinese_time.dart';

void main() {
  group('numberToChinese', () {
    test('基础数字', () {
      expect(numberToChinese(0), '零');
      expect(numberToChinese(5), '五');
      expect(numberToChinese(10), '十');
      expect(numberToChinese(11), '十一');
      expect(numberToChinese(19), '十九');
      expect(numberToChinese(20), '二十');
      expect(numberToChinese(25), '二十五');
      expect(numberToChinese(59), '五十九');
      expect(numberToChinese(99), '九十九');
    });

    test('越界抛 ArgumentError', () {
      expect(() => numberToChinese(-1), throwsArgumentError);
      expect(() => numberToChinese(100), throwsArgumentError);
    });
  });

  group('hourText', () {
    test('零点到二十三点', () {
      expect(hourText(0), '零点');
      expect(hourText(9), '九点');
      expect(hourText(13), '十三点');
      expect(hourText(21), '二十一点');
      expect(hourText(23), '二十三点');
      expect(() => hourText(24), throwsArgumentError);
    });
  });

  group('minuteText', () {
    test('整点与带零前缀', () {
      expect(minuteText(0), '整');
      expect(minuteText(5), '零五分');
      expect(minuteText(15), '十五分');
      expect(minuteText(30), '三十分');
      expect(minuteText(59), '五十九分');
      expect(() => minuteText(60), throwsArgumentError);
    });
  });

  group('shichenText 十二时辰', () {
    test('边界正确', () {
      expect(shichenText(23), '子时');
      expect(shichenText(0), '子时');
      expect(shichenText(1), '丑时');
      expect(shichenText(3), '寅时');
      expect(shichenText(7), '辰时');
      expect(shichenText(9), '巳时');
      expect(shichenText(12), '午时');
      expect(shichenText(15), '申时');
      expect(shichenText(18), '酉时');
      expect(shichenText(22), '亥时');
    });
  });
}
