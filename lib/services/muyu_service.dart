import 'package:audioplayers/audioplayers.dart';

/// 木鱼声播放：懒加载播放器，首次敲击才初始化（避免无谓的插件通道开销）。
class MuyuService {
  MuyuService({bool Function()? enabled}) : _enabled = enabled;

  /// 可选开关（如测试环境禁用真实播放）。
  final bool Function()? _enabled;

  AudioPlayer? _player;

  Future<void> knock() async {
    if (_enabled?.call() == false) return;
    try {
      _player ??= AudioPlayer();
      await _player!.play(AssetSource('sounds/muyu.wav'));
    } catch (_) {
      // 无声胜有声：音频不可用不影响功德。
    }
  }

  void dispose() {
    _player?.dispose();
    _player = null;
  }
}
