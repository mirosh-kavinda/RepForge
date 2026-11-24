import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/core/metrics/adherence.dart';
import 'package:repforge/core/metrics/estimate.dart';

const done = DayStatus.done;
const rest = DayStatus.rest;
const missed = DayStatus.missed;
const skipped = DayStatus.skipped;
const moved = DayStatus.moved;
const pending = DayStatus.pending;
const unplannedRest = DayStatus.unplannedRest;

void main() {
  group('FND-04 adherence', () {
    test('AC8 done ÷ planned training days', () {
      expect(
        adherence(const [done, rest, done, missed, done, rest]),
        const Estimated(75.0),
      );
    });

    test('AC8 skipped counts against; rest, moved, pending do not', () {
      expect(
        adherence(const [done, skipped, rest, moved, pending]),
        const Estimated(50.0),
      );
    });

    test('edge: no planned training days is not enough data', () {
      expect(
        adherence(const [rest, rest, pending]),
        const NotEstimable<double>(EstimateReason.notEnoughData),
      );
      expect(
        adherence(const []),
        const NotEstimable<double>(EstimateReason.notEnoughData),
      );
    });
  });

  group('FND-04 cycle streak', () {
    test('AC8 done and rest extend it', () {
      expect(cycleStreak(const [done, rest, done, done]), 4);
    });

    test('AC8 a missed training day ends it', () {
      expect(cycleStreak(const [done, done, missed, done, rest]), 2);
      expect(cycleStreak(const [done, missed]), 0);
    });

    test('AC8 skipped and moved neither extend nor break it', () {
      expect(cycleStreak(const [done, skipped, rest, moved, done]), 3);
    });

    test('AC8 today not yet done does not break it', () {
      expect(cycleStreak(const [done, rest, done, pending]), 3);
    });

    test('edge: empty or single day', () {
      expect(cycleStreak(const []), 0);
      expect(cycleStreak(const [rest]), 1);
      expect(cycleStreak(const [pending]), 0);
    });
  });

  group('PRG-02 adherence and streaks', () {
    test('AC3 done and planned training days', () {
      expect(
        trainingDays(const [done, missed, skipped, rest, unplannedRest, done]),
        (done: 2, planned: 4),
      );
    });

    test('AC3 unplanned rest is not a planned training day', () {
      expect(
        adherence(const [done, unplannedRest, missed]),
        const Estimated(50.0),
      );
    });

    test('AC2 unplanned rest neither extends nor breaks the streak', () {
      expect(cycleStreak(const [done, unplannedRest, done]), 2);
    });

    test('AC4 best streak is the longest run, by the same rules', () {
      expect(bestCycleStreak(const []), 0);
      expect(
        bestCycleStreak(const [done, rest, done, missed, done, pending]),
        3,
      );
      expect(
        bestCycleStreak(const [done, missed, done, skipped, rest, moved, done]),
        3,
      );
      expect(bestCycleStreak(const [missed, missed]), 0);
    });

    test('AC4 best equals current when the current run is longest', () {
      const days = [done, missed, done, rest, unplannedRest, done, pending];
      expect(bestCycleStreak(days), cycleStreak(days));
      expect(cycleStreak(days), 3);
    });
  });
}
