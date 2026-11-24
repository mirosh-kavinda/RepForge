import 'package:flutter_riverpod/misc.dart';
import 'package:repforge/core/clock.dart';

// Today without the midnight timer, for tests whose container outlives the
// widget tree (the timer would still be pending when the tree is disposed).
class StaticToday extends Today {
  @override
  DateTime build() {
    final now = ref.watch(clockProvider)();
    return DateTime.utc(now.year, now.month, now.day);
  }
}

Override get staticToday => todayProvider.overrideWith(StaticToday.new);
