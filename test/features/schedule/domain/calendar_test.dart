import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/features/schedule/domain/calendar.dart';
import 'package:repforge/features/schedule/domain/cycle.dart';
import 'package:repforge/features/schedule/domain/day_record.dart';
import 'package:repforge/features/schedule/domain/rolling.dart';

DateTime nov(int d) => DateTime.utc(2026, 11, d);

// Push, Legs, Rest; anchored Mon 23 Nov on Push.
final ppl = Cycle(
  id: 'c1',
  name: 'PPL',
  days: const [
    CycleDay(id: 'd1', workoutId: 'push'),
    CycleDay(id: 'd2', workoutId: 'legs'),
    CycleDay(id: 'd3'),
  ],
  isActive: true,
  startDate: nov(23),
  startDayIndex: 0,
);

// Mon Push, Tue Legs, Wed Rest, Thu Push, Fri Rest, Sat Legs, Sun Rest.
final week = ppl.copyWith(
  id: 'w',
  mode: CycleMode.weekdays,
  days: [
    for (final (i, w) in [
      'push',
      'legs',
      null,
      'push',
      null,
      'legs',
      null,
    ].indexed)
      CycleDay(id: 'w$i', workoutId: w),
  ],
);

DayRecord rec(
  int day,
  String cycleId,
  String dayId,
  DayStatus s, {
  String? workoutId,
  DateTime? linked,
}) => DayRecord(
  id: '$cycleId$day',
  cycleId: cycleId,
  date: nov(day),
  dayId: dayId,
  dayIndex: 0,
  status: s,
  workoutId: workoutId,
  linkedDate: linked,
);

List<CalendarDay> month(
  Cycle? active,
  List<DayRecord> records, {
  int today = 23,
  int firstDay = 1,
  List<Cycle> others = const [],
}) => buildMonth(
  month: nov(1),
  firstDay: firstDay,
  today: nov(today),
  records: records,
  active: active,
  rolled: active == null ? null : rollForward(active, records, nov(today)),
  cycles: {
    for (final c in [?active, ...others]) c.id: c,
  },
);

CalendarDay on(List<CalendarDay> m, int day) =>
    m.firstWhere((d) => d.date == nov(day));

void main() {
  group('SCH-05 month grid', () {
    test('AC2 whole weeks from the locale first day (Monday)', () {
      final d = monthDates(nov(1), 1);
      expect(d.first, DateTime.utc(2026, 10, 26), reason: 'Mon before 1 Nov');
      expect(d.last, DateTime.utc(2026, 12, 6), reason: 'Sun after 30 Nov');
      expect(d.length % 7, 0);
    });

    test('AC2 Sunday-first weeks', () {
      final d = monthDates(nov(1), 0);
      expect(d.first, nov(1), reason: '1 Nov 2026 is a Sunday');
      expect(d.last, DateTime.utc(2026, 12, 5));
    });

    test('AC2 days outside the month are flagged', () {
      final m = month(ppl, const []);
      expect(m.first.inMonth, isFalse);
      expect(on(m, 1).inMonth, isTrue);
    });
  });

  group('SCH-05 history and plan', () {
    test('AC3 past dates show their recorded outcome; none shows empty', () {
      final m = month(ppl, [
        rec(20, 'c1', 'd1', DayStatus.done),
        rec(21, 'c1', 'd2', DayStatus.skipped),
      ]);
      expect(
        (on(m, 20).kind, on(m, 20).status, on(m, 20).workoutId),
        (CalendarKind.history, DayStatus.done, 'push'),
      );
      expect(on(m, 21).status, DayStatus.skipped);
      expect(on(m, 22).kind, CalendarKind.empty);
    });

    test('AC4 Rolling projects from today, each training day done', () {
      final m = month(ppl, const []);
      expect(
        [
          for (final d in [23, 24, 25, 26]) on(m, d).workoutId,
        ],
        ['push', 'legs', null, 'push'],
      );
      expect(on(m, 24).kind, CalendarKind.planned);
      expect(on(m, 23).isToday, isTrue);
    });

    test('AC4 an unplanned rest today shifts the projection by a day', () {
      final m = month(ppl, [rec(23, 'c1', 'd1', DayStatus.unplannedRest)]);
      expect(on(m, 23).status, DayStatus.unplannedRest);
      expect(on(m, 24).workoutId, 'push');
    });

    test('AC4 Weekdays plans by weekday; a moved-in workout replaces it', () {
      final m = month(week, [
        rec(23, 'w', 'w0', DayStatus.moved, workoutId: 'push', linked: nov(25)),
        rec(
          25,
          'w',
          'w2',
          DayStatus.planned,
          workoutId: 'push',
          linked: nov(23),
        ),
      ]);
      expect(on(m, 24).workoutId, 'legs');
      expect(
        (on(m, 25).kind, on(m, 25).workoutId, on(m, 25).record?.linkedDate),
        (CalendarKind.planned, 'push', nov(23)),
      );
      expect(on(m, 23).status, DayStatus.moved);
    });

    test('AC5 today shows its day action', () {
      final m = month(ppl, [
        rec(23, 'c1', 'd1', DayStatus.planned, workoutId: 'pull'),
      ]);
      expect(
        (on(m, 23).kind, on(m, 23).workoutId, on(m, 23).plannedWorkoutId),
        (CalendarKind.planned, 'pull', 'push'),
      );
    });

    test('edge two cycles on a date: the active one wins, both kept', () {
      final old = ppl.copyWith(id: 'old', isActive: false);
      final m = month(
        ppl,
        [
          rec(20, 'c1', 'd1', DayStatus.done),
          rec(20, 'old', 'd2', DayStatus.missed),
          rec(19, 'old', 'd2', DayStatus.missed),
          rec(19, 'x', 'd1', DayStatus.done),
        ],
        others: [old],
      );
      expect(on(m, 20).record?.cycleId, 'c1');
      expect(on(m, 20).records, hasLength(2));
      expect(on(m, 19).record?.cycleId, 'x', reason: 'last updated');
    });

    test('edge no active cycle: history only, nothing planned', () {
      final m = month(
        null,
        [rec(20, 'c1', 'd1', DayStatus.done)],
        others: [ppl],
      );
      expect(on(m, 20).workoutId, 'push');
      expect(on(m, 23).kind, CalendarKind.empty);
      expect(on(m, 24).kind, CalendarKind.empty);
    });

    test('edge a record of a cycle no longer saved keeps its status', () {
      final m = month(ppl, [rec(20, 'gone', 'd9', DayStatus.missed)]);
      expect((on(m, 20).status, on(m, 20).workoutId), (DayStatus.missed, null));
    });
  });
}
