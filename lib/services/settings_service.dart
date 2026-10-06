import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 用户设置，基于 shared_preferences 持久化；任何修改都会通知监听者刷新 UI。
class SettingsService extends ChangeNotifier {
  SettingsService(this._prefs);

  static const _kWallpaperDim = 'wallpaper_dim';
  static const _kShowPoetry = 'show_poetry';
  static const _kStartFullscreen = 'start_fullscreen';

  final SharedPreferences _prefs;

  /// 背景瓷白雾化浓度（0 = 原图，0.6 = 最朦胧）。
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
}
