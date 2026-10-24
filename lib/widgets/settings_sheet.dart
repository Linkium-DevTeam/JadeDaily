import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

import '../services/settings_service.dart';
import '../theme/jade_theme.dart';

/// 瓷白浮窗式设置面板。
///
/// [onWeatherCitySaved] 在用户保存城市后触发（用于立即刷新天气）；
/// [onQuoteCategoryChanged] 在切换一言雅类后触发（立即重取一句）。
Future<void> showJadeSettings(
  BuildContext context,
  SettingsService settings, {
  VoidCallback? onWeatherCitySaved,
  VoidCallback? onQuoteCategoryChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _SettingsSheet(
      settings: settings,
      onWeatherCitySaved: onWeatherCitySaved,
      onQuoteCategoryChanged: onQuoteCategoryChanged,
    ),
  );
}

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet({
    required this.settings,
    this.onWeatherCitySaved,
    this.onQuoteCategoryChanged,
  });

  final SettingsService settings;
  final VoidCallback? onWeatherCitySaved;
  final VoidCallback? onQuoteCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final palette = jadePalette(context);
        final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.85 - 32;
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.panel,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: palette.panelBorder, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: JadeColors.jadeShadow.withValues(alpha: 0.25),
                blurRadius: 30,
              ),
            ],
          ),
          // Material 层保证 ListTile 墨水效果可见；可滚动避免小窗口溢出。
          child: Material(
            type: MaterialType.transparency,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxSheetHeight),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    _title(context, Icons.tune, '雅设'),
                    const SizedBox(height: 12),
                    _sectionLabel(context, '外观'),
                    _themeModeButton(context),
                    Text(
                      '瓷雾浓度 —— 让背景更朦胧温润',
                      style: TextStyle(fontSize: 13, color: palette.inkFaint),
                    ),
                    Slider(
                      value: settings.wallpaperDim,
                      max: 0.6,
                      divisions: 12,
                      label: '${(settings.wallpaperDim * 100).round()}%',
                      onChanged: settings.setWallpaperDim,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('诗词玉简', style: TextStyle(fontSize: 15)),
                      subtitle: Text(
                        '显示右侧竖排每日一句',
                        style: TextStyle(fontSize: 12, color: palette.inkFaint),
                      ),
                      value: settings.showPoetry,
                      onChanged: settings.setShowPoetry,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('启动即入画', style: TextStyle(fontSize: 15)),
                      subtitle: Text(
                        '打开应用直接进入全屏壁纸模式',
                        style: TextStyle(fontSize: 12, color: palette.inkFaint),
                      ),
                      value: settings.startFullscreen,
                      onChanged: settings.setStartFullscreen,
                    ),
                    const SizedBox(height: 8),
                    _sectionLabel(context, '日常'),
                    _quoteCategoryDropdown(context, palette),
                    _weatherCityField(context, palette),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('开机自启', style: TextStyle(fontSize: 15)),
                      subtitle: Text(
                        '随系统启动，静候每日一景',
                        style: TextStyle(fontSize: 12, color: palette.inkFaint),
                      ),
                      value: settings.launchAtStartup,
                      onChanged: _toggleLaunchAtStartup,
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        '简·画报 v1.3.0 · Linkium 出品',
                        style: TextStyle(fontSize: 12, color: palette.inkFaint),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _title(BuildContext context, IconData icon, String text) {
    final palette = jadePalette(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: palette.inkSoft),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.notoSerifSc(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: palette.ink,
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.notoSerifSc(
          fontSize: 13,
          color: JadeColors.jadeShadow,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _themeModeButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SegmentedButton<JadeThemeMode>(
        segments: [
          for (final mode in JadeThemeMode.values)
            ButtonSegment(
              value: mode,
              label: Text(mode.label),
              icon: Icon(
                switch (mode) {
                  JadeThemeMode.light => Icons.light_mode,
                  JadeThemeMode.dark => Icons.dark_mode,
                  JadeThemeMode.auto => Icons.brightness_auto,
                },
                size: 16,
              ),
            ),
        ],
        selected: {settings.themeMode},
        onSelectionChanged: (selection) => settings.setThemeMode(selection.first),
        showSelectedIcon: false,
      ),
    );
  }

  Widget _quoteCategoryDropdown(BuildContext context, JadePalette palette) {
    return DropdownButtonFormField<JadeQuoteCategory>(
      initialValue: settings.quoteCategoryEnum,
      style: TextStyle(fontSize: 14, color: palette.ink),
      dropdownColor: palette.panel,
      decoration: InputDecoration(
        labelText: '一言雅类',
        labelStyle: TextStyle(fontSize: 13, color: palette.inkFaint),
        helperText: '每日一句的出处偏好',
        helperStyle: TextStyle(fontSize: 11, color: palette.inkFaint),
        border: const OutlineInputBorder(),
      ),
      items: [
        for (final c in JadeQuoteCategory.values)
          DropdownMenuItem(
            value: c,
            child: Text(c.label, style: const TextStyle(fontSize: 14)),
          ),
      ],
      onChanged: (c) {
        if (c != null) {
          settings.setQuoteCategory(c);
          onQuoteCategoryChanged?.call();
        }
      },
    );
  }

  Widget _weatherCityField(BuildContext context, JadePalette palette) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: settings.weatherCity,
        style: TextStyle(fontSize: 14, color: palette.ink),
        decoration: InputDecoration(
          labelText: '天气城市',
          hintText: '如：杭州（回车保存 · 留空隐藏）',
          labelStyle: TextStyle(fontSize: 13, color: palette.inkFaint),
          helperStyle: TextStyle(fontSize: 11, color: palette.inkFaint),
          hintStyle: TextStyle(fontSize: 12, color: palette.inkFaint),
          border: const OutlineInputBorder(),
          prefixIcon: Icon(Icons.location_on_outlined,
              size: 18, color: palette.inkSoft),
        ),
        onFieldSubmitted: (value) async {
          await settings.setWeatherCity(value);
          onWeatherCitySaved?.call();
        },
      ),
    );
  }

  Future<void> _toggleLaunchAtStartup(bool value) async {
    await settings.setLaunchAtStartup(value);
    try {
      if (value) {
        await LaunchAtStartup.instance.enable();
      } else {
        await LaunchAtStartup.instance.disable();
      }
    } catch (_) {
      // 插件通道不可用（开发/测试环境）时仅保留偏好。
    }
  }
}
