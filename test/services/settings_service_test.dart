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
}
