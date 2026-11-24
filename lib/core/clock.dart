import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock.g.dart';

// The phone's current time; tests override it to pin "today".
@Riverpod(keepAlive: true)
DateTime Function() clock(Ref ref) => DateTime.now;

// The phone's calendar day as a UTC midnight (as cycle_rules' calendarDay).
// Re-read at local midnight and on resume, since the OS may suspend the app
// past the timer.
@Riverpod(keepAlive: true)
class Today extends _$Today {
  Timer? _timer;

  @override
  DateTime build() {
    final listener = AppLifecycleListener(onResume: _refresh);
    ref.onDispose(() {
      _timer?.cancel();
      listener.dispose();
    });
    return _read();
  }

  DateTime _read() {
    final now = ref.read(clockProvider)();
    _timer?.cancel();
    // A second past midnight, so a slightly early timer lands on the new day.
    final next = DateTime(now.year, now.month, now.day + 1, 0, 0, 1);
    _timer = Timer(next.difference(now), _refresh);
    return DateTime.utc(now.year, now.month, now.day);
  }

  void _refresh() => state = _read();
}
