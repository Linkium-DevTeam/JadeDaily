// 主编排：时钟心跳、壁纸管线、诗词、天气、回廊、木鱼、设置与窗口控制。

import * as logic from './logic.js';
import { getSettings, updateSettings, subscribe, resolveDark } from './store.js';
import * as api from './api.js';
import * as cache from './cache.js';
import { knock as muyuKnock } from './muyu.js';

const tauri = () => globalThis.__TAURI__;
const invoke = (cmd, args) => tauri()?.core?.invoke(cmd, args);
const winApi = () => tauri()?.window;
const autostartApi = () => tauri()?.autostart;
const dialogApi = () => tauri()?.dialog;
const fsApi = () => tauri()?.fs;
const appData = () => fsApi()?.BaseDirectory?.AppData;

const $ = (id) => document.getElementById(id);
const els = {};

// ---- 状态 ----
let loadedDate = new Date(0);
let currentMeta = null;
let currentCachePath = null;
let currentBlobUrl = null;
let currentBytes = null;
let offline = true;
let weatherInfo = null;
let lastWeatherAt = 0;
let weatherLoading = false;
let isFullscreen = false;
const lunarCache = new Map();
let toastTimer = 0;

// ---- 启动 ----
async function boot() {
  for (const id of [
    'wallpaper', 'veil', 'loading', 'ui', 'dateText', 'shichenSeal', 'lunarText',
    'hourText', 'minuteText', 'wallTitle', 'wallStory', 'weatherRow', 'weatherText',
    'poetry', 'quoteSource', 'quoteText', 'btnMin', 'btnFull', 'btnClose',
    'btnRefresh', 'btnGallery', 'btnMuyu', 'btnSave', 'btnSettings',
    'settingsDialog', 'galleryDialog', 'muyuDialog', 'galleryGrid',
    'galleryClose', 'muyuClose', 'muyuPad', 'muyuStage', 'meritText',
    'themeSeg', 'dimRange', 'dimVal', 'showPoetry', 'startFullscreen',
    'quoteCategory', 'cityInput', 'autostart', 'toast',
  ]) {
    els[id] = $(id);
  }

  bindUI();
  applyTheme();
  applyPoetryVisibility();

  if (getSettings().startFullscreen) {
    try {
      await winApi()?.getCurrentWindow()?.setFullscreen(true);
      isFullscreen = true;
      document.body.classList.toggle('fullscreen', isFullscreen);
    } catch {
      // 忽略
    }
  }

  refreshClock();
  setInterval(tick, 1000);
  await loadWallpaperFlow();
  await refreshQuote();
  await refreshWeather(true);
  els.loading.hidden = true;
  els.ui.hidden = false;
}

// ---- 心跳 ----
function tick() {
  const now = new Date();
  refreshClock(now);
  applyTheme();

  if (!logic.isSameDay(now, loadedDate) && loadedDate.getTime() !== 0) {
    loadWallpaperFlow();
    return;
  }
  const city = getSettings().weatherCity;
  if (
    !weatherLoading &&
    city &&
    Date.now() - lastWeatherAt > 30 * 60 * 1000
  ) {
    refreshWeather();
  }
}

function refreshClock(now = new Date()) {
  els.dateText.textContent = logic.formatChineseDate(now);
  els.shichenSeal.textContent = logic.shichenText(now.getHours());
  els.hourText.textContent = logic.hourText(now.getHours());
  els.minuteText.textContent = logic.minuteText(now.getMinutes());
  renderLunar(now);
}

async function renderLunar(now) {
  const key = logic.dateKey(now);
  if (!lunarCache.has(key)) {
    lunarCache.set(key, ''); // 占位，避免重复请求
    try {
      const info = await invoke('lunar_info', {
        year: now.getFullYear(),
        month: now.getMonth() + 1,
        day: now.getDate(),
      });
      lunarCache.set(key, `${info.ganzhi}年${info.zodiac} · 农历${info.month}${info.day}`);
    } catch {
      lunarCache.set(key, '');
    }
  }
  els.lunarText.textContent = lunarCache.get(key);
}

