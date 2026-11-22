import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/features/schedule/domain/cycle.dart';
import 'package:repforge/features/schedule/domain/cycle_rules.dart';
import 'package:repforge/features/schedule/domain/day_record.dart';
import 'package:repforge/features/schedule/domain/rolling.dart';

CycleDay d(String id, [String? w]) => CycleDay(id: id, workoutId: w);

// Push, Pull, Rest, Legs.
final days = [d('1', 'push'), d('2', 'pull'), d('3'), d('4', 'legs')];

// Anchored Sat 21 Nov 2026 on day 1 (Push).
Cycle cycle({List<CycleDay>? rows, int index = 0, String id = 'c'}) => Cycle(
  id: id,
  name: 'PPL',
  days: rows ?? days,
  isActive: true,
  startDate: DateTime.utc(2026, 11, 21),
  startDayIndex: index,
);

DateTime nov(int day, [int hour = 10]) => DateTime(2026, 11, day, hour);

DayRecord rec(
  int day,
  String dayId, {
  DayStatus status = DayStatus.done,
  String cycleId = 'c',
}) => DayRecord(
  id: 'r$day$dayId$cycleId',
  cycleId: cycleId,
  date: DateTime.utc(2026, 11, day),
  dayId: dayId,
  dayIndex: days.indexWhere((x) => x.id == dayId),
  status: status,
);

