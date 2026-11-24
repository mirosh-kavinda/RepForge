import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/features/schedule/domain/cycle.dart';
import 'package:repforge/features/schedule/domain/day_record.dart';
import 'package:repforge/features/schedule/domain/rolling.dart';
import 'package:repforge/features/settings/domain/reminder_rules.dart';

DateTime d(int day, [int month = 11]) => DateTime.utc(2026, month, day);

// Push, Pull, Rest from today (Tue Nov 24).
Cycle cycle({CycleMode mode = CycleMode.rolling, List<CycleDay>? days}) =>
    Cycle(
      id: 'c',
      name: 'PPR',
      days:
          days ??
          const [
            CycleDay(id: 'a', workoutId: 'push'),
            CycleDay(id: 'b', workoutId: 'pull'),
            CycleDay(id: 'off'),
          ],
      isActive: true,
      startDate: d(24),
      startDayIndex: 0,
      mode: mode,
    );

List<ReminderDay> run(Cycle c, [List<DayRecord> records = const []]) =>
    reminderDays(
      active: c,
      rolled: rollForward(c, records, d(24)),
      records: records,
      today: d(24),
    );

DayRecord today(DayStatus s) => DayRecord(
  id: 't',
  cycleId: 'c',
  date: d(24),
  dayId: 'a',
  dayIndex: 0,
  status: s,
);

void main() {
  group('SET-01 reminder days', () {
    test('AC8 training days over the next 14, none on rest days', () {
      final r = run(cycle());
      expect(r, hasLength(10));
      expect(r.first, (date: d(24), workoutId: 'push'));
      expect(r[1], (date: d(25), workoutId: 'pull'));
      expect(r.map((x) => x.date), isNot(contains(d(26))));
      expect(r.last.date, d(7, 12));
    });

    test('AC8 none today once done, skipped or rested', () {
      for (final s in [
        DayStatus.done,
        DayStatus.skipped,
        DayStatus.unplannedRest,
      ]) {
        final r = run(cycle(), [today(s)]);
        expect(r.first.date, d(25), reason: s.name);
      }
    });

    test('edge weekday-locked cycles remind on their weekdays', () {
      // Monday first: train Mon and Thu only.
      final c = cycle(
        mode: CycleMode.weekdays,
        days: const [
          CycleDay(id: 'mo', workoutId: 'push'),
          CycleDay(id: 'tu'),
          CycleDay(id: 'we'),
          CycleDay(id: 'th', workoutId: 'pull'),
          CycleDay(id: 'fr'),
          CycleDay(id: 'sa'),
          CycleDay(id: 'su'),
        ],
      );
      final r = run(c);
      expect([for (final x in r) x.date], [d(26), d(30), d(3, 12), d(7, 12)]);
    });

    test('edge no active cycle: nothing', () {
      expect(
        reminderDays(
          active: null,
          rolled: null,
          records: const [],
          today: d(24),
        ),
        isEmpty,
      );
    });
  });

  group('SET-01 review fixes', () {
    test('AC8 today moved: none today, one on the day it moved to', () {
      final c = cycle();
      final records = [
        DayRecord(
          id: 'm',
          cycleId: 'c',
          date: d(24),
          dayId: 'a',
          dayIndex: 0,
          status: DayStatus.moved,
          linkedDate: d(26),
        ),
        DayRecord(
          id: 'p',
          cycleId: 'c',
          date: d(26),
          dayId: 'off',
          dayIndex: 2,
          status: DayStatus.planned,
          workoutId: 'push',
          linkedDate: d(24),
        ),
      ];
      final r = run(c, records);
      expect(r.map((x) => x.date), isNot(contains(d(24))));
      expect(r.where((x) => x.date == d(26)).single.workoutId, 'push');
    });

    test('AC8 a swapped workout is the one reminded', () {
      final r = run(cycle(), [
        DayRecord(
          id: 's',
          cycleId: 'c',
          date: d(24),
          dayId: 'a',
          dayIndex: 0,
          status: DayStatus.planned,
          workoutId: 'legs',
        ),
      ]);
      expect(r.first, (date: d(24), workoutId: 'legs'));
    });
  });
}
