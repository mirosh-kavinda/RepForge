import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/core/metrics/adherence.dart';
import 'package:repforge/core/metrics/estimate.dart';

const done = DayStatus.done;
const rest = DayStatus.rest;
const missed = DayStatus.missed;
const skipped = DayStatus.skipped;
const moved = DayStatus.moved;
const pending = DayStatus.pending;

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
}