// ---- 主题 ----
function applyTheme() {
  const dark = resolveDark(getSettings());
  document.documentElement.dataset.theme = dark ? 'dark' : 'light';
}

function applyPoetryVisibility() {
  document.body.classList.toggle('no-poetry', !getSettings().showPoetry);
}

// ---- 壁纸管线 ----
async function loadWallpaperFlow({ force = false } = {}) {
  const today = new Date();
  let entry = force ? null : await cache.loadWallpaper(today);
  const meta = await api.fetchBingToday();

  if (meta && !entry) {
    const bytes = await api.downloadBytes(meta.imageUrl);
    if (bytes) {
      try {
        const path = await cache.saveWallpaper(today, bytes);
        entry = await cache.loadWallpaper(today) ?? { url: bytesToUrl(bytes), path };
      } catch {
        entry = { url: bytesToUrl(bytes), path: null };
      }
      currentBytes = bytes;
    }
  }
  if (!meta && !entry) {
    entry = await cache.latestWallpaper();
  }

  loadedDate = today;
  applyWallpaper(entry, meta);
}

function applyWallpaper(entry, meta) {
  currentMeta = meta ?? currentMeta;
  currentCachePath = entry?.path ?? currentCachePath;
  if (meta) {
    els.wallTitle.textContent = meta.title || '凝脂画报';
    els.wallStory.textContent = meta.copyright.split(' (')[0] ?? '';
  }
  setWallpaperSrc(entry?.url ?? meta?.imageUrl ?? null);
}

function setWallpaperSrc(url) {
  if (currentBlobUrl?.startsWith('blob:') && currentBlobUrl !== url) {
    URL.revokeObjectURL(currentBlobUrl);
  }
  currentBlobUrl = url?.startsWith('blob:') ? url : currentBlobUrl;
  if (!url) {
    els.wallpaper.classList.remove('ready');
    return;
  }
  els.wallpaper.onload = () => els.wallpaper.classList.add('ready');
  els.wallpaper.src = url;
}

function bytesToUrl(bytes) {
  currentBytes = bytes;
  return URL.createObjectURL(new Blob([bytes], { type: 'image/jpeg' }));
}

// ---- 诗词 ----
async function refreshQuote() {
  const quote = await api.fetchQuote(getSettings().quoteCategory);
  offline = quote === null && currentMeta === null;
  const q = quote ?? logic.randomFallbackQuote();
  els.quoteText.textContent = q.text;
  els.quoteSource.textContent = q.source;
}

// ---- 天气 ----
async function refreshWeather(initial = false) {
  const city = getSettings().weatherCity;
  if (!city) {
    weatherInfo = null;
    els.weatherRow.hidden = true;
    return;
  }
  if (weatherLoading) return;
  weatherLoading = true;
  const info = await api.fetchWeather(city);
  weatherLoading = false;
  lastWeatherAt = Date.now();
  if (info) weatherInfo = info;
  if (initial && !info) return; // 启动时失败就静默
  els.weatherRow.hidden = !weatherInfo;
  if (weatherInfo) els.weatherText.textContent = weatherInfo.label;
}

