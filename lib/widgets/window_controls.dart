import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../theme/jade_theme.dart';

/// 右上角窗口控制钮：最小化 / 全屏 / 关闭。
/// 全屏模式下自动淡出，鼠标悬停恢复。
class WindowControls extends StatefulWidget {
  const WindowControls({super.key, required this.fullscreen});

  final bool fullscreen;

  @override
  State<WindowControls> createState() => _WindowControlsState();
}

class _WindowControlsState extends State<WindowControls> {
  bool _hovering = false;

  Future<void> _toggleFullscreen() async {
    if (await windowManager.isFullScreen()) {
      await windowManager.setFullScreen(false);
      await windowManager.maximize();
    } else {
      await windowManager.setFullScreen(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = jadePalette(context);
    final faded = widget.fullscreen && !_hovering;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedOpacity(
        opacity: faded ? 0.25 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            color: palette.panel.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: '最小化',
                onPressed: windowManager.minimize,
                icon: const Icon(Icons.remove, size: 20),
                color: palette.inkSoft,
              ),
              IconButton(
                tooltip: widget.fullscreen ? '退出全屏' : '全屏壁纸',
                onPressed: _toggleFullscreen,
                icon: Icon(
                  widget.fullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  size: 20,
                ),
                color: palette.inkSoft,
              ),
              IconButton(
                tooltip: '关闭',
                onPressed: windowManager.close,
                icon: const Icon(Icons.close, size: 20),
                color: palette.inkSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
