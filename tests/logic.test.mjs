// 纯逻辑单元测试：node --test tests/
import test from 'node:test';
import assert from 'node:assert/strict';

import {
  numberToCn,
  hourText,
  minuteText,
  shichenText,
  isSameDay,
  dateKey,
  formatChineseDate,
  describeWmo,
  thumbnailUrl,
  parseBingDate,
  randomFallbackQuote,
  QUOTE_FALLBACKS,
} from '../src/js/logic.js';
import { DEFAULTS, resolveDark } from '../src/js/store.js';

test('numberToCn 基础数字', () => {
  assert.equal(numberToCn(0), '零');
  assert.equal(numberToCn(5), '五');
  assert.equal(numberToCn(10), '十');
  assert.equal(numberToCn(11), '十一');
  assert.equal(numberToCn(19), '十九');
  assert.equal(numberToCn(20), '二十');
  assert.equal(numberToCn(25), '二十五');
  assert.equal(numberToCn(59), '五十九');
  assert.equal(numberToCn(99), '九十九');
  assert.throws(() => numberToCn(100), RangeError);
  assert.throws(() => numberToCn(-1), RangeError);
});

test('hourText / minuteText', () => {
  assert.equal(hourText(0), '零点');
  assert.equal(hourText(9), '九点');
  assert.equal(hourText(21), '二十一点');
  assert.throws(() => hourText(24), RangeError);
  assert.equal(minuteText(0), '整');
  assert.equal(minuteText(5), '零五分');
  assert.equal(minuteText(15), '十五分');
  assert.equal(minuteText(59), '五十九分');
  assert.throws(() => minuteText(60), RangeError);
});

test('shichenText 十二时辰边界', () => {
  assert.equal(shichenText(23), '子时');
  assert.equal(shichenText(0), '子时');
  assert.equal(shichenText(1), '丑时');
  assert.equal(shichenText(7), '辰时');
  assert.equal(shichenText(12), '午时');
  assert.equal(shichenText(22), '亥时');
});

test('日期工具', () => {
  const a = new Date(2026, 9, 7, 9, 8);
  const b = new Date(2026, 9, 7, 23, 59);
  const c = new Date(2026, 9, 8, 0, 1);
  assert.equal(isSameDay(a, b), true);
  assert.equal(isSameDay(a, c), false);
  assert.equal(dateKey(a), '2026-10-07');
  assert.equal(formatChineseDate(a), '2026年10月07日 · 星期三');
});

test('describeWmo 天气代码', () => {
  assert.equal(describeWmo(0), '晴');
  assert.equal(describeWmo(3), '阴');
  assert.equal(describeWmo(48), '雾');
  assert.equal(describeWmo(63), '雨');
  assert.equal(describeWmo(75), '雪');
  assert.equal(describeWmo(95), '雷阵雨');
  assert.equal(describeWmo(33), '多云');
});

test('thumbnailUrl 分辨率替换', () => {
  assert.equal(
    thumbnailUrl('https://www.bing.com/th?id=OHR.A_1920x1080.jpg'),
    'https://www.bing.com/th?id=OHR.A_640x360.jpg',
  );
  assert.equal(thumbnailUrl('https://x.com/a.jpg'), 'https://x.com/a.jpg');
  assert.equal(thumbnailUrl(undefined), undefined);
});

test('parseBingDate', () => {
  assert.deepEqual(parseBingDate('20261007'), new Date(2026, 9, 7));
  assert.equal(parseBingDate('bad'), null);
  assert.equal(parseBingDate(undefined), null);
});

test('兜底诗词池', () => {
  assert.ok(QUOTE_FALLBACKS.length >= 8);
  for (const q of QUOTE_FALLBACKS) {
    assert.ok(q.text.length > 0);
    assert.ok(q.source.length > 0);
  }
  assert.ok(QUOTE_FALLBACKS.includes(randomFallbackQuote()));
});

test('设置默认值与夜阑解析', () => {
  assert.equal(DEFAULTS.themeMode, 'auto');
  assert.equal(DEFAULTS.wallpaperDim, 0.25);
  assert.equal(DEFAULTS.quoteCategory, 'i');
  assert.equal(resolveDark({ themeMode: 'light' }, new Date(2026, 9, 7, 23)), false);
  assert.equal(resolveDark({ themeMode: 'dark' }, new Date(2026, 9, 7, 12)), true);
  assert.equal(resolveDark({ themeMode: 'auto' }, new Date(2026, 9, 7, 10)), false);
  assert.equal(resolveDark({ themeMode: 'auto' }, new Date(2026, 9, 7, 20)), true);
  assert.equal(resolveDark({ themeMode: 'auto' }, new Date(2026, 9, 7, 2)), true);
});
