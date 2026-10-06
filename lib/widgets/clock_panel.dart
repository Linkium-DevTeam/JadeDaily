import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/daily_content.dart';
import '../services/lunar_service.dart';
import '../theme/jade_theme.dart';
import '../utils/chinese_time.dart';
import 'porcelain_panel.dart';

/// 左下角玉牌：日期 + 时辰章 + 农历干支 + 毛笔字时刻 + 壁纸故事 + 天气。
class ClockPanel extends StatelessWidget {
  const ClockPanel({
    super.key,
    required this.clock,
    required this.wallpaper,
    required this.offline,
    this.weatherLabel,
  });

  /// 时钟心跳（每秒更新）。
  final ValueListenable<DateTime> clock;

  /// 今日壁纸元信息；离线时可能为 null。
  final DailyWallpaper? wallpaper;

  /// 离线提示。
  final bool offline;

  /// 天气一行文案（如「晴 · 12°」）；未启用为 null。
  final String? weatherLabel;

  @override
  Widget build(BuildContext context) {
    final palette = jadePalette(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bigFontSize = (screenWidth * 0.065).clamp(64.0, 104.0);

    return PorcelainPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<DateTime>(
            valueListenable: clock,
            builder: (context, now, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        DateFormat('yyyy年MM月dd日 · EEEE', 'zh_CN').format(now),
                        style: GoogleFonts.notoSerifSc(
                          fontSize: 16,
                          color: palette.inkSoft,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _seal(context, shichenText(now.hour)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  LunarService.infoFor(now).label,
                  style: GoogleFonts.notoSerifSc(
                    fontSize: 14,
                    color: palette.inkFaint,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: ValueListenableBuilder<DateTime>(
              valueListenable: clock,
              builder: (context, now, _) => Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    hourText(now.hour),
                    style: GoogleFonts.maShanZheng(
                      fontSize: bigFontSize,
                      color: palette.ink,
                      height: 1.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '·',
                      style: TextStyle(
                        fontSize: 40,
                        color: palette.inkSoft.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  Text(
                    minuteText(now.minute),
                    style: GoogleFonts.maShanZheng(
                      fontSize: bigFontSize,
                      color: palette.ink,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Divider(height: 1, color: palette.inkFaint.withValues(alpha: 0.35)),
          const SizedBox(height: 14),
          Text(
            (wallpaper?.title.isNotEmpty ?? false) ? wallpaper!.title : '凝脂画报',
            style: GoogleFonts.notoSerifSc(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: palette.textBody,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _storyText(),
            style: GoogleFonts.notoSerifSc(
              fontSize: 14,
              color: palette.inkFaint,
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (weatherLabel != null) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.device_thermostat,
                    size: 15, color: palette.inkSoft),
                const SizedBox(width: 6),
                Text(
                  weatherLabel!,
                  style: GoogleFonts.notoSerifSc(
                    fontSize: 13,
                    color: palette.inkSoft,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _storyText() {
    if (offline) return '离线雅坐 · 暂无网络，且赏旧时景。';
    final story = wallpaper?.copyright.split(' (').first ?? '';
    return story;
  }

  Widget _seal(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: JadeColors.seal.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
