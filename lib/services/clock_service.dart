import 'dart:async';

import 'package:flutter/foundation.dart';

/// 全局心跳：每秒广播一次当前时间，供时钟牌与跨日检测订阅。
class ClockService {
  ClockService({DateTime Function()? source})
      : _source = source ?? DateTime.now {
    _notifier = ValueNotifier<DateTime>(_source());
  }

  final DateTime Function() _source;
  late final ValueNotifier<DateTime> _notifier;
  Timer? _timer;

  ValueListenable<DateTime> get now => _notifier;

  void addListener(VoidCallback listener) => _notifier.addListener(listener);

  void removeListener(VoidCallback listener) =>
      _notifier.removeListener(listener);

  void start() {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      _notifier.value = _source();
    });
  }

  void dispose() {
    _timer?.cancel();
    _notifier.dispose();
  }
}

/// 同一自然日判断（忽略时分秒）。
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
