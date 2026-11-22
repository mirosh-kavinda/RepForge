import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/features/schedule/domain/cycle.dart';
import 'package:repforge/features/schedule/domain/cycle_rules.dart';

CycleDay d(String id, [String? w]) => CycleDay(id: id, workoutId: w);

final ppl = [d('1', 'push'), d('2', 'pull'), d('3', 'legs'), d('4')];

Cycle cycle(List<CycleDay> days, {DateTime? start, int index = 0}) => Cycle(
  id: 'c',
  name: 'PPL',
  days: days,
  isActive: true,
  startDate: calendarDay(start ?? DateTime(2026, 11, 21)),
  startDayIndex: index,
);

void main() {
  group('SCH-01 save rules', () {
    test('AC2 name 1–40, 1–14 days, at least one training day', () {
      expect(saveProblem('', ppl), SaveProblem.name);
      expect(saveProblem('a' * 41, ppl), SaveProblem.name);
      expect(saveProblem('💪' * 40, ppl), isNull, reason: 'counts characters');
      expect(saveProblem(' PPL ', []), SaveProblem.noDays);
      expect(saveProblem('Rest', [d('1'), d('2')]), SaveProblem.noTraining);
      expect(saveProblem('PPL', ppl), isNull);
      expect(saveProblem('Daily', [d('1', 'full')]), isNull, reason: 'edge');
    });

    test('AC1 AC2 counts and the 14-day cap', () {
      expect(dayCounts(ppl), (train: 3, rest: 1));
      var days = <CycleDay>[];
      for (var i = 0; i < 20; i++) {
        days = addDay(days, workoutId: i.isEven ? 'w' : null);
      }
      expect(days, hasLength(14));
      expect(canAddDay(days), isFalse);
      expect(days.map((x) => x.id).toSet(), hasLength(14));
    });

    test('AC3 change, rest, remove and move', () {
      expect(setWorkout(ppl, 3, 'push')[3].workoutId, 'push');
      expect(setWorkout(ppl, 0, null)[0].isRest, isTrue);
      expect(removeDay(ppl, 1).map((x) => x.id), ['1', '3', '4']);
      expect(moveDay(ppl, 0, 2).map((x) => x.id), ['2', '3', '1', '4']);
      expect(moveDay(ppl, 3, 0).map((x) => x.id), ['4', '1', '2', '3']);
    });
  });

  group('SCH-01 preview', () {
    test('AC4 preview: next 8 dates from today', () {
      final p = preview(4, 2, DateTime(2026, 11, 21, 15));
      expect(p, hasLength(8));
      expect(p.first.date, DateTime.utc(2026, 11, 21));
      expect(p.map((x) => x.dayIndex), [2, 3, 0, 1, 2, 3, 0, 1]);
    });
  });

  group('SCH-02 re-anchor after editing the active cycle', () {
    final today = DateTime(2026, 11, 23);
    // Today rolled to index 2 = legs, wherever the calendar would say.
    final old = cycle(ppl);

    test('AC12 today follows its row through a reorder', () {
      final moved = moveDay(ppl, 2, 0); // legs first
      final a = reanchor(old, moved, 2, today);
      expect(a.startDate, DateTime.utc(2026, 11, 23));
      expect(moved[a.startDayIndex].id, '3');
    });

    test('AC12 uses the rolled index, not calendar days', () {
      final a = reanchor(old, moveDay(ppl, 0, 3), 0, today);
      expect(moveDay(ppl, 0, 3)[a.startDayIndex].id, '1');
    });

    test('AC12 a removed row leaves today at that position, clamped', () {
      expect(reanchor(old, removeDay(ppl, 2), 2, today).startDayIndex, 2);
      final short = [d('1', 'push'), d('9', 'x')];
      expect(reanchor(old, short, 2, today).startDayIndex, 1);
    });
  });

  group('SCH-03 weekday rules', () {
    // Monday … Sunday, stored Monday first.
    final week = [
      for (final (i, w) in [
        'push',
        'pull',
        null,
        'legs',
        null,
        'full',
        null,
      ].indexed)
        d('$i', w),
    ];
    const sundayFirst = 0, mondayFirst = 1;

    test("AC5 a date's row is its ISO weekday, Monday = 0", () {
      expect(weekdayRow(DateTime(2026, 11, 23)), 0, reason: 'Monday');
      expect(weekdayRow(DateTime(2026, 11, 22, 23, 59)), 6, reason: 'Sunday');
      expect(weekdayRow(DateTime(2026, 11, 21)), 5, reason: 'Saturday');
    });

    test('AC2 Weekdays needs exactly 7 days, also checked on save', () {
      expect(canUseWeekdays(week), isTrue);
      expect(canUseWeekdays(ppl), isFalse);
      expect(canUseWeekdays([...week, d('x')]), isFalse);
      expect(
        saveProblem('PPL', ppl, mode: CycleMode.weekdays),
        SaveProblem.notSevenDays,
      );
      expect(saveProblem('PPL', week, mode: CycleMode.weekdays), isNull);
      expect(saveProblem('PPL', ppl), isNull, reason: 'rolling unchanged');
    });

    test('edge all seven Rest cannot be saved', () {
      expect(
        saveProblem('Off', [
          for (var i = 0; i < 7; i++) d('$i'),
        ], mode: CycleMode.weekdays),
        SaveProblem.noTraining,
      );
    });

    test("AC3 display order starts on the locale's first weekday", () {
      expect(rotate(week, mondayFirst).map((x) => x.id), [
        '0', '1', '2', '3', '4', '5', '6', //
      ]);
      expect(rotate(week, sundayFirst).map((x) => x.id), [
        '6', '0', '1', '2', '3', '4', '5', //
      ]);
      expect(unrotate(rotate(week, sundayFirst), sundayFirst), week);
    });

    test('AC3 display and stored indexes map both ways', () {
      expect(storedIndex(0, sundayFirst), 6);
      expect(storedIndex(1, sundayFirst), 0);
      expect(storedIndex(0, mondayFirst), 0);
      for (final f in [sundayFirst, mondayFirst, 6]) {
        for (var i = 0; i < 7; i++) {
          expect(displayIndex(storedIndex(i, f), f), i);
        }
      }
    });

    test('AC4 a move in display order moves the workout to that weekday', () {
      // Sunday-first: drag Sunday (display 0) to the Tuesday row (display 2).
      final moved = moveDisplayed(week, 0, 2, sundayFirst);
      expect(moved, hasLength(7));
      expect(moved[1].id, '6', reason: "Sunday's row now on Tuesday");
      expect(rotate(moved, sundayFirst)[2].id, '6');
      expect(moveDisplayed(week, 0, 2, mondayFirst), moveDay(week, 0, 2));
    });

    test("AC9 switching mode anchors on today's weekday row", () {
      final a = anchorOnWeekday(DateTime(2026, 11, 25, 20));
      expect(a, (startDate: DateTime.utc(2026, 11, 25), startDayIndex: 2));
    });

    test('AC3 the weekday preview follows the calendar', () {
      final today = DateTime(2026, 11, 22); // Sunday
      final p = preview(7, weekdayRow(today), today);
      expect(p.map((x) => x.dayIndex), [6, 0, 1, 2, 3, 4, 5, 6]);
      for (final x in p) {
        expect(x.dayIndex, weekdayRow(x.date));
      }
    });
  });
}
