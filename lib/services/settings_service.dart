import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 主题模式：日间 / 夜阑墨色 / 按时自动（19:00-06:00 为夜）。
enum JadeThemeMode { light, dark, auto }

extension JadeThemeModeX on JadeThemeMode {
  ThemeMode resolve(DateTime now) => switch (this) {
        JadeThemeMode.light => ThemeMode.light,
        JadeThemeMode.dark => ThemeMode.dark,
        JadeThemeMode.auto =>
          (now.hour >= 19 || now.hour < 6) ? ThemeMode.dark : ThemeMode.light,
      };

  String get label => switch (this) {
        JadeThemeMode.light => '日间',
        JadeThemeMode.dark => '夜阑',
        JadeThemeMode.auto => '自动',
      };
}

/// 一言分类（对应 Hitokoto 的 c 参数）。
enum JadeQuoteCategory {
  random('', '随机'),
  poetry('i', '诗词'),
  literature('c', '文学'),
  philosophy('k', '哲学');

  const JadeQuoteCategory(this.code, this.label);
  final String code;
  final String label;

  static JadeQuoteCategory fromCode(String code) => values.firstWhere(
        (e) => e.code == code,
        orElse: () => JadeQuoteCategory.poetry,
      );
}

/// 用户设置，基于 shared_preferences 持久化；任何修改都会通知监听者刷新 UI。
class SettingsService extends ChangeNotifier {
  SettingsService(this._prefs);

  static const _kWallpaperDim = 'wallpaper_dim';
  static const _kShowPoetry = 'show_poetry';
  static const _kStartFullscreen = 'start_fullscreen';
  static const _kThemeMode = 'theme_mode';
  static const _kMuyuMerit = 'muyu_merit';
  static const _kWeatherCity = 'weather_city';
  static const _kQuoteCategory = 'quote_category';
  static const _kLaunchAtStartup = 'launch_at_startup';

  final SharedPreferences _prefs;

  /// 背景瓷雾浓度（0 = 原图，0.6 = 最朦胧）。
  double get wallpaperDim => _prefs.getDouble(_kWallpaperDim) ?? 0.25;

  Future<void> setWallpaperDim(double value) async {
    await _prefs.setDouble(_kWallpaperDim, value.clamp(0.0, 0.6));
    notifyListeners();
  }

  /// 是否显示右侧诗词玉简。
  bool get showPoetry => _prefs.getBool(_kShowPoetry) ?? true;

  Future<void> setShowPoetry(bool value) async {
    await _prefs.setBool(_kShowPoetry, value);
    notifyListeners();
  }

  /// 启动时直接进入全屏壁纸模式。
  bool get startFullscreen => _prefs.getBool(_kStartFullscreen) ?? false;

  Future<void> setStartFullscreen(bool value) async {
    await _prefs.setBool(_kStartFullscreen, value);
    notifyListeners();
  }

  /// 主题模式。
  JadeThemeMode get themeMode {
    final raw = _prefs.getString(_kThemeMode);
    return JadeThemeMode.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => JadeThemeMode.auto,
    );
  }

  Future<void> setThemeMode(JadeThemeMode value) async {
    await _prefs.setString(_kThemeMode, value.name);
    notifyListeners();
  }

  /// 木鱼功德累计。
  int get muyuMerit => _prefs.getInt(_kMuyuMerit) ?? 0;

  Future<void> addMerit([int count = 1]) async {
    await _prefs.setInt(_kMuyuMerit, muyuMerit + count);
    notifyListeners();
  }

  /// 天气城市（空 = 隐藏天气）。
  String get weatherCity => _prefs.getString(_kWeatherCity) ?? '';

  Future<void> setWeatherCity(String value) async {
    await _prefs.setString(_kWeatherCity, value.trim());
    notifyListeners();
  }

  /// 一言分类 code（'' = 随机）。
  String get quoteCategory => _prefs.getString(_kQuoteCategory) ?? 'i';

  JadeQuoteCategory get quoteCategoryEnum =>
      JadeQuoteCategory.fromCode(quoteCategory);

  Future<void> setQuoteCategory(JadeQuoteCategory value) async {
    await _prefs.setString(_kQuoteCategory, value.code);
    notifyListeners();
  }

  /// 开机自启。
  bool get launchAtStartup => _prefs.getBool(_kLaunchAtStartup) ?? false;

  Future<void> setLaunchAtStartup(bool value) async {
    await _prefs.setBool(_kLaunchAtStartup, value);
    notifyListeners();
  }
}
