// 设置存储：localStorage 持久化 + 订阅通知。

const KEY = 'jade-settings-v1';

export const DEFAULTS = {
  wallpaperDim: 0.25,
  showPoetry: true,
  startFullscreen: false,
  themeMode: 'auto', // light | dark | auto
  quoteCategory: 'i', // '' 随机 / i 诗词 / c 文学 / k 哲学
  weatherCity: '',
  launchAtStartup: false,
  muyuMerit: 0,
};

let cached = null;
const listeners = new Set();

function read() {
  try {
    const raw = JSON.parse(localStorage.getItem(KEY) ?? '{}');
    return { ...DEFAULTS, ...raw };
  } catch {
    return { ...DEFAULTS };
  }
}

export function getSettings() {
  return (cached ??= read());
}

export function updateSettings(patch) {
  cached = { ...getSettings(), ...patch };
  try {
    localStorage.setItem(KEY, JSON.stringify(cached));
  } catch {
    // 隐私模式下写不进去也不致命
  }
  listeners.forEach((fn) => fn(cached));
  return cached;
}

export function subscribe(fn) {
  listeners.add(fn);
  return () => listeners.delete(fn);
}

/** 主题模式 -> 是否夜阑（auto 按 19:00-06:00）。 */
export function resolveDark(settings, now = new Date()) {
  if (settings.themeMode === 'dark') return true;
  if (settings.themeMode === 'light') return false;
  const h = now.getHours();
  return h >= 19 || h < 6;
}
