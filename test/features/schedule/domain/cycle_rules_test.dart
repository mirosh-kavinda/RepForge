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

  group('SCH-01 where today is', () {
    test('AC7 start day plus calendar days, wrapped by length', () {
      final c = cycle(ppl, index: 1);
      expect(dayIndexOn(c, DateTime(2026, 11, 21, 23, 59)), 1);
      expect(dayIndexOn(c, DateTime(2026, 11, 22, 0, 1)), 2);
      expect(dayIndexOn(c, DateTime(2026, 11, 24)), 0);
      expect(dayIndexOn(c, DateTime(2026, 12, 25)), (1 + 34) % 4);
    });

    test('edge before the start date still wraps forward', () {
      expect(dayIndexOn(cycle(ppl), DateTime(2026, 11, 20)), 3);
    });

    test('edge DST change does not move the day', () {
      // Europe DST ends 25 Oct 2026; a 25-hour day must still count as one.
      final c = cycle(ppl, start: DateTime(2026, 10, 24));
      expect(dayIndexOn(c, DateTime(2026, 10, 26)), 2);
    });

    test('AC4 preview: next 8 dates from today', () {
      final p = preview(4, 2, DateTime(2026, 11, 21, 15));
      expect(p, hasLength(8));
      expect(p.first.date, DateTime.utc(2026, 11, 21));
      expect(p.map((x) => x.dayIndex), [2, 3, 0, 1, 2, 3, 0, 1]);
    });
  });

  group('SCH-01 re-anchor after editing the active cycle', () {
    final today = DateTime(2026, 11, 23); // index 2 = legs
    final old = cycle(ppl);

    test('AC8 today follows its row through a reorder', () {
      final moved = moveDay(ppl, 2, 0); // legs first
      final a = reanchor(old, moved, today);
      expect(a.startDate, DateTime.utc(2026, 11, 23));
      expect(moved[a.startDayIndex].id, '3');
    });

    test('AC8 a removed row leaves today at that position, clamped', () {
      expect(reanchor(old, removeDay(ppl, 2), today).startDayIndex, 2);
      final short = [d('1', 'push'), d('9', 'x')];
      expect(reanchor(old, short, today).startDayIndex, 1);
    });
  });
}
