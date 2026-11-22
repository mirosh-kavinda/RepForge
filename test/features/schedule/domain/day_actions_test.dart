import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/features/schedule/domain/cycle.dart';
import 'package:repforge/features/schedule/domain/day_actions.dart';
import 'package:repforge/features/schedule/domain/day_record.dart';
import 'package:repforge/features/schedule/domain/rolling.dart';

// Mon Push, Tue Legs, Wed Rest, Thu Push, Fri Rest, Sat Legs, Sun Rest.
final week = Cycle(
  id: 'c',
  name: 'Week',
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
  isActive: true,
  startDate: DateTime.utc(2026, 11, 23),
  startDayIndex: 0,
);
final rolling = week.copyWith(mode: CycleMode.rolling);
final weekdays = week.copyWith(mode: CycleMode.weekdays);

DateTime nov(int day) => DateTime.utc(2026, 11, day);

DayRecord rec(int day, int row, DayStatus s, {String? w, DateTime? linked}) =>
    DayRecord(
      id: 'r$day',
      cycleId: 'c',
      date: nov(day),
      dayId: 'w$row',
      dayIndex: row,
      status: s,
      workoutId: w,
      linkedDate: linked,
    );

List<DayAction> actions(Cycle c, List<DayRecord> r, int day, {int first = 1}) {
  final today = rollForward(c, r, nov(day));
  return availableActions(
    c,
    today,
    moveTargets: moveTargets(c, r, nov(day), firstDay: first),
  );
}

void main() {
  group('SCH-04 day actions', () {
    test('AC1 a training day offers Swap, Skip, Unplanned rest', () {
      expect(actions(rolling, const [], 23), [
        DayAction.swap,
        DayAction.skip,
        DayAction.unplannedRest,
      ]);
    });

    test('AC1 AC7 Weekdays also offers Move while the week has days left', () {
      expect(actions(weekdays, const [], 23), [
        DayAction.swap,
        DayAction.skip,
        DayAction.unplannedRest,
        DayAction.move,
      ]);
    });

    test('AC8 a rest day offers Train today only', () {
      expect(actions(weekdays, const [], 25), [DayAction.trainToday]);
      final picked = [rec(25, 2, DayStatus.planned, w: 'push')];
      expect(actions(weekdays, picked, 25), [DayAction.trainToday]);
    });

    test('edge none once done, skipped, rested, moved or read-only', () {
      for (final s in [
        DayStatus.done,
        DayStatus.skipped,
        DayStatus.unplannedRest,
        DayStatus.moved,
        DayStatus.missed,
      ]) {
        expect(actions(weekdays, [rec(23, 0, s)], 23), isEmpty, reason: '$s');
      }
    });

    test('edge a planned swap can be swapped again; moved-in cannot', () {
      final swap = [rec(23, 0, DayStatus.planned, w: 'legs')];
      expect(actions(weekdays, swap, 23), contains(DayAction.swap));
      final movedIn = [
        rec(23, 0, DayStatus.planned, w: 'legs', linked: nov(22)),
      ];
      expect(actions(weekdays, movedIn, 23), isEmpty);
    });

    test(
      'AC7 Move targets: later dates in the locale week without a record',
      () {
        // Monday-first: Tue 24 … Sun 29; Thu 26 already has a move in.
        final r = [rec(26, 3, DayStatus.planned, w: 'legs', linked: nov(20))];
        expect(moveTargets(weekdays, r, nov(23), firstDay: 1), [
          nov(24),
          nov(25),
          nov(27),
          nov(28),
          nov(29),
        ]);
        // Sunday-first: the week of Mon 23 ends Sat 28.
        expect(
          moveTargets(weekdays, const [], nov(23), firstDay: 0).last,
          nov(28),
        );
      },
    );

    test('AC7 no Move on the last day of the week, or in Rolling', () {
      expect(moveTargets(weekdays, const [], nov(29), firstDay: 1), isEmpty);
      expect(moveTargets(weekdays, const [], nov(28), firstDay: 0), isEmpty);
      expect(moveTargets(rolling, const [], nov(23), firstDay: 1), isEmpty);
      expect(actions(weekdays, const [], 29), isNot(contains(DayAction.move)));
    });

    test('AC2 AC8 the workout today shows: the record\'s, else the row\'s', () {
      final t = rollForward(weekdays, const [], nov(23));
      expect(todayWorkoutId(weekdays, t), 'push');
      final swapped = rollForward(weekdays, [
        rec(23, 0, DayStatus.planned, w: 'legs'),
      ], nov(23));
      expect(todayWorkoutId(weekdays, swapped), 'legs');
      final rest = rollForward(weekdays, const [], nov(25));
      expect(todayWorkoutId(weekdays, rest), isNull);
    });
  });
}
