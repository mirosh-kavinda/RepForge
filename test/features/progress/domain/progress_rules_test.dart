import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/core/metrics/estimate.dart';
import 'package:repforge/features/body/domain/body_snapshot.dart';
import 'package:repforge/features/logger/domain/session_repository.dart';
import 'package:repforge/features/logger/domain/workout_session.dart';
import 'package:repforge/features/progress/domain/progress_rules.dart';

DateTime d(int day, [int month = 11]) => DateTime.utc(2026, month, day);

LoggedSet s(double kg, {int? reps, int? seconds}) => LoggedSet(
  id: 'x',
  rowId: 'r',
  exerciseId: 'e',
  setNo: 1,
  kg: kg,
  reps: reps,
  seconds: seconds,
);

ExerciseLogEntry w(DateTime date, List<LoggedSet> sets) =>
    (date: date, sets: sets);

void main() {
  final today = d(24);

  group('PRG-01 progress rules', () {
    test('AC1 range starts', () {
      expect(rangeStart(ProgressRange.weeks4, today), d(28, 10));
      expect(rangeStart(ProgressRange.months3, today), d(26, 8));
      expect(
        rangeStart(ProgressRange.year1, today),
        DateTime.utc(2025, 11, 25),
      );
      expect(rangeStart(ProgressRange.all, today), isNull);
    });

    test('AC2 best e1RM per workout in range, oldest first', () {
      final r = strengthSeries([
        w(d(20), [s(100, reps: 5), s(90, reps: 8)]),
        w(d(1, 6), [s(80, reps: 5)]),
        w(d(10), [s(95, reps: 5)]),
      ], d(1));
      expect(r.measure, StrengthMeasure.e1rm);
      expect([for (final p in r.points) p.date], [d(10), d(20)]);
      expect(r.points.last.value, closeTo(100 * (1 + 5 / 30), 1e-9));
      expect(r.change, closeTo(5 * (1 + 5 / 30), 1e-9));
      expect(r.bestSet!.kg, 100);
      expect(r.best, r.points.last.value);
    });

    test('edge bodyweight and timed exercises fall back', () {
      final reps = strengthSeries([
        w(d(10), [s(0, reps: 10), s(0, reps: 12)]),
        w(d(20), [s(0, reps: 14)]),
      ], null);
      expect(reps.measure, StrengthMeasure.reps);
      expect([for (final p in reps.points) p.value], [12, 14]);
      expect(reps.bestSet!.reps, 14);
      final time = strengthSeries([
        w(d(10), [s(0, seconds: 45)]),
        w(d(20), [s(0, seconds: 60)]),
      ], null);
      expect(time.measure, StrengthMeasure.seconds);
      expect(time.change, 15);
    });

    test('edge a workout of only > 12-rep sets gives no e1RM point', () {
      final r = strengthSeries([
        w(d(10), [s(100, reps: 5)]),
        w(d(20), [s(60, reps: 15)]),
      ], null);
      expect(r.measure, StrengthMeasure.e1rm);
      expect(r.points, hasLength(1));
      expect(enoughForLine(r.points), isFalse);
      expect(r.bestSet!.kg, 100);
    });

    test('AC3 weekly volume, Monday weeks, empty weeks as 0', () {
      final v = weeklyVolume(
        [
          (date: d(10), set: s(100, reps: 5)),
          (date: d(12), set: s(50, reps: 10)),
          (date: d(24), set: s(60, reps: 10)),
          (date: d(24), set: s(0, seconds: 60)),
        ],
        d(9),
        today,
      );
      expect([for (final p in v) p.date], [d(9), d(16), d(23)]);
      expect([for (final p in v) p.value], [1000, 0, 600]);
    });

    test('AC3 all range starts at the first set; nothing gives no weeks', () {
      expect(weeklyVolume(const [], null, today), isEmpty);
      final v = weeklyVolume([(date: d(18), set: s(10, reps: 1))], null, today);
      expect(v.first.date, d(16));
    });

    test('AC4 weight and body fat lines; deleted left to the repository', () {
      final t = bodyTrends([
        BodySnapshot(
          id: 'b',
          date: d(20),
          weightKg: 81,
          results: {BodyMetric.bodyFat: const Estimated(18)},
        ),
        BodySnapshot(id: 'a', date: d(10), weightKg: 82),
        BodySnapshot(id: 'old', date: d(1, 1), weightKg: 90),
      ], d(1));
      expect(t.weight, [ChartPoint(d(10), 82), ChartPoint(d(20), 81)]);
      expect(t.bodyFat, [ChartPoint(d(20), 18)]);
      expect(changeOf(t.weight), -1);
      expect(changeOf(t.bodyFat), isNull);
    });

    test('AC4 body fat falls back to the scale reading', () {
      final t = bodyTrends([
        BodySnapshot(id: 'o', date: d(5), weightKg: 83, scaleBodyFatPct: 20),
        BodySnapshot(
          id: 'b',
          date: d(20),
          weightKg: 81,
          scaleBodyFatPct: 25,
          results: {BodyMetric.bodyFat: const Estimated(18)},
        ),
      ], d(1));
      expect(t.bodyFat, [ChartPoint(d(5), 20), ChartPoint(d(20), 18)]);
    });
  });
}
