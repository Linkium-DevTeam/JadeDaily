import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/jade_theme.dart';

/// 背景壁纸层：本地缓存图 + 瓷雾/墨色压暗 + 淡入动画。
/// 无图或加载失败时退到随主题的渐变底。
class WallpaperBackground extends StatelessWidget {
  const WallpaperBackground({
    super.key,
    required this.path,
    required this.dim,
  });

  final String? path;

  /// 雾化浓度 0-0.6。
  final double dim;

  @override
  Widget build(BuildContext context) {
    final palette = jadePalette(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: path != null
              ? Image.file(
                  File(path!),
                  fit: BoxFit.cover,
                  frameBuilder: _fadeIn,
                  errorBuilder: (_, _, _) => _mist(palette),
                )
              : _mist(palette),
        ),
        if (path != null)
          RepaintBoundary(
            child: ColoredBox(
              color: palette.overlay.withValues(alpha: dim),
            ),
          ),
      ],
    );
  }

  /// 瓷雾/夜色渐变 + 一枚极淡的「简」字水印。
  Widget _mist(JadePalette palette) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.mistTop,
            palette.mistMiddle,
            palette.mistBottom,
          ],
        ),
      ),
      child: Center(
        child: Text(
          '简',
          style: TextStyle(
            fontSize: 220,
            fontFamily: 'Microsoft YaHei',
            color: palette.ink.withValues(alpha: 0.045),
          ),
        ),
      ),
    );
  }

  Widget _fadeIn(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    if (wasSynchronouslyLoaded) return child;
    return AnimatedOpacity(
      opacity: frame == null ? 0 : 1,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      child: child,
    );
  }
}
