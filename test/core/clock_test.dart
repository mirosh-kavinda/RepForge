import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/core/clock.dart';

void main() {
  group('SCH-02 today', () {
    late DateTime now;

    // Disposed in the test body: tearDown runs after the pending-timer check.
    ProviderContainer container() {
      final c = ProviderContainer(
        overrides: [clockProvider.overrideWithValue(() => now)],
      );
      return c;
    }

    testWidgets('AC4 AC5 AC6 is the calendar day as a UTC midnight', (
      tester,
    ) async {
      now = DateTime(2026, 11, 21, 23, 59);
      final c = container();
      expect(c.read(todayProvider), DateTime.utc(2026, 11, 21));
      c.dispose();
    });

    testWidgets('AC4 AC5 AC6 moves on at local midnight', (tester) async {
      now = DateTime(2026, 11, 21, 23, 59, 30);
      final c = container();
      final seen = <DateTime>[];
      c.listen(todayProvider, (_, v) => seen.add(v));
      expect(c.read(todayProvider), DateTime.utc(2026, 11, 21));

      now = DateTime(2026, 11, 22, 0, 0, 1);
      await tester.pump(const Duration(seconds: 32));
      expect(seen, [DateTime.utc(2026, 11, 22)]);

      // Re-armed for the following midnight.
      now = DateTime(2026, 11, 23, 0, 0, 1);
      await tester.pump(const Duration(days: 1));
      expect(seen.last, DateTime.utc(2026, 11, 23));
      c.dispose();
    });

    testWidgets('AC4 AC5 AC6 re-reads the day when the app resumes', (
      tester,
    ) async {
      now = DateTime(2026, 11, 21, 10);
      final c = container();
      expect(c.read(todayProvider), DateTime.utc(2026, 11, 21));

      // The OS suspended the app over midnight, so the timer never ran.
      now = DateTime(2026, 11, 24, 8);
      for (final s in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(s);
      }
      expect(c.read(todayProvider), DateTime.utc(2026, 11, 24));
      c.dispose();
    });
  });
}
