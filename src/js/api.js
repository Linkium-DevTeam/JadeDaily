// 网络层：全部经 Tauri http 插件发出（无 CORS 限制）。
// 任何失败一律返回 null / 空数组，由调用方兜底，绝不抛出。

import { dateKey, describeWmo, parseBingDate } from './logic.js';

const tauri = () => globalThis.__TAURI__;

// connectTimeout 单位为毫秒（tauri-plugin-http: Duration::from_millis）
async function tauriGet(url, connectTimeout = 8000) {
  const http = tauri()?.http;
  if (!http) return null;
  try {
    const res = await http.fetch(url, { method: 'GET', connectTimeout });
    return res?.ok ? res : null;
  } catch {
    return null;
  }
}

/** 最近 n 天必应壁纸元信息，按日期从新到旧。 */
export async function fetchBingRecent(count = 8) {
  const res = await tauriGet(
    `https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=${count}&mkt=zh-CN`,
    10000,
  );
  if (!res) return [];
  try {
    const data = await res.json();
    if (!Array.isArray(data?.images)) return [];
    return data.images
      .map((img) => ({
        imageUrl: img.url?.startsWith('http')
          ? img.url
          : `https://www.bing.com${img.url ?? ''}`,
        title: img.title ?? '',
        copyright: img.copyright ?? '',
        date: parseBingDate(img.enddate),
      }))
      .filter((w) => w.imageUrl !== 'https://www.bing.com');
  } catch {
    return [];
  }
}

export async function fetchBingToday() {
  const [today] = await fetchBingRecent(1);
  return today ?? null;
}

/** 一言；category 传 Hitokoto 分类 code，空串 = 随机。 */
export async function fetchQuote(category) {
  const query = category ? `?c=${encodeURIComponent(category)}` : '';
  const res = await tauriGet(`https://v1.hitokoto.cn/${query}`, 6000);
  if (!res) return null;
  try {
    const data = await res.json();
    if (!data?.hitokoto) return null;
    return { text: data.hitokoto, source: data.from || '佚名' };
  } catch {
    return null;
  }
}

/** Open-Meteo 天气：地理编码 + 实况两步。 */
export async function fetchWeather(city) {
  const name = (city ?? '').trim();
  if (!name) return null;
  try {
    const geoRes = await tauriGet(
      `https://geocoding-api.open-meteo.com/v1/search?name=${encodeURIComponent(name)}&count=1&language=zh&format=json`,
    );
    if (!geoRes) return null;
    const geo = await geoRes.json();
    const place = geo?.results?.[0];
    if (!place || typeof place.latitude !== 'number') return null;

    const fcRes = await tauriGet(
      `https://api.open-meteo.com/v1/forecast?latitude=${place.latitude}&longitude=${place.longitude}&current=temperature_2m,weather_code&timezone=auto`,
    );
    if (!fcRes) return null;
    const fc = await fcRes.json();
    const cur = fc?.current;
    if (typeof cur?.temperature_2m !== 'number' || typeof cur?.weather_code !== 'number') {
      return null;
    }
    return {
      city: place.name ?? name,
      label: `${describeWmo(cur.weather_code)} · ${Math.round(cur.temperature_2m)}°`,
    };
  } catch {
    return null;
  }
}

/** 下载壁纸原图字节；失败重试一次。 */
export async function downloadBytes(url, connectTimeout = 20000) {
  for (let attempt = 0; attempt < 2; attempt++) {
    const res = await tauriGet(url, connectTimeout);
    if (res) {
      try {
        const buf = await res.arrayBuffer();
        if (buf.byteLength > 0) return new Uint8Array(buf);
      } catch {
        // 重试
      }
    }
  }
  return null;
}

export { dateKey };
