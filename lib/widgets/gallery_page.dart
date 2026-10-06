import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/daily_content.dart';
import '../services/bing_service.dart';
import '../theme/jade_theme.dart';

/// 回廊：近七日必应壁纸回看，点选一幅即可换上当日之景。
/// 返回选中的 [DailyWallpaper]（pop 时），未选返回 null。
Future<DailyWallpaper?> showGallery(BuildContext context, BingService bing) {
  return Navigator.of(context).push<DailyWallpaper>(
    MaterialPageRoute<DailyWallpaper>(
      builder: (_) => GalleryPage(bing: bing),
      fullscreenDialog: true,
    ),
  );
}

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key, required this.bing});

  final BingService bing;

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<DailyWallpaper>? _items;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await widget.bing.fetchRecent(count: 8);
    if (!mounted) return;
    setState(() {
      _items = items;
      _failed = items.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = jadePalette(context);
    final today = DateTime.now();
    return Scaffold(
      backgroundColor: palette.porcelain,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
              child: Row(
                children: [
                  BackButton(color: palette.inkSoft),
                  const SizedBox(width: 4),
                  Text(
                    '回廊 · 近七日',
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: palette.ink,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildBody(context, today),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DateTime today) {
    final palette = jadePalette(context);
    if (_items == null) {
      return const Center(
        child: Text('展卷中……', style: TextStyle(color: Colors.grey, letterSpacing: 4)),
      );
    }
    if (_failed) {
      return Center(
        child: Text(
          '网络微恙，回廊暂无藏画。',
          style: GoogleFonts.notoSerifSc(fontSize: 14, color: palette.inkFaint),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 16 / 11,
      ),
      itemCount: _items!.length,
      itemBuilder: (context, index) {
        final item = _items![index];
        final isToday = item.date != null &&
            item.date!.year == today.year &&
            item.date!.month == today.month &&
            item.date!.day == today.day;
        return _GalleryCard(
          item: item,
          isToday: isToday,
          onTap: () => Navigator.of(context).pop(item),
        );
      },
    );
  }
}

class _GalleryCard extends StatelessWidget {
  const _GalleryCard({
    required this.item,
    required this.isToday,
    required this.onTap,
  });

  final DailyWallpaper item;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = jadePalette(context);
    final dateLabel = item.date == null
        ? ''
        : DateFormat('MM月dd日', 'zh_CN').format(item.date!);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              item.thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => ColoredBox(color: palette.mistMiddle),
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : ColoredBox(color: palette.mistMiddle),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.55, 1],
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateLabel,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (isToday)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: JadeColors.seal.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '今日',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
