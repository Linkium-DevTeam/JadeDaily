import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// 壁纸磁盘缓存：每天一张，按日期落盘。
/// 好处：当天重启秒开、断网也能显示、离线时回退到最近一张。
class WallpaperCache {
  WallpaperCache({Future<Directory> Function()? resolveDir})
      : _resolveDir = resolveDir ?? _defaultDir;

  static Future<Directory> _defaultDir() async =>
      getApplicationSupportDirectory();

  static const _prefix = 'jade-wallpaper-';

  final Future<Directory> Function() _resolveDir;

  Future<Directory> _dir() async {
    final base = await _resolveDir();
    final dir = Directory('${base.path}/wallpapers');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static String _stamp(DateTime day) {
    final m = day.month.toString().padLeft(2, '0');
    final d = day.day.toString().padLeft(2, '0');
    return '${day.year}-$m-$d';
  }

  File _fileFor(Directory dir, DateTime day) =>
      File('${dir.path}/$_prefix${_stamp(day)}.jpg');

  /// 当日缓存命中返回文件路径，否则 null。
  Future<String?> load(DateTime day) async {
    try {
      final file = _fileFor(await _dir(), day);
      if (await file.exists() && await file.length() > 0) return file.path;
    } catch (_) {}
    return null;
  }

  Future<File> save(DateTime day, Uint8List bytes) async {
    final file = _fileFor(await _dir(), day);
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  /// 最近一张缓存（跨日断网兜底），没有任何缓存返回 null。
  Future<String?> latest() async {
    try {
      final dir = await _dir();
      final files = await dir
          .list()
          .where((e) => e is File && e.path.contains(_prefix))
          .toList();
      final images = files.whereType<File>().toList()
        ..sort((a, b) => b.path.compareTo(a.path));
      for (final f in images) {
        if (await f.length() > 0) return f.path;
      }
    } catch (_) {}
    return null;
  }
}
