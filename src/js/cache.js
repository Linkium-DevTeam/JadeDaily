// 壁纸磁盘缓存：appData/wallpapers/jade-wallpaper-YYYY-MM-DD.jpg
// 当天重启秒开、断网回退最近一张。

import { dateKey } from './logic.js';

const DIR = 'wallpapers';
const PREFIX = 'jade-wallpaper-';

const fs = () => globalThis.__TAURI__?.fs;
const appData = () => fs()?.BaseDirectory?.AppData;

function ready() {
  return Boolean(fs() && appData() !== undefined);
}

function blobUrl(bytes) {
  return URL.createObjectURL(new Blob([bytes], { type: 'image/jpeg' }));
}

function pathOf(day) {
  return `${DIR}/${PREFIX}${dateKey(day)}.jpg`;
}

/** 当日缓存命中返回 { url, path }，否则 null。 */
export async function loadWallpaper(day) {
  if (!ready()) return null;
  try {
    const bytes = await fs().readFile(pathOf(day), { baseDir: appData() });
    if (!bytes || bytes.length === 0) return null;
    return { url: blobUrl(bytes), path: pathOf(day) };
  } catch {
    return null;
  }
}

/** 落盘并返回缓存路径。 */
export async function saveWallpaper(day, bytes) {
  await fs().mkdir(DIR, { baseDir: appData(), recursive: true });
  await fs().writeFile(pathOf(day), bytes, { baseDir: appData() });
  return pathOf(day);
}

/** 从缓存文件读原始字节（珍藏壁纸用）。 */
export async function readBytes(path) {
  if (!ready()) return null;
  try {
    const bytes = await fs().readFile(path, { baseDir: appData() });
    return bytes?.length ? bytes : null;
  } catch {
    return null;
  }
}

/** 最近一张缓存（跨日断网兜底）。 */
export async function latestWallpaper() {
  if (!ready()) return null;
  try {
    const entries = await fs().readDir(DIR, { baseDir: appData() });
    const names = entries
      .map((e) => e.name)
      .filter((name) => name?.startsWith(PREFIX))
      .sort()
      .reverse();
    for (const name of names) {
      const bytes = await fs().readFile(`${DIR}/${name}`, { baseDir: appData() });
      if (bytes?.length) return { url: blobUrl(bytes), path: `${DIR}/${name}` };
    }
  } catch {
    // 无缓存
  }
  return null;
}
