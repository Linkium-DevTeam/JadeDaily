import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/muyu_service.dart';
import '../services/settings_service.dart';
import '../theme/jade_theme.dart';

/// 木鱼 · 功德：轻敲积功德，播放合成木鱼声，"+1" 缓缓上浮。
Future<void> showMuyuDialog(
  BuildContext context, {
  required SettingsService settings,
  required MuyuService muyu,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black26,
    builder: (_) => MuyuDialog(settings: settings, muyu: muyu),
  );
}

class MuyuDialog extends StatefulWidget {
  const MuyuDialog({
    super.key,
    required this.settings,
    required this.muyu,
  });

  final SettingsService settings;
  final MuyuService muyu;

  @override
  State<MuyuDialog> createState() => _MuyuDialogState();
}

class _MuyuDialogState extends State<MuyuDialog> {
  final List<int> _floaters = [];
  int _floaterSeq = 0;

  void _knock() {
    widget.muyu.knock();
    widget.settings.addMerit();
    setState(() => _floaters.add(_floaterSeq++));
  }

  void _removeFloater(int id) {
    if (!mounted) return;
    setState(() => _floaters.remove(id));
  }

  @override
  Widget build(BuildContext context) {
    final palette = jadePalette(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: palette.panel,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: palette.panelBorder, width: 1.5),
        ),
        child: ListenableBuilder(
          listenable: widget.settings,
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '木鱼 · 功德',
                style: GoogleFonts.notoSerifSc(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: palette.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '功德 ${widget.settings.muyuMerit}',
                style: GoogleFonts.notoSerifSc(
                  fontSize: 14,
                  color: palette.inkSoft,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 18),
              // 敲击垫 + 上浮的「功德 +1」
              Stack(
                alignment: Alignment.center,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: _knock,
                      child: Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: palette.porcelain,
                          border: Border.all(
                            color: palette.panelBorder,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.temple_buddhist,
                          size: 84,
                          color: palette.ink,
                        ),
                      ),
                    ),
                  ),
                  for (final id in _floaters)
                    _MeritFloater(
                      key: ValueKey(id),
                      onDone: () => _removeFloater(id),
                    ),
                ],
              ),              const SizedBox(height: 18),
              Text(
                '轻敲一声，心随声静',
                style: GoogleFonts.notoSerifSc(
                  fontSize: 12,
                  color: palette.inkFaint,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('合上', style: TextStyle(color: palette.inkSoft)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 「功德 +1」上浮渐隐，播完自动移除；不拦截敲击。
class _MeritFloater extends StatelessWidget {
  const _MeritFloater({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        onEnd: onDone,
        builder: (context, t, _) => Transform.translate(
          offset: Offset(0, -70 * t),
          child: Opacity(
            opacity: (1 - t).clamp(0.0, 1.0),
            child: Text(
              '功德 +1',
              style: GoogleFonts.maShanZheng(
                fontSize: 26,
                color: JadeColors.seal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
