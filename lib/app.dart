import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/clock_service.dart';
import 'services/settings_service.dart';
import 'theme/jade_theme.dart';

class JadeApp extends StatelessWidget {
  const JadeApp({
    super.key,
    required this.settings,
    required this.clock,
  });

  final SettingsService settings;
  final ClockService clock;

  @override
  Widget build(BuildContext context) {
    // 主题随设置变化；「自动」模式下跟随心跳按时切换昼夜。
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => ValueListenableBuilder<DateTime>(
        valueListenable: clock.now,
        builder: (context, now, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: '简·画报 Jade Daily',
          theme: buildJadeTheme(Brightness.light),
          darkTheme: buildJadeTheme(Brightness.dark),
          themeMode: settings.themeMode.resolve(now),
          home: HomeScreen(settings: settings, clock: clock),
        ),
      ),
    );
  }
}
