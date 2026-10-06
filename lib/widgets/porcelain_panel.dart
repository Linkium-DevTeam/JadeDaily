import 'package:flutter/material.dart';

import '../theme/jade_theme.dart';

/// 「凝脂瓷」玉牌面板 —— 暖白底、白瓷描边、青玉投影。
class PorcelainPanel extends StatelessWidget {
  const PorcelainPanel({
    super.key,
    required this.child,
    this.vertical = false,
  });

  final Widget child;

  /// 竖排玉简（右侧诗词）使用更宽的横向留白。
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: vertical
          ? const EdgeInsets.symmetric(horizontal: 28, vertical: 48)
          : const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: JadeColors.panel.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: JadeColors.jadeShadow.withValues(alpha: 0.15),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
