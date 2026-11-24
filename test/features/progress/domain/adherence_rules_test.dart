import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/core/metrics/adherence.dart' as m;
import 'package:repforge/core/metrics/estimate.dart';
import 'package:repforge/features/progress/domain/adherence_rules.dart';
import 'package:repforge/features/schedule/domain/cycle.dart';
import 'package:repforge/features/schedule/domain/day_record.dart';

DateTime d(int day, [int month = 11]) => DateTime.utc(2026, month, day);

final cycle = Cycle(
  id: 'c',
  name: 'PPL',
  days: const [
    CycleDay(id: 'push', workoutId: 'w-push'),
    CycleDay(id: 'pull', workoutId: 'w-pull'),
    CycleDay(id: 'off'),
  ],
  isActive: true,
  startDate: d(1),
  startDayIndex: 0,
);

DayRecord r(
  DateTime date,
  DayStatus status, {
  String cycleId = 'c',
  String dayId = 'push',
  String? workoutId,
}) => DayRecord(
  id: '$cycleId-${date.day}-${date.month}',
  cycleId: cycleId,
  date: date,
  dayId: dayId,
  dayIndex: 0,
  status: status,
  workoutId: workoutId,
);

List<DatedStatus> history(
  List<DayRecord> records, {
  TodayRow? today = const (isRest: false, workoutId: 'w-push'),
}) => dayHistory(
  records: records,
  activeCycleId: 'c',
  cycles: {'c': cycle},
  today: d(24),
  todayRow: today,
);

void main() {
  group('PRG-02 day history', () {
    test('AC2 AC3 schedule statuses map onto the metrics', () {
      final h = history([
        r(d(17), DayStatus.done),
        r(d(18), DayStatus.missed),
        r(d(19), DayStatus.rest, dayId: 'off'),
        r(d(20), DayStatus.skipped),
        r(d(21), DayStatus.unplannedRest),
        r(d(22), DayStatus.moved),
      ]);
      expect(
        [for (final x in h) x.status],
        [
          m.DayStatus.done,
          m.DayStatus.missed,
          m.DayStatus.rest,
          m.DayStatus.skipped,
          m.DayStatus.unplannedRest,
          m.DayStatus.moved,
          m.DayStatus.pending,
        ],
      );
      expect(h.last.date, d(24));
    });

    test('AC2 today: its record, else pending training or rest', () {
      expect(
        history([r(d(24), DayStatus.done)]).single.status,
        m.DayStatus.done,
      );
      expect(
        history([r(d(24), DayStatus.planned)]).single.status,
        m.DayStatus.pending,
      );
      expect(
        history(
          const [],
          today: const (isRest: true, workoutId: null),
        ).single.status,
        m.DayStatus.rest,
      );
      expect(history(const [], today: null), isEmpty);
    });

    test('edge future records are left out', () {
      final h = history([r(d(26), DayStatus.planned)]);
      expect([for (final x in h) x.date], [d(24)]);
    });

    test('edge two cycles on a date: the active one wins', () {
      final h = history([
        r(d(20), DayStatus.missed, cycleId: 'old'),
        r(d(20), DayStatus.done),
        r(d(21), DayStatus.rest, cycleId: 'old'),
      ]);
      expect(
        [for (final x in h) x.status],
        [m.DayStatus.done, m.DayStatus.rest, m.DayStatus.pending],
      );
    });

    test('edge a done rest day counts as done', () {
      final h = history([r(d(23), DayStatus.done, dayId: 'off')]);
      expect(h.first.status, m.DayStatus.done);
    });

    test('AC6 the workout: the record\'s, else the cycle row\'s', () {
      final h = history([
        r(d(20), DayStatus.missed, dayId: 'pull'),
        r(d(21), DayStatus.skipped, workoutId: 'w-legs'),
      ]);
      expect(h[0].workoutId, 'w-pull');
      expect(h[1].workoutId, 'w-legs');
    });
  });

  group('PRG-02 adherence summary', () {
    DatedStatus x(DateTime date, m.DayStatus s, [String? w]) =>
        (date: date, status: s, workoutId: w);

    test('AC3 AC4 percentage, counts and streaks', () {
      final s = adherenceSummary(
        [
          x(d(2), m.DayStatus.done),
          x(d(3), m.DayStatus.done),
          x(d(4), m.DayStatus.rest),
          x(d(5), m.DayStatus.missed, 'w-push'),
          x(d(16), m.DayStatus.done),
          x(d(17), m.DayStatus.rest),
          x(d(18), m.DayStatus.skipped, 'w-pull'),
          x(d(19), m.DayStatus.done),
          x(d(24), m.DayStatus.pending),
        ],
        from: d(10),
        today: d(24),
      );
      expect(s.done, 2);
      expect(s.planned, 3);
      expect((s.percent as Estimated<double>).value, closeTo(66.7, 0.1));
      expect(s.streak, 3);
      expect(s.bestStreak, 3);
    });

    test('AC4 best streak looks past the range', () {
      final s = adherenceSummary(
        [
          for (var i = 1; i <= 5; i++) x(d(i, 9), m.DayStatus.done),
          x(d(10), m.DayStatus.missed),
          x(d(20), m.DayStatus.done),
        ],
        from: d(1),
        today: d(24),
      );
      expect(s.streak, 1);
      expect(s.bestStreak, 5);
    });

    test('AC5 a bar per Monday week; a week with nothing planned has none', () {
      final s = adherenceSummary(
        [
          x(d(2), m.DayStatus.done),
          x(d(3), m.DayStatus.missed),
          x(d(10), m.DayStatus.rest),
          x(d(17), m.DayStatus.done),
        ],
        from: d(1),
        today: d(24),
      );
      // Edge: weeks start at the first recorded day's, not the range's.
      expect([for (final w in s.weeks) w.week], [d(2), d(9), d(16), d(23)]);
      expect([for (final w in s.weeks) w.percent], [50, null, 100, null]);
    });

    test('AC6 missed and skipped, newest first', () {
      final s = adherenceSummary(
        [
          x(d(5), m.DayStatus.missed, 'a'),
          x(d(1, 9), m.DayStatus.missed, 'old'),
          x(d(18), m.DayStatus.skipped, 'b'),
          x(d(19), m.DayStatus.done),
        ],
        from: d(1),
        today: d(24),
      );
      expect(
        [for (final x in s.missed) (x.date, x.skipped, x.workoutId)],
        [(d(18), true, 'b'), (d(5), false, 'a')],
      );
    });

    test('AC7 nothing planned: not enough data and no bars', () {
      final s = adherenceSummary(
        [x(d(20), m.DayStatus.rest), x(d(24), m.DayStatus.pending)],
        from: d(1),
        today: d(24),
      );
      expect(s.percent, isA<NotEstimable<double>>());
      expect(s.weeks, isEmpty);
      expect(s.missed, isEmpty);
    });

    test('AC3 all-time range starts at the first day', () {
      final s = adherenceSummary(
        [x(d(18), m.DayStatus.done)],
        from: null,
        today: d(24),
      );
      expect(s.weeks.first.week, d(16));
      expect(s.planned, 1);
    });
  });
}
