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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '简·画报 Jade Daily',
      theme: buildJadeTheme(),
      home: HomeScreen(settings: settings, clock: clock),
    );
  }
}
