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

    test('AC2 a done record for today on today\'s row marks it done', () {
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

    test('AC11 other cycles\' history does not move this one', () {
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
}
