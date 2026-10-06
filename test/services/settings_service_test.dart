import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:poster/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SettingsService settings;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settings = SettingsService(await SharedPreferences.getInstance());
  });

  test('默认值', () {
    expect(settings.wallpaperDim, 0.25);
    expect(settings.showPoetry, isTrue);
    expect(settings.startFullscreen, isFalse);
  });

  test('修改即持久化', () async {
    await settings.setWallpaperDim(0.4);
    await settings.setShowPoetry(false);
    await settings.setStartFullscreen(true);

    // 用同一份底层存储重建，验证确实写盘
    final restored = SettingsService(await SharedPreferences.getInstance());
    expect(restored.wallpaperDim, 0.4);
    expect(restored.showPoetry, isFalse);
    expect(restored.startFullscreen, isTrue);
  });

  test('雾化浓度越界自动收敛', () async {
    await settings.setWallpaperDim(5.0);
    expect(settings.wallpaperDim, 0.6);
    await settings.setWallpaperDim(-1);
    expect(settings.wallpaperDim, 0.0);
  });

  test('修改会通知监听者', () async {
    var notified = 0;
    settings.addListener(() => notified++);
    await settings.setShowPoetry(false);
    expect(notified, 1);
  });

  test('主题模式默认自动并按时解析昼夜', () async {
    expect(settings.themeMode, JadeThemeMode.auto);
    expect(
      JadeThemeMode.auto.resolve(DateTime(2026, 10, 7, 10)),
      ThemeMode.light,
    );
    expect(
      JadeThemeMode.auto.resolve(DateTime(2026, 10, 7, 20)),
      ThemeMode.dark,
    );
    expect(
      JadeThemeMode.auto.resolve(DateTime(2026, 10, 7, 2)),
      ThemeMode.dark,
    );
    // 显式日间不受时间影响
    await settings.setThemeMode(JadeThemeMode.light);
    expect(
      settings.themeMode.resolve(DateTime(2026, 10, 7, 23)),
      ThemeMode.light,
    );
  });

  test('v1.3 新设置项持久化', () async {
    await settings.setThemeMode(JadeThemeMode.dark);
    await settings.addMerit();
    await settings.addMerit();
    await settings.setWeatherCity(' 杭州 ');
    await settings.setQuoteCategory(JadeQuoteCategory.philosophy);
    await settings.setLaunchAtStartup(true);

    final restored = SettingsService(await SharedPreferences.getInstance());
    expect(restored.themeMode, JadeThemeMode.dark);
    expect(restored.muyuMerit, 2);
    expect(restored.weatherCity, '杭州');
    expect(restored.quoteCategoryEnum, JadeQuoteCategory.philosophy);
    expect(restored.launchAtStartup, isTrue);
  });

  test('一言分类默认诗词，未知 code 回退', () {
    expect(settings.quoteCategory, 'i');
    expect(settings.quoteCategoryEnum, JadeQuoteCategory.poetry);
    expect(JadeQuoteCategory.fromCode('不存在的'), JadeQuoteCategory.poetry);
  });
}
