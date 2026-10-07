// 纯函数层：汉字数字、时辰、天气文案、日期格式化。
// 不依赖 DOM 与 Tauri，可直接用 `node --test` 测试。

export const CN_NUMS = ['零', '一', '二', '三', '四', '五', '六', '七', '八', '九', '十'];

/** 0-99 的汉字数字，如 25 -> "二十五"。越界抛 RangeError。 */
export function numberToCn(n) {
  if (!Number.isInteger(n) || n < 0 || n > 99) throw new RangeError('仅支持 0-99');
  if (n <= 10) return CN_NUMS[n];
  const unit = CN_NUMS[n % 10];
  if (n < 20) return `十${n % 10 === 0 ? '' : unit}`;
  return `${CN_NUMS[Math.floor(n / 10)]}十${n % 10 === 0 ? '' : unit}`;
}

/** 时针文案：0 -> "零点"，21 -> "二十一点"。 */
export function hourText(hour) {
  if (!Number.isInteger(hour) || hour < 0 || hour > 23) throw new RangeError('hour 须为 0-23');
  return `${numberToCn(hour)}点`;
}

/** 分针文案：0 -> "整"，5 -> "零五分"。 */
export function minuteText(minute) {
  if (!Number.isInteger(minute) || minute < 0 || minute > 59) throw new RangeError('minute 须为 0-59');
  if (minute === 0) return '整';
  if (minute < 10) return `零${CN_NUMS[minute]}分`;
  return `${numberToCn(minute)}分`;
}

const SHICHEN = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];

/** 十二时辰：23-1 -> 子时 …… 21-23 -> 亥时。 */
export function shichenText(hour) {
  if (!Number.isInteger(hour) || hour < 0 || hour > 23) throw new RangeError('hour 须为 0-23');
  return `${SHICHEN[Math.floor(((hour + 1) / 2) % 12)]}时`;
}

export function isSameDay(a, b) {
  return (
    a.getFullYear() === b.getFullYear() &&
    a.getMonth() === b.getMonth() &&
    a.getDate() === b.getDate()
  );
}

export function dateKey(d) {
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${d.getFullYear()}-${m}-${day}`;
}

const WEEKDAYS = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];

/** "2026年10月07日 · 星期三" */
export function formatChineseDate(d) {
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${d.getFullYear()}年${m}月${day}日 · ${WEEKDAYS[d.getDay()]}`;
}

/** WMO 天气代码 -> 中文描述。 */
export function describeWmo(code) {
  if (code === 0) return '晴';
  if (code === 1) return '晴间少云';
  if (code === 2) return '局部多云';
  if (code === 3) return '阴';
  if (code === 45 || code === 48) return '雾';
  if (code >= 51 && code <= 57) return '毛毛雨';
  if (code >= 61 && code <= 67) return '雨';
  if (code >= 71 && code <= 77) return '雪';
  if (code >= 80 && code <= 82) return '阵雨';
  if (code === 85 || code === 86) return '阵雪';
  if (code >= 95) return '雷阵雨';
  return '多云';
}

/** Bing 原图地址 -> 回廊缩略图地址。 */
export function thumbnailUrl(url) {
  return url ? url.replace('_1920x1080', '_640x360') : url;
}

/** Bing enddate (yyyyMMdd) -> Date | null。 */
export function parseBingDate(raw) {
  if (!raw || raw.length !== 8) return null;
  const y = Number(raw.slice(0, 4));
  const m = Number(raw.slice(4, 6));
  const d = Number(raw.slice(6, 8));
  if (!y || !m || !d) return null;
  return new Date(y, m - 1, d);
}

/** 断网时的雅集存货。 */
export const QUOTE_FALLBACKS = [
  { text: '行到水穷处，坐看云起时。', source: '王维·终南别业' },
  { text: '清风徐来，水波不兴。', source: '苏轼·赤壁赋' },
  { text: '采菊东篱下，悠然见南山。', source: '陶渊明·饮酒' },
  { text: '明月松间照，清泉石上流。', source: '王维·山居秋暝' },
  { text: '落霞与孤鹜齐飞，秋水共长天一色。', source: '王勃·滕王阁序' },
  { text: '疏影横斜水清浅，暗香浮动月黄昏。', source: '林逋·山园小梅' },
  { text: '山中何事？松花酿酒，春水煎茶。', source: '张可久·人月圆' },
  { text: '静水流深，大音希声。', source: '佚名' },
];

export function randomFallbackQuote() {
  return QUOTE_FALLBACKS[Math.floor(Math.random() * QUOTE_FALLBACKS.length)];
}
