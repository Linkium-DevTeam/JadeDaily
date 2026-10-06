import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/settings_service.dart';
import '../theme/jade_theme.dart';

/// 瓷白浮窗式设置面板。
Future<void> showJadeSettings(BuildContext context, SettingsService settings) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _SettingsSheet(settings: settings),
  );
}

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet({required this.settings});

  final SettingsService settings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.85 - 32;
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: JadeColors.panel,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 1.5),
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
                    Row(
                      children: [
                        const Icon(
                          Icons.tune,
                          size: 20,
                          color: JadeColors.inkSoft,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '雅设',
                          style: GoogleFonts.notoSerifSc(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: JadeColors.ink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '瓷雾浓度 —— 让背景更朦胧温润',
                      style: TextStyle(
                        fontSize: 13,
                        color: JadeColors.inkFaint,
                      ),
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
                        style: TextStyle(
                          fontSize: 12,
                          color: JadeColors.inkFaint,
                        ),
                      ),
                      value: settings.showPoetry,
                      onChanged: settings.setShowPoetry,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        '启动即入画',
                        style: TextStyle(fontSize: 15),
                      ),
                      subtitle: Text(
                        '打开应用直接进入全屏壁纸模式',
                        style: TextStyle(
                          fontSize: 12,
                          color: JadeColors.inkFaint,
                        ),
                      ),
                      value: settings.startFullscreen,
                      onChanged: settings.setStartFullscreen,
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        '简·画报 v1.2.0 · Linkium 出品',
                        style: TextStyle(
                          fontSize: 12,
                          color: JadeColors.inkFaint,
                        ),
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
}
