import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

import '../models/daily_content.dart';
import '../services/bing_service.dart';
import '../services/clock_service.dart';
import '../services/quote_service.dart';
import '../services/settings_service.dart';
import '../services/wallpaper_cache.dart';
import '../widgets/clock_panel.dart';
import '../widgets/poetry_scroll.dart';
import '../widgets/settings_sheet.dart';
import '../widgets/wallpaper_background.dart';
import '../widgets/window_controls.dart';

/// 主界面：背景壁纸 + 时钟玉牌 + 诗词玉简 + 窗口控制。
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.settings,
    required this.clock,
    this.bing,
    this.quotes,
    this.cache,
  });

  final SettingsService settings;
  final ClockService clock;

  /// 依赖注入入口（测试时替换为假实现）。
  final BingService? bing;
  final QuoteService? quotes;
  final WallpaperCache? cache;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WindowListener {
  late final BingService _bing;
  late final QuoteService _quotes;
  late final WallpaperCache _cache;

  DailyWallpaper? _wallpaper;
  DailyQuote _quote = const DailyQuote('正在研墨……', '');
  String? _wallpaperPath;
  bool _loading = true;
  bool _offline = false;
  bool _fullscreen = false;
  DateTime _fetchedDay = DateTime(0);

  @override
  void initState() {
    super.initState();
    _bing = widget.bing ?? BingService();
    _quotes = widget.quotes ?? QuoteService();
    _cache = widget.cache ?? WallpaperCache();
    widget.clock.addListener(_onTick);
    windowManager.addListener(this);
    _bootstrap();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncFullscreenState());
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    widget.clock.removeListener(_onTick);
    super.dispose();
  }

  // ---- WindowListener：只关心全屏状态 ----
  @override
  void onWindowEnterFullScreen() => setState(() => _fullscreen = true);

  @override
  void onWindowLeaveFullScreen() => setState(() => _fullscreen = false);

  // ---- 数据 ----

  /// 启动/跨日/手动刷新共用：
  /// 当日缓存秒开 → 拉元信息 → 需要时下载 → 全败则回退最近一张。
  Future<void> _bootstrap({bool force = false}) async {
    final today = DateTime.now();
    if (mounted && !_loading) setState(() => _loading = true);

    var path = force ? null : await _cache.load(today);

    final results = await Future.wait<Object?>([
      _bing.fetchToday(),
      _quotes.fetch(),
    ]);
    final meta = results[0] as DailyWallpaper?;
    final quote = results[1] as DailyQuote?;

    if (meta != null && path == null) {
      final bytes = await _bing.downloadImage(meta.imageUrl);
      if (bytes != null) {
        try {
          path = (await _cache.save(today, bytes)).path;
        } catch (_) {
          // 缓存写失败不致命，直接用内存字节也行——这里选择下次重下。
        }
      }
    }

    if (meta == null && path == null) {
      path = await _cache.latest();
    }

    if (!mounted) return;
    setState(() {
      _wallpaper = meta;
      _quote = quote ?? DailyQuote.fallback();
      _wallpaperPath = path ?? _wallpaperPath;
      _offline = meta == null && quote == null;
      _loading = false;
      _fetchedDay = today;
    });
  }

  /// 跨日自动换景：心跳里发现日期变了就重新取景。
  void _onTick() {
    final now = widget.clock.now.value;
    if (!_loading && !isSameDay(now, _fetchedDay)) _bootstrap();
  }

  // ---- 窗口行为 ----

  Future<void> _syncFullscreenState() async {
    try {
      final fs = await windowManager.isFullScreen();
      if (fs != _fullscreen && mounted) setState(() => _fullscreen = fs);
    } catch (_) {
      // 测试环境无窗口插件，忽略。
    }
  }

  Future<void> _toggleFullscreen() async {
    if (await windowManager.isFullScreen()) {
      await windowManager.setFullScreen(false);
      await windowManager.maximize();
    } else {
      await windowManager.setFullScreen(true);
    }
  }

  Future<void> _exitFullscreen() async {
    if (await windowManager.isFullScreen()) {
      await windowManager.setFullScreen(false);
      await windowManager.maximize();
    }
  }

  // ---- 小动作 ----

  Future<void> _saveWallpaper() async {
    final path = _wallpaperPath;
    if (path == null) {
      _toast('暂无壁纸可珍藏');
      return;
    }
    try {
      final dir =
          await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      final stamp = DateFormat('yyyyMMdd').format(DateTime.now());
      await File(path).copy('${dir.path}/简画报-$stamp.jpg');
      _toast('已珍藏至「下载」文件夹');
    } catch (_) {
      _toast('珍藏失败，再试试？');
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
  }

  // ---- UI ----

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): _exitFullscreen,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: GestureDetector(
            onDoubleTap: _toggleFullscreen,
            child: ListenableBuilder(
              listenable: settings,
              builder: (context, _) => Stack(
                fit: StackFit.expand,
                children: [
                  WallpaperBackground(
                    path: _wallpaperPath,
                    dim: settings.wallpaperDim,
                  ),

                  // 顶部隐形拖拽条（替代被隐藏的标题栏）
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 48,
                    child: DragToMoveArea(child: ColoredBox(color: Colors.transparent)),
                  ),

                  Positioned(
                    top: 8,
                    right: 8,
                    child: WindowControls(fullscreen: _fullscreen),
                  ),

                  if (_loading)
                    const Center(
                      child: Text(
                        '研墨中……',
                        style: TextStyle(color: Colors.grey, letterSpacing: 4),
                      ),
                    )
                  else
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(48),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 520),
                                child: DragToMoveArea(
                                  child: ClockPanel(
                                    clock: widget.clock.now,
                                    wallpaper: _wallpaper,
                                    offline: _offline,
                                  ),
                                ),
                              ),
                            ),
                            if (settings.showPoetry)
                              Align(
                                alignment: Alignment.centerRight,
                                child: PoetryScroll(quote: _quote),
                              ),
                          ],
                        ),
                      ),
                    ),

                  Positioned(bottom: 16, right: 16, child: _actionCluster()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionCluster() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: '换一景',
            onPressed: _loading ? null : () => _bootstrap(force: true),
            icon: const Icon(Icons.refresh, color: Colors.black38),
          ),
          IconButton(
            tooltip: '珍藏壁纸',
            onPressed: _wallpaperPath == null ? null : _saveWallpaper,
            icon: const Icon(Icons.save_alt, color: Colors.black38),
          ),
          IconButton(
            tooltip: '雅设',
            onPressed: () => showJadeSettings(context, widget.settings),
            icon: const Icon(Icons.tune, color: Colors.black38),
          ),
        ],
      ),
    );
  }
}