// ---- 回廊 ----
async function openGallery() {
  els.galleryDialog.showModal();
  els.galleryGrid.innerHTML = '<p class="dialog-hint">展卷中……</p>';
  const items = await api.fetchBingRecent(8);
  if (!items.length) {
    els.galleryGrid.innerHTML = '<p class="dialog-hint">网络微恙，回廊暂无藏画。</p>';
    return;
  }
  const today = new Date();
  els.galleryGrid.innerHTML = '';
  for (const item of items) {
    const isToday = item.date && logic.isSameDay(item.date, today);
    const card = document.createElement('button');
    card.className = 'gallery-card';
    card.type = 'button';
    const img = document.createElement('img');
    img.loading = 'lazy';
    img.src = logic.thumbnailUrl(item.imageUrl);
    img.alt = item.title;
    const metaDiv = document.createElement('div');
    metaDiv.className = 'gallery-meta';
    const strong = document.createElement('strong');
    strong.textContent = item.title;
    const dateSpan = document.createElement('span');
    dateSpan.textContent = item.date
      ? `${item.date.getMonth() + 1}月${item.date.getDate()}日`
      : '';
    metaDiv.append(strong, dateSpan);
    card.append(img, metaDiv);
    if (isToday) {
      const badge = document.createElement('span');
      badge.className = 'badge';
      badge.textContent = '今日';
      card.append(badge);
    }
    card.onclick = () => pickGalleryItem(item);
    els.galleryGrid.append(card);
  }
}

async function pickGalleryItem(item) {
  els.galleryDialog.close();
  toast('正在取画……');
  const bytes = await api.downloadBytes(item.imageUrl);
  if (!bytes) {
    toast('这幅画一时取不下来');
    return;
  }
  currentBytes = bytes;
  try {
    currentCachePath = await cache.saveWallpaper(item.date ?? new Date(), bytes);
  } catch {
    currentCachePath = null;
  }
  currentMeta = item;
  els.wallTitle.textContent = item.title || '凝脂画报';
  els.wallStory.textContent = item.copyright.split(' (')[0] ?? '';
  setWallpaperSrc(bytesToUrl(bytes));
  toast(`已换上「${item.title}」`);
}

// ---- 木鱼 ----
function openMuyu() {
  els.meritText.textContent = `功德 ${getSettings().muyuMerit}`;
  els.muyuDialog.showModal();
}

function knockMuyu() {
  muyuKnock();
  const merit = getSettings().muyuMerit + 1;
  updateSettings({ muyuMerit: merit });
  els.meritText.textContent = `功德 ${merit}`;
  const floater = document.createElement('span');
  floater.className = 'merit-float';
  floater.textContent = '功德 +1';
  els.muyuStage.append(floater);
  floater.addEventListener('animationend', () => floater.remove());
}

// ---- 珍藏壁纸 ----
async function saveWallpaperToDisk() {
  try {
    let bytes = currentBytes;
    if (!bytes && currentCachePath) {
      bytes = await cache.readBytes(currentCachePath);
    }
    if (!bytes) {
      toast('暂无壁纸可珍藏');
      return;
    }
    const target = await dialogApi()?.save({
      defaultPath: `简画报-${logic.dateKey(new Date())}.jpg`,
      filters: [{ name: '图片', extensions: ['jpg'] }],
    });
    if (!target) return;
    await fsApi().writeFile(target, bytes);
    toast('已珍藏');
  } catch {
    toast('珍藏失败，再试试？');
  }
}

// ---- 设置面板 ----
async function openSettings() {
  const s = getSettings();
  for (const radio of els.themeSeg.querySelectorAll('input')) {
    radio.checked = radio.value === s.themeMode;
  }
  els.dimRange.value = s.wallpaperDim;
  els.dimVal.textContent = `${Math.round(s.wallpaperDim * 100)}%`;
  els.showPoetry.checked = s.showPoetry;
  els.startFullscreen.checked = s.startFullscreen;
  els.quoteCategory.value = s.quoteCategory;
  els.cityInput.value = s.weatherCity;
  els.autostart.checked = s.launchAtStartup;
  try {
    els.autostart.checked = await autostartApi()?.isEnabled?.();
  } catch {
    // 以本地偏好为准
  }
  els.settingsDialog.showModal();
}

