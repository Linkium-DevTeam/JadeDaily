import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'services/clock_service.dart';
import 'services/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('zh_CN', null);

  final prefs = await SharedPreferences.getInstance();
  final settings = SettingsService(prefs);
  final clock = ClockService();

  await _initWindow(startFullscreen: settings.startFullscreen);

  runApp(JadeApp(settings: settings, clock: clock));
  clock.start();
}

Future<void> _initWindow({required bool startFullscreen}) async {
  await windowManager.ensureInitialized();
  const options = WindowOptions(
    size: Size(1280, 720),
    minimumSize: Size(900, 600),
    center: true,
    backgroundColor: Color(0xFFF2F4F3),
    skipTaskbar: false,
    title: '简·画报 · Jade Daily',
    titleBarStyle: TitleBarStyle.hidden,
  );
  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
    if (startFullscreen) {
      await windowManager.setFullScreen(true);
    } else {
      await windowManager.maximize();
    }
  });
}
