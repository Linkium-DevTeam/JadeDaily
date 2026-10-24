import 'package:flutter/material.dart';

/// 「凝脂瓷」主题色常量（跨主题不变的部分）。
abstract final class JadeColors {
  /// 朱砂印（时辰章、雅趣章）
  static const seal = Color(0xFFA64036);

  /// 青玉（强调、阴影）
  static const jadeShadow = Color(0xFF869D7A);
}

/// 随主题变化的凝脂瓷配色，经 ThemeExtension 注入明暗两套。
@immutable
class JadePalette extends ThemeExtension<JadePalette> {
  const JadePalette({
    required this.porcelain,
    required this.panel,
    required this.panelBorder,
    required this.ink,
    required this.inkSoft,
    required this.inkFaint,
    required this.textBody,
    required this.textPoem,
    required this.overlay,
    required this.mistTop,
    required this.mistMiddle,
    required this.mistBottom,
  });

  /// 页面底色
  final Color porcelain;

  /// 玉牌面板
  final Color panel;

  /// 玉牌描边
  final Color panelBorder;

  /// 浓墨（大字时刻）
  final Color ink;

  /// 淡墨（日期、次要文字）
  final Color inkSoft;

  /// 灰墨（版权、署名）
  final Color inkFaint;

  /// 正文（壁纸故事标题）
  final Color textBody;

  /// 诗文
  final Color textPoem;

  /// 壁纸雾化色（日间瓷白提亮 / 夜间墨色压暗）
  final Color overlay;

  /// 无壁纸时的渐变底
  final Color mistTop;
  final Color mistMiddle;
  final Color mistBottom;

  static const light = JadePalette(
    porcelain: Color(0xFFF2F4F3),
    panel: Color(0xFFF8FBF8),
    panelBorder: Color(0xFFFFFFFF),
    ink: Color(0xFF2B333E),
    inkSoft: Color(0xFF5E616D),
    inkFaint: Color(0xFF888888),
    textBody: Color(0xFF333333),
    textPoem: Color(0xFF222222),
    overlay: Color(0xFFF2F4F3),
    mistTop: Color(0xFFE8EDE8),
    mistMiddle: Color(0xFFF6F4EE),
    mistBottom: Color(0xFFDCE5DC),
  );

  /// 夜阑墨色
  static const dark = JadePalette(    porcelain: Color(0xFF171C21),
    panel: Color(0xFF232B33),
    panelBorder: Color(0xFF3A444E),
    ink: Color(0xFFE8E2D4),
    inkSoft: Color(0xFFA8B0B8),
    inkFaint: Color(0xFF78828B),
    textBody: Color(0xFFD8D3C6),
    textPoem: Color(0xFFE6E1D4),
    overlay: Color(0xFF0B0E12),
    mistTop: Color(0xFF1A2027),
    mistMiddle: Color(0xFF14191F),
    mistBottom: Color(0xFF10141A),
  );

  @override
  JadePalette copyWith({
    Color? porcelain,
    Color? panel,
    Color? panelBorder,
    Color? ink,
    Color? inkSoft,
    Color? inkFaint,
    Color? textBody,
    Color? textPoem,
    Color? overlay,
    Color? mistTop,
    Color? mistMiddle,
    Color? mistBottom,
  }) {
    return JadePalette(
      porcelain: porcelain ?? this.porcelain,
      panel: panel ?? this.panel,
      panelBorder: panelBorder ?? this.panelBorder,
      ink: ink ?? this.ink,
      inkSoft: inkSoft ?? this.inkSoft,
      inkFaint: inkFaint ?? this.inkFaint,
      textBody: textBody ?? this.textBody,
      textPoem: textPoem ?? this.textPoem,
      overlay: overlay ?? this.overlay,
      mistTop: mistTop ?? this.mistTop,
      mistMiddle: mistMiddle ?? this.mistMiddle,
      mistBottom: mistBottom ?? this.mistBottom,
    );
  }

  @override
  JadePalette lerp(ThemeExtension<JadePalette>? other, double t) {
    if (other is! JadePalette) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return JadePalette(
      porcelain: mix(porcelain, other.porcelain),
      panel: mix(panel, other.panel),
      panelBorder: mix(panelBorder, other.panelBorder),
      ink: mix(ink, other.ink),
      inkSoft: mix(inkSoft, other.inkSoft),
      inkFaint: mix(inkFaint, other.inkFaint),
      textBody: mix(textBody, other.textBody),
      textPoem: mix(textPoem, other.textPoem),
      overlay: mix(overlay, other.overlay),
      mistTop: mix(mistTop, other.mistTop),
      mistMiddle: mix(mistMiddle, other.mistMiddle),
      mistBottom: mix(mistBottom, other.mistBottom),
    );
  }
}

/// 便捷取色：`jadePalette(context).ink`。
JadePalette jadePalette(BuildContext context) =>
    Theme.of(context).extension<JadePalette>() ?? JadePalette.light;

ThemeData buildJadeTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final palette = isDark ? JadePalette.dark : JadePalette.light;
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: palette.porcelain,
    colorScheme: ColorScheme.fromSeed(
      seedColor: JadeColors.jadeShadow,
      brightness: brightness,
      surface: palette.porcelain,
    ),
    fontFamily: 'Microsoft YaHei',
  );
  return base.copyWith(
    extensions: [palette],
    sliderTheme: base.sliderTheme.copyWith(
      activeTrackColor: JadeColors.jadeShadow,
      inactiveTrackColor: JadeColors.jadeShadow.withValues(alpha: 0.2),
      thumbColor: palette.panel,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: isDark
          ? palette.panel.withValues(alpha: 0.95)
          : palette.ink.withValues(alpha: 0.88),
      contentTextStyle: TextStyle(
        color: isDark ? palette.ink : Colors.white,
        fontSize: 14,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
