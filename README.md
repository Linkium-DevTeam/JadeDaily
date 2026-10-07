<div align="center">

<img src="assets/logo.png" width="120" height="120" alt="Jade Daily Logo" />

# 🏮 Jade Daily | 简·画报

**New Chinese Style Zen Clock & Wallpaper**
<br>
*将您的桌面，化为一方温润的数字雅集。*

[![Indie Dev](https://img.shields.io/badge/Dev-Grade_7_Student-39C5BB?style=for-the-badge)](https://github.com/Linkium-suki)
[![Open Source](https://img.shields.io/badge/Open_Source-ApacheLicensev2-262A55?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%2010%2F11-39C5BB?style=for-the-badge&logo=windows)](https://www.windows.com)
[![CI](https://github.com/Linkium-DevTeam/JadeDaily/actions/workflows/ci.yml/badge.svg)](https://github.com/Linkium-DevTeam/JadeDaily/actions/workflows/ci.yml)

</div>

---

## 👋 Introduction (开发者说)

Hi there! I'm **Linkium**, a Grade 7 student and an independent developer.

**Jade Daily (简·画报)** is a free and open-source project. I built it because I wanted to bring the warmth of "New Chinese Style" aesthetics to the cold Windows desktop.

**📢 A Note on Pricing / 关于付费：**
*   **GitHub:** You can download the **Full Version** here for **FREE**.
*   **Microsoft Store:** The paid version on the Store is exactly the same. It exists solely as a **Donation Channel**. If you like my work and want to support a student developer, buying it on the Store is the best way to say "Thank you"! ❤️

**GitHub 里的就是完整版，完全免费！**
微软商店的付费版仅仅是**“捐助/打赏”**通道。如果您觉得这个软件不错，想请我喝瓶可乐，欢迎去商店购买支持！非常感谢！

---

## ✨ Features (功能亮点)

### 🏮 Porcelain Texture (凝脂瓷质感)
- **Suet Jade UI:** The interface mimics the texture of premium "Mutton-fat Jade".
- **独家“凝脂瓷”调色：** 温润色调，如玉般细腻。
- **瓷雾浓度可调：** 内置「雅设」面板，随手调节背景朦胧感。
- **夜阑墨色：** 手动切换或按时自动（19:00-06:00）进入暗色主题。

### ✒️ Digital Calligraphy (数字书法)
- **Artistic Time:** 汉字毛笔字时刻 + 十二时辰朱砂章。
- **农历·干支·生肖：** 玉牌上常驻一行农历（如「丙午年马 · 农历八月初三」）。
- **Poetic Moments:** 一言 Hitokoto 竖排玉简排版如古籍；一言雅类（诗词/文学/哲学）随心选；断网自动落到古诗词兜底池。

### 🖼️ Daily View (每日一景)
- **4K Sync:** Automatically syncs Bing's daily ultra-HD wallpapers.
- **秒开与离线：** 壁纸按日磁盘缓存，当天重启即开即用；断网自动回退最近一景。
- **跨日换景：** 时针走过零点，自动为您换上新一日的画报。
- **回廊：** 近七日画报一眼回看，点选即可换上当日之景。
- **珍藏壁纸：** 一键把今日之景收进本地。
- **天气一测：** 设置城市即可在玉牌上看到实时天气（Open-Meteo，免密钥）。

### 🪵 Zen Moments (禅意小物)
- **木鱼功德：** 轻敲木鱼，功德 +1 缓缓上浮；敲击声由 WebAudio 实时合成，零音频资产；功德累计持久保存。

### 🪟 Desktop Craft (桌面细节)
- **无边框也可用：** 自绘最小化 / 全屏 / 关闭按钮，顶部与玉牌均可拖拽移动窗口。
- **全屏壁纸模式：** 双击画面进入；`Esc` 一键回到窗口。
- **开机自启：** 随系统启动，静候每日一景。
- **设置持久化：** 主题、瓷雾、诗词、自启等设置重启后依然如故。

### ⚡ Solo Engineering (独立开发)
- **Efficiency:** No ads, no tracking. 安装后约 **3-5 MB**，内存占用约为原 Flutter 版本的一半。

---

## 📥 Download (下载)

You have two choices. Both provide the same great experience.

### 🚀 Option 1: Free Full Version (免费完整版)
Get the installer (NSIS) or portable `.exe` from GitHub Releases.
<br>
[![](https://img.shields.io/badge/Download-GitHub_Releases-39C5BB?style=for-the-badge&logo=github)](https://github.com/Linkium-DevTeam/JadeDaily/releases)

<br>

### ❤️ Option 2: Support Me (捐助/支持作者)
Buy on Microsoft Store to help me keep updating.
<br>
[![](https://img.shields.io/badge/Donate-Microsoft_Store-EB3C00?style=for-the-badge&logo=microsoft)](https://apps.microsoft.com/detail/9njxk0k0x0l3)

---

## 🛠️ Tech Stack (技术栈)

v2 起从 Flutter 迁移到 **Tauri 2**，安装体积从 ~30 MB 降到 ~4 MB：

| Component | Technology | Description |
| :--- | :--- | :--- |
| **Shell** | ![Rust](https://img.shields.io/badge/-Rust-DEA584?style=flat-square&logo=rust&logoColor=white) | Tauri 2 壳层 + 农历算法（chinese-lunisolar-calendar）。 |
| **UI** | ![HTML5](https://img.shields.io/badge/-HTML%2FCSS%2FJS-E34F26?style=flat-square&logo=html5&logoColor=white) | 零框架、零构建的静态前端，系统楷体/宋体渲染书法。 |
| **Engine** | ![WebView2](https://img.shields.io/badge/-WebView2-0078D6?style=flat-square&logo=microsoftedge&logoColor=white) | Windows 10/11 系统自带，无需分发运行时。 |
| **Quality** | ![Tests](https://img.shields.io/badge/-node:test%20%2B%20cargo%20test-39C5BB?style=flat-square&logo=githubactions&logoColor=white) | JS 逻辑测试 + Rust 农历测试，CI 全平台验证。 |

> 📜 v1（Flutter 版）的历史与源码保留在 `feature/v1.3` 分支及更早的提交中。

---

## 🗂️ Project Structure (代码结构)

```
├── package.json               # 仅一个 devDependency：@tauri-apps/cli
├── src/                       # 前端（Tauri 直接分发，零构建）
│   ├── index.html             # 界面结构（玉牌 / 玉简 / 回廊 / 木鱼 / 雅设）
│   ├── css/jade.css           # 「凝脂瓷」明暗双主题
│   ├── js/
│   │   ├── main.js            # 编排：时钟、壁纸管线、天气、窗口控制
│   │   ├── logic.js           # 纯函数：汉字数字、时辰、天气文案（可测）
│   │   ├── store.js           # 设置存储（localStorage + 订阅）
│   │   ├── api.js             # 网络层：Bing / 一言 / Open-Meteo
│   │   ├── cache.js           # 壁纸磁盘缓存
│   │   └── muyu.js            # 木鱼声（WebAudio 合成）
│   └── logo.png
├── src-tauri/                 # Rust 壳层
│   ├── src/main.rs            # 插件注册 + lunar_info 命令（含单元测试）
│   ├── tauri.conf.json        # 无边框窗口、NSIS 打包配置
│   └── capabilities/          # 最小权限声明
├── tests/logic.test.mjs       # node --test 逻辑测试
└── .github/workflows/ci.yml   # CI：测试 + Windows 构建 + 标签发布
```

---

## 💻 Development (开发指南)

### 环境要求
- Node.js ≥ 20
- Rust stable（MSVC 工具链）
- WebView2 Runtime（Windows 10/11 自带）

### 常用命令

```bash
npm install          # 安装依赖（只有 tauri cli）
npm test             # JS 逻辑测试
npm run dev          # 开发模式热重载
npm run build        # 构建（exe + NSIS 安装包）
cargo test           # 在 src-tauri/ 内运行 Rust 农历测试
npm run icon         # 由 assets/logo.png 重新生成全套图标
```

### 质量保障
- GitHub Actions CI：每次 push / PR 自动执行 `npm test`，并在 Windows 上验证完整构建。
- 打上 `v*` 标签（如 `v2.0.1`）会自动构建 NSIS 安装包与便携版 zip 并附加到 GitHub Release。

---

## 📄 License

This project is licensed under the **Apache License 2.0**.
You are free to view the source code, learn from it, and modify it.

<br>

<div align="center">

*Made with ❤️ by [Linkium](https://github.com/Linkium-suki)*

</div>
