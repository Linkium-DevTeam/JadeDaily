<div align="center">

<img src="assets/logo.png" width="120" height="120" alt="Jade Daily Logo" />

# 🏮 Jade Daily | 简·画报

**New Chinese Style Zen Clock & Wallpaper**
<br>
*将您的桌面，化为一方温润的数字雅集。*

<!-- Miku绿 (#39C5BB) 风格徽章 -->
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
- **Suet Jade UI:** The interface mimics the texture of premium "Mutton-fat Jade", offering a warm and calming visual experience.
- **独家“凝脂瓷”调色：** 拒绝死板的高斯模糊，采用独家调制的温润色调，如玉般细腻。
- **瓷雾浓度可调：** 内置设置面板，随手调节背景朦胧感。

### ✒️ Digital Calligraphy (数字书法)
- **Artistic Time:** Time is rendered in traditional Chinese calligraphy fonts (马善政毛笔体), restoring the artistic beauty of Hanzi strokes.
- **十二时辰:** 除了数字时间，还显示「辰时」「戌时」等传统时辰朱砂章。
- **Poetic Moments:** Displays daily ancient poems or *Hitokoto* (一言)，竖排玉简排版如古籍；断网自动落到古诗词兜底池。

### 🖼️ Daily View (每日一景)
- **4K Sync:** Automatically syncs Bing's daily ultra-HD wallpapers.
- **Storytelling:** View the story behind every image.
- **秒开与离线：** 壁纸按日磁盘缓存，当天重启即开即用；断网自动回退最近一景。
- **跨日换景：** 时针走过零点，自动为您换上新一日的画报。
- **珍藏壁纸：** 一键把今日之景收进「下载」文件夹。

### 🪟 Desktop Craft (桌面细节)
- **无边框也可用：** 自绘最小化 / 全屏 / 关闭按钮，顶部与玉牌均可拖拽移动窗口。
- **全屏壁纸模式：** 双击画面或右上角按钮进入；`Esc` 一键回到窗口。
- **设置持久化：** 瓷雾浓度、诗词开关、启动即入画，重启后依然如故。

### ⚡ Solo Engineering (独立开发)
- **Pure Native:** Built with **Flutter** & **Win32 API**.
- **Efficiency:** No ads, no tracking, lightweight performance.

---

## 📸 Screenshots (预览)

<div align="center">
  <!-- TODO: 发布前替换为最新版截图 -->
  <!-- <img src="assets/screenshot.png" width="800" alt="App Screenshot" style="border-radius: 10px; box-shadow: 0 0 20px rgba(0,0,0,0.2);" /> -->
</div>

---

## 📥 Download (下载)

You have two choices. Both provide the same great experience.

### 🚀 Option 1: Free Full Version (免费完整版)
Get the portable `.exe` or installer from GitHub Releases.
<br>
[![](https://img.shields.io/badge/Download-GitHub_Releases-39C5BB?style=for-the-badge&logo=github)](https://github.com/Linkium-DevTeam/JadeDaily/releases)

<br>

### ❤️ Option 2: Support Me (捐助/支持作者)
Buy on Microsoft Store to help me keep updating.
<br>
[![](https://img.shields.io/badge/Donate-Microsoft_Store-EB3C00?style=for-the-badge&logo=microsoft)](https://apps.microsoft.com/detail/9njxk0k0x0l3)

---

## 🛠️ Tech Stack (技术栈)

| Component | Technology | Description |
| :--- | :--- | :--- |
| **Framework** | ![Flutter](https://img.shields.io/badge/-Flutter-39C5BB?style=flat-square&logo=flutter&logoColor=white) | Pixel-perfect UI rendering. |
| **Language** | ![Dart](https://img.shields.io/badge/-Dart-262A55?style=flat-square&logo=dart&logoColor=white) | Core logic. |
| **System** | ![Win32](https://img.shields.io/badge/-Win32-0078D6?style=flat-square&logo=windows&logoColor=white) | Native window management. |
| **Quality** | ![Tests](https://img.shields.io/badge/-flutter__test-39C5BB?style=flat-square&logo=githubactions&logoColor=white) | Unit + widget tests & CI. |

---

## 🗂️ Project Structure (代码结构)

```
lib/
├── main.dart                  # 入口：窗口初始化、依赖装配
├── app.dart                   # MaterialApp 与主题挂载
├── theme/jade_theme.dart      # 「凝脂瓷」配色与全局主题
├── models/
│   └── daily_content.dart     # 壁纸 / 诗词数据模型（含离线兜底池）
├── services/
│   ├── clock_service.dart     # 每秒心跳（跨日换景检测）
│   ├── settings_service.dart  # 设置持久化（shared_preferences）
│   ├── bing_service.dart      # 必应每日一图（超时/重试）
│   ├── quote_service.dart     # 一言 Hitokoto
│   └── wallpaper_cache.dart   # 壁纸磁盘缓存
├── screens/
│   └── home_screen.dart       # 主界面编排（数据 + 窗口行为）
├── widgets/
│   ├── porcelain_panel.dart   # 凝脂瓷玉牌容器
│   ├── clock_panel.dart       # 左下时钟玉牌（时辰章）
│   ├── poetry_scroll.dart     # 右侧诗词玉简
│   ├── vertical_text.dart     # 竖排文字（古籍标点排版）
│   ├── wallpaper_background.dart # 背景壁纸 + 瓷雾 + 淡入
│   ├── window_controls.dart   # 自绘窗口控制钮
│   └── settings_sheet.dart    # 「雅设」设置面板
└── utils/
    └── chinese_time.dart      # 汉字数字与十二时辰换算
```

---

## 💻 Development (开发指南)

### 环境要求
- Flutter stable（含 Windows 桌面支持）
- Visual Studio 2022（含「使用 C++ 的桌面开发」工作负载，用于构建 Windows 运行器）

### 常用命令

```bash
flutter pub get              # 安装依赖
flutter run -d windows       # 本地运行
flutter analyze              # 静态检查
flutter test                 # 单元测试 + Widget 测试
flutter build windows --release   # 构建 exe（build/windows/x64/runner/Release）
dart run msix:create         # 打包 Microsoft Store 的 MSIX 安装包
```

### 质量保障
- GitHub Actions CI：每次 push / PR 自动执行 `analyze + test`，并在 Windows 上验证 release 构建。
- 打上 `v*` 标签（如 `v1.2.1`）会自动构建便携版 zip 并附加到 GitHub Release。

---

## 📄 License

This project is licensed under the **Apache License 2.0**.
You are free to view the source code, learn from it, and modify it.

<br>

<div align="center">

*Made with ❤️ by [Linkium](https://github.com/Linkium-suki)*

</div>
