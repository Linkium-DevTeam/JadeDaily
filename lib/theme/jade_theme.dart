import 'package:flutter/material.dart';

/// 「凝脂瓷」配色 —— 全应用统一从这里取色。
abstract final class JadeColors {
  /// 瓷白底色（背景）
  static const porcelain = Color(0xFFF2F4F3);

  /// 玉牌面板色
  static const panel = Color(0xFFF8FBF8);

  /// 浓墨（大字时刻）
  static const ink = Color(0xFF2B333E);

  /// 淡墨（日期、次要文字）
  static const inkSoft = Color(0xFF5E616D);

  /// 灰墨（版权、署名）
  static const inkFaint = Color(0xFF888888);

  /// 朱砂印（时辰章、雅趣章）
  static const seal = Color(0xFFA64036);

  /// 青玉阴影
  static const jadeShadow = Color(0xFF869D7A);

  /// 离线兜底的渐变底色
  static const mistTop = Color(0xFFE8EDE8);
  static const mistMiddle = Color(0xFFF6F4EE);
  static const mistBottom = Color(0xFFDCE5DC);
}

ThemeData buildJadeTheme() {
  final base = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: JadeColors.porcelain,
    colorScheme: ColorScheme.fromSeed(
      seedColor: JadeColors.jadeShadow,
      surface: JadeColors.porcelain,
    ),
    fontFamily: 'Microsoft YaHei',
  );
  return base.copyWith(
    sliderTheme: base.sliderTheme.copyWith(
      activeTrackColor: JadeColors.jadeShadow,
      inactiveTrackColor: JadeColors.jadeShadow.withValues(alpha: 0.2),
      thumbColor: JadeColors.panel,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: JadeColors.ink.withValues(alpha: 0.88),
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