void main() {
  group('SCH-02 rolling forward', () {
    test('AC1 on the anchor date today is the chosen day, not done', () {
      expect(
        rollForward(cycle(), const [], nov(21)),
        const CycleToday(index: 0, doneToday: false, missedDays: 0, next: 1),
      );
    });

    test("AC2 a done record for today on today's row marks it done", () {
      final t = rollForward(cycle(), [rec(21, '1')], nov(21, 23));
      expect((t.index, t.doneToday, t.next), (0, true, 1));
    });

    test('AC4 done on day n moves to day n+1 the next calendar day', () {
      final t = rollForward(cycle(), [rec(21, '1')], nov(22, 0));
      expect((t.index, t.doneToday, t.missedDays), (1, false, 0));
    });

    test('AC4 wraps after the last day', () {
      final t = rollForward(cycle(index: 3), [rec(21, '4')], nov(22));
      expect((t.index, t.next), (0, 1));
    });

    test('AC5 a rest day passes on its own', () {
      // Sat Push done, Sun Pull done, Mon Rest (no tap) → Tue Legs.
      final t = rollForward(cycle(), [rec(21, '1'), rec(22, '2')], nov(24));
      expect((t.index, t.missedDays), (3, 0));
    });

    test('AC6 an undone training day waits and counts one missed', () {
      final t = rollForward(cycle(), const [], nov(22));
      expect((t.index, t.doneToday, t.missedDays), (0, false, 1));
    });

    test('AC7 several days away: still that day, missed per date', () {
      final t = rollForward(cycle(), const [], nov(24));
      expect((t.index, t.missedDays), (0, 3));
    });

    test('AC8 missed resets once the waiting day is done', () {
      // Missed Sat and Sun, Push done Mon → Tue is Pull, nothing missed.
      final t = rollForward(cycle(), [rec(23, '1')], nov(24));
      expect((t.index, t.missedDays), (1, 0));
    });

    test('edge rest days are never counted as missed', () {
      // On the Rest row Sat; it passes; Sun Legs is missed.
      final t = rollForward(cycle(index: 2), const [], nov(23));
      expect((t.index, t.missedDays), (3, 1));
    });

    test('edge a missed record does not move the cycle', () {
      final t = rollForward(cycle(), [
        rec(21, '1', status: DayStatus.missed),
      ], nov(22));
      expect((t.index, t.missedDays), (0, 1));
    });

    test('edge a done record on a different row does not count', () {
      final t = rollForward(cycle(), [rec(21, '2')], nov(22));
      expect(t.index, 0);
      expect(rollForward(cycle(), [rec(21, '2')], nov(21)).doneToday, isFalse);
    });

    test('edge a one-day cycle: done today is the same day tomorrow', () {
      final one = cycle(rows: [d('1', 'push')]);
      final t = rollForward(one, [rec(21, '1')], nov(22));
      expect((t.index, t.doneToday, t.missedDays, t.next), (0, false, 0, 0));
    });

    test('edge the clock moving back never un-does a done day', () {
      final records = [rec(21, '1'), rec(22, '2')];
      expect(rollForward(cycle(), records, nov(23)).index, 2);
      final back = rollForward(cycle(), records, nov(22));
      expect((back.index, back.doneToday), (1, true));
    });

    test('edge before the anchor date today is the anchor day', () {
      final t = rollForward(cycle(index: 2), [rec(20, '3')], nov(19));
      expect((t.index, t.doneToday, t.missedDays), (2, false, 0));
    });

    test('edge only the calendar date counts, not the clock or offset', () {
      expect(rollForward(cycle(), [rec(21, '1')], nov(21, 23)).index, 0);
      expect(rollForward(cycle(), [rec(21, '1')], nov(22, 0)).index, 1);
      // DST ends 25 Oct 2026 in Europe; a 25-hour day still counts as one.
      final c = cycle().copyWith(
        startDate: calendarDay(DateTime(2026, 10, 24)),
      );
      expect(rollForward(c, const [], DateTime(2026, 10, 26)).missedDays, 2);
    });

    test("AC11 other cycles' history does not move this one", () {
      final t = rollForward(cycle(), [rec(21, '1', cycleId: 'other')], nov(22));
      expect((t.index, t.missedDays), (0, 1));
    });

    test('AC11 records before the anchor date are ignored', () {
      final c = cycle().copyWith(startDate: DateTime.utc(2026, 11, 22));
      final t = rollForward(c, [rec(21, '1')], nov(22));
      expect((t.index, t.missedDays), (0, 0));
    });
  });

  group('SCH-02 settle', () {
    List<(int, String, DayStatus)> settled(
      Cycle c,
      List<DayRecord> r,
      DateTime now,
    ) => [for (final x in toSettle(c, r, now)) (x.date.day, x.dayId, x.status)];

    test('AC6 a passed undone training day is recorded missed', () {
      expect(settled(cycle(), const [], nov(22)), [
        (21, '1', DayStatus.missed),
      ]);
    });

    test('AC7 several days away: one missed record per passed date', () {
      expect(settled(cycle(), const [], nov(24)), [
        (21, '1', DayStatus.missed),
        (22, '1', DayStatus.missed),
        (23, '1', DayStatus.missed),
      ]);
    });

    test('AC5 a passed rest day is recorded rest; rest is never missed', () {
      expect(settled(cycle(), [rec(21, '1'), rec(22, '2')], nov(25)), [
        (23, '3', DayStatus.rest),
        (24, '4', DayStatus.missed),
      ]);
    });

    test('edge dates with a record and today are left alone', () {
      final r = [rec(21, '1')];
      expect(settled(cycle(), r, nov(21)), isEmpty);
      final once = toSettle(cycle(), r, nov(23));
      expect(settled(cycle(), [...r, ...once], nov(23)), isEmpty);
    });

    test('edge settle writes the cycle, row index and fresh ids', () {
      final out = toSettle(cycle(index: 2), const [], nov(23));
      expect(out.map((x) => (x.cycleId, x.dayIndex)), [('c', 2), ('c', 3)]);
      expect(out.map((x) => x.id).toSet(), hasLength(2));
    });

    test('edge the clock moving back settles nothing new', () {
      expect(settled(cycle(), const [], nov(19)), isEmpty);
    });

    test("AC11 other cycles' records do not count as present", () {
      expect(settled(cycle(), [rec(21, '1', cycleId: 'other')], nov(22)), [
        (21, '1', DayStatus.missed),
      ]);
    });
  });

  group('SCH-02 editing the active cycle', () {
    // Sat Push done, Sun Pull done today (index 1).
    final records = [rec(21, '1'), rec(22, '2')];
    final now = nov(22, 18);

    Cycle edited(List<CycleDay> rows) {
      final c = cycle();
      final a = reanchor(c, rows, rollForward(c, records, now).index, now);
      return c.copyWith(
        days: rows,
        startDate: a.startDate,
        startDayIndex: a.startDayIndex,
      );
    }

    test('AC12 edit keeps done by row', () {
      final c = edited(moveDay(days, 1, 3)); // Pull to the end
      final t = rollForward(c, records, now);
      expect((c.days[t.index].id, t.doneToday), ('2', true));
      // Tomorrow follows the new order: Pull was last, so Push.
      expect(rollForward(c, records, nov(23)).index, 0);
    });

    test('AC12 a removed today row shows not done and keeps history', () {
      final c = edited(removeDay(days, 1));
      final t = rollForward(c, records, now);
      expect((c.days[t.index].id, t.doneToday), ('3', false));
      expect(toSettle(c, records, now), isEmpty);
    });
  });

  group('SCH-02 read-only today', () {
    test('edge the clock behind the latest day seen locks today', () {
      final t = rollForward(
        cycle(),
        [rec(21, '1')],
        nov(21),
        latestSeen: nov(22),
      );
      expect((t.doneToday, t.readOnly), (true, true));
    });

    test('edge today already recorded missed is read-only', () {
      final t = rollForward(cycle(), [
        rec(21, '1', status: DayStatus.missed),
      ], nov(21));
      expect((t.doneToday, t.readOnly), (false, true));
    });

    test('AC1 AC2 today on or after the latest day seen is editable', () {
      expect(
        rollForward(cycle(), const [], nov(21), latestSeen: nov(21)).readOnly,
        isFalse,
      );
      expect(rollForward(cycle(), [rec(21, '1')], nov(21)).readOnly, isFalse);
    });
  });

  group('SCH-03 weekdays', () {
    // Mon Push, Tue Pull, Wed Rest, Thu Legs, Fri Rest, Sat Full, Sun Rest.
    final week = [
      d('mo', 'push'),
      d('tu', 'pull'),
      d('we'),
      d('th', 'legs'),
      d('fr'),
      d('sa', 'full'),
      d('su'),
    ];
    // Anchored Sat 21 Nov; the index is ignored in Weekdays.
    final c = cycle(rows: week, index: 3).copyWith(mode: CycleMode.weekdays);
    DayRecord wrec(int day, String dayId, [DayStatus s = DayStatus.done]) =>
        DayRecord(
          id: 'w$day',
          cycleId: 'c',
          date: DateTime.utc(2026, 11, day),
          dayId: dayId,
          dayIndex: week.indexWhere((x) => x.id == dayId),
          status: s,
        );

    test("AC5 today is the date's weekday row, whatever came before", () {
      expect(rollForward(c, const [], nov(21)).index, 5, reason: 'Sat');
      expect(rollForward(c, const [], nov(23)).index, 0, reason: 'Mon');
      expect(rollForward(c, [wrec(23, 'mo')], nov(26)).index, 3, reason: 'Thu');
    });

    test('AC7 a missed day does not shift the week or carry over', () {
      final t = rollForward(c, const [], nov(24));
      expect((t.index, t.missedDays, t.next), (1, 0, 2));
    });

    test("AC6 done follows today's row; next is tomorrow's weekday", () {
      final t = rollForward(c, [wrec(23, 'mo')], nov(23, 20));
      expect((t.index, t.doneToday, t.next, t.readOnly), (0, true, 1, false));
      expect(rollForward(c, const [], nov(22)).next, 0, reason: 'Sun → Mon');
    });

    test('edge a done record on another row is not today done', () {
      expect(rollForward(c, [wrec(23, 'tu')], nov(23)).doneToday, isFalse);
    });

    test('AC7 settle: missed once per passed training date, rest never', () {
      final out = toSettle(c, [wrec(23, 'mo')], nov(26));
      expect(
        [for (final x in out) (x.date.day, x.dayId, x.status)],
        [
          (21, 'sa', DayStatus.missed),
          (22, 'su', DayStatus.rest),
          (24, 'tu', DayStatus.missed),
          (25, 'we', DayStatus.rest),
        ],
      );
      expect(out.map((x) => x.dayIndex), [5, 6, 1, 2]);
      expect(toSettle(c, [wrec(23, 'mo'), ...out], nov(26)), isEmpty);
    });

    test('edge the clock moving back is read-only and settles nothing', () {
      final t = rollForward(c, [wrec(23, 'mo')], nov(23), latestSeen: nov(24));
      expect((t.doneToday, t.readOnly), (true, true));
      expect(toSettle(c, const [], nov(19)), isEmpty);
    });

    test('edge today already recorded missed is read-only', () {
      final t = rollForward(c, [wrec(23, 'mo', DayStatus.missed)], nov(23));
      expect((t.doneToday, t.readOnly), (false, true));
    });
  });

  group('SCH-04 day actions in the walk', () {
    DayRecord act(
      int day,
      String dayId,
      DayStatus s, {
      String? workoutId,
      DateTime? linked,
    }) => rec(
      day,
      dayId,
      status: s,
    ).copyWith(workoutId: workoutId, linkedDate: linked);

    test('AC4 Rolling: a skipped day moves on to the next day', () {
      final t = rollForward(cycle(), [
        act(21, '1', DayStatus.skipped),
      ], nov(22));
      expect((t.index, t.missedDays), (1, 0));
    });

    test('AC5 Rolling: unplanned rest waits without counting missed', () {
      final r = [act(21, '1', DayStatus.unplannedRest)];
      final t = rollForward(cycle(), r, nov(22));
      expect((t.index, t.missedDays), (0, 0));
      // A later undone day still counts, from where it was.
      expect(rollForward(cycle(), r, nov(23)).missedDays, 1);
    });

    test('AC3 a swapped day marked done moves on like the planned one', () {
      final r = [act(21, '1', DayStatus.done, workoutId: 'pull')];
      expect(rollForward(cycle(), r, nov(22)).index, 1);
      final today = rollForward(cycle(), r, nov(21));
      expect((today.doneToday, today.record?.workoutId), (true, 'pull'));
    });

    test('AC2 a planned swap today is today\'s record, not done, editable', () {
      final t = rollForward(cycle(), [
        act(21, '1', DayStatus.planned, workoutId: 'pull'),
      ], nov(21));
      expect((t.doneToday, t.readOnly), (false, false));
      expect(t.record?.status, DayStatus.planned);
    });

    test('edge a passed planned swap counts as missed', () {
      final t = rollForward(cycle(), [
        act(21, '1', DayStatus.planned, workoutId: 'pull'),
      ], nov(22));
      expect((t.index, t.missedDays), (0, 1));
    });

    test('AC8 Train today on a rest row: the cycle moves on as for rest', () {
      final r = [act(21, '3', DayStatus.done, workoutId: 'push')];
      final c = cycle(index: 2);
      expect(rollForward(c, r, nov(21)).doneToday, isTrue);
      expect(rollForward(c, r, nov(22)).index, 3);
    });

    test('AC9 skipped, unplanned rest and moved today keep Undo open', () {
      for (final s in [
        DayStatus.skipped,
        DayStatus.unplannedRest,
        DayStatus.moved,
      ]) {
        final t = rollForward(cycle(), [act(21, '1', s)], nov(21));
        expect((t.readOnly, t.record?.status), (false, s));
      }
    });

    test('edge a record on a removed row is not today\'s action', () {
      final t = rollForward(cycle(), [
        act(21, 'gone', DayStatus.skipped),
      ], nov(21));
      expect(t.record, isNull);
    });

    test(
      'edge settle: passed planned becomes missed, or rest on a rest row',
      () {
        final r = [
          act(21, '1', DayStatus.planned, workoutId: 'pull'),
          act(22, '1', DayStatus.done),
          act(23, '2', DayStatus.skipped),
        ];
        final c = cycle();
        final out = toSettle(c, r, nov(25));
        expect(
          [for (final x in out) (x.date.day, x.status, x.workoutId)],
          [(21, DayStatus.missed, 'pull'), (24, DayStatus.rest, null)],
        );
        expect(out.first.id, 'r211c', reason: 'replaces the planned record');
        final rest = toSettle(cycle(index: 2), [
          act(21, '3', DayStatus.planned, workoutId: 'push'),
        ], nov(22));
        expect(rest.single.status, DayStatus.rest);
      },
    );

    test('AC6 Weekdays: skipped and unplanned rest just pass', () {
      final week = cycle(
        rows: [for (var i = 0; i < 7; i++) d('$i', i.isEven ? 'push' : null)],
      ).copyWith(mode: CycleMode.weekdays);
      final t = rollForward(week, [act(21, '5', DayStatus.skipped)], nov(22));
      expect((t.index, t.missedDays), (6, 0));
    });

    test(
      'edge settle: a passed moved-in date is missed for the moved workout',
      () {
        final week = cycle(
          rows: [
            for (var i = 0; i < 7; i++) d('w$i', i.isEven ? 'push' : null),
          ],
        ).copyWith(mode: CycleMode.weekdays);
        // Sat 21 is row 5 (rest); Push was moved in from Thursday.
        final out = toSettle(week, [
          DayRecord(
            id: 'm',
            cycleId: 'c',
            date: DateTime.utc(2026, 11, 21),
            dayId: 'w5',
            dayIndex: 5,
            status: DayStatus.planned,
            workoutId: 'push',
            linkedDate: DateTime.utc(2026, 11, 19),
          ),
        ], nov(22));
        expect((out.single.id, out.single.status), ('m', DayStatus.missed));
      },
    );
  });
}