function bindSettings() {
  els.themeSeg.addEventListener('change', (e) => {
    if (e.target.name === 'themeMode') {
      updateSettings({ themeMode: e.target.value });
      applyTheme();
    }
  });
  els.dimRange.addEventListener('input', () => {
    const dim = Number(els.dimRange.value);
    els.dimVal.textContent = `${Math.round(dim * 100)}%`;
    els.veil.style.opacity = String(dim);
    updateSettings({ wallpaperDim: dim });
  });
  els.showPoetry.addEventListener('change', () => {
    updateSettings({ showPoetry: els.showPoetry.checked });
    applyPoetryVisibility();
  });
  els.startFullscreen.addEventListener('change', () => {
    updateSettings({ startFullscreen: els.startFullscreen.checked });
  });
  els.quoteCategory.addEventListener('change', () => {
    updateSettings({ quoteCategory: els.quoteCategory.value });
    refreshQuote();
  });
  els.cityInput.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') {
      e.preventDefault();
      updateSettings({ weatherCity: els.cityInput.value.trim() });
      refreshWeather(true);
      toast(els.cityInput.value.trim() ? '天气城市已保存' : '天气已隐藏');
    }
  });
  els.autostart.addEventListener('change', async () => {
    const value = els.autostart.checked;
    updateSettings({ launchAtStartup: value });
    try {
      if (value) await autostartApi()?.enable();
      else await autostartApi()?.disable();
    } catch {
      toast('自启设置未生效（开发环境属正常）');
    }
  });
}

// ---- 窗口控制 ----
async function toggleFullscreen() {
  const w = winApi()?.getCurrentWindow();
  if (!w) return;
  try {
    isFullscreen = await w.isFullscreen();
    await w.setFullscreen(!isFullscreen);
    isFullscreen = !isFullscreen;
    document.body.classList.toggle('fullscreen', isFullscreen);
    if (!isFullscreen) await w.maximize?.();
  } catch {
    // 忽略
  }
}

async function exitFullscreen() {
  if (!isFullscreen) return;
  try {
    await winApi()?.getCurrentWindow()?.setFullscreen(false);
    isFullscreen = false;
    document.body.classList.remove('fullscreen');
    await winApi()?.getCurrentWindow()?.maximize?.();
  } catch {
    // 忽略
  }
}

// ---- Toast ----
function toast(message) {
  els.toast.textContent = message;
  els.toast.hidden = false;
  els.toast.classList.add('show');
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => {
    els.toast.classList.remove('show');
    els.toast.hidden = true;
  }, 2000);
}

// ---- 事件绑定 ----
function bindUI() {
  els.btnMin.onclick = () => winApi()?.getCurrentWindow()?.minimize();
  els.btnClose.onclick = () => winApi()?.getCurrentWindow()?.close();
  els.btnFull.onclick = toggleFullscreen;
  document.body.addEventListener('dblclick', (e) => {
    if (e.target.closest('dialog, #actionCluster, #winControls')) return;
    toggleFullscreen();
  });
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && !els.settingsDialog.open && !els.galleryDialog.open && !els.muyuDialog.open) {
      exitFullscreen();
    }
  });

  els.btnRefresh.onclick = () => {
    els.loading.hidden = false;
    loadWallpaperFlow({ force: true }).finally(() => {
      els.loading.hidden = true;
      refreshQuote();
    });
  };
  els.btnGallery.onclick = openGallery;
  els.galleryClose.onclick = () => els.galleryDialog.close();
  els.btnMuyu.onclick = openMuyu;
  els.muyuPad.onclick = knockMuyu;
  els.muyuClose.onclick = () => els.muyuDialog.close();
  els.btnSave.onclick = saveWallpaperToDisk;
  els.btnSettings.onclick = openSettings;

  // 瓷雾初始值
  els.veil.style.opacity = String(getSettings().wallpaperDim);
  subscribe(() => {
    els.veil.style.opacity = String(getSettings().wallpaperDim);
  });

  bindSettings();
}

boot().catch((err) => {
  console.error('启动失败', err);
  els.loading.textContent = '研墨失手了，请重启应用。';
});
