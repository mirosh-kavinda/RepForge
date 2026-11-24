import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/core/clock.dart';
import 'package:repforge/core/metrics/adherence.dart' as m;
import 'package:repforge/features/progress/data/providers.dart';
import 'package:repforge/features/progress/domain/adherence_rules.dart';
import 'package:repforge/features/schedule/domain/cycle.dart';
import 'package:repforge/features/schedule/domain/day_record.dart';

import '../../../helpers/app_overrides.dart';
import '../../schedule/fake_cycle_repository.dart';
import '../../schedule/fake_day_record_repository.dart';

DateTime d(int day) => DateTime.utc(2026, 11, day);

DayRecord rec(DateTime date, DayStatus s, String dayId, int i) => DayRecord(
  id: 'r${date.day}',
  cycleId: 'c',
  date: date,
  dayId: dayId,
  dayIndex: i,
  status: s,
);

// Train, Train, Rest from Nov 20: 20 done, 21 done, 22 rest, 23 done, so
// today (24) is row 1, training.
final cycle = Cycle(
  id: 'c',
  name: 'Two on',
  days: const [
    CycleDay(id: 'a', workoutId: 'w-a'),
    CycleDay(id: 'b', workoutId: 'w-b'),
    CycleDay(id: 'off'),
  ],
  isActive: true,
  startDate: d(20),
  startDayIndex: 0,
);

Future<void> settle() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

Future<(ProviderContainer, FakeDayRecordRepository)> start() async {
  final days = FakeDayRecordRepository([
    rec(d(20), DayStatus.done, 'a', 0),
    rec(d(21), DayStatus.done, 'b', 1),
    rec(d(22), DayStatus.rest, 'off', 2),
    rec(d(23), DayStatus.done, 'a', 0),
  ]);
  final container = ProviderContainer(
    overrides: [
      ...signedInOverrides(cycles: FakeCycleRepository([cycle]), days: days),
      clockProvider.overrideWithValue(() => DateTime(2026, 11, 24, 8)),
    ],
  );
  addTearDown(container.dispose);
  container
    ..listen(adherenceProvider, (_, _) {})
    ..listen(streakProvider, (_, _) {});
  await settle();
  return (container, days);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PRG-02 adherence providers', () {
    test('AC4 AC9 skipping today updates streak and adherence', () async {
      final (container, days) = await start();
      expect(container.read(streakProvider).value, 4);
      final before = container.read(adherenceProvider).value!;
      expect((before.done, before.planned), (3, 3));
      expect(before.bestStreak, 4);

      await days.skip(cycleId: 'c', date: d(24), dayId: 'b', dayIndex: 1);
      await settle();
      final after = container.read(adherenceProvider).value!;
      expect((after.done, after.planned), (3, 4));
      expect(after.missed.single.skipped, isTrue);
      expect(after.missed.single.workoutId, 'w-b');
      expect(container.read(streakProvider).value, 4);
    });

    test('AC9 resting today: neutral, not planned', () async {
      final (container, days) = await start();
      await days.restToday(cycleId: 'c', date: d(24), dayId: 'b', dayIndex: 1);
      await settle();
      final s = container.read(adherenceProvider).value!;
      expect((s.done, s.planned), (3, 3));
      expect(s.streak, 4);
    });

    test('AC9 moving today: neutral, not planned', () async {
      final (container, days) = await start();
      await days.move(
        cycleId: 'c',
        date: d(24),
        dayId: 'b',
        dayIndex: 1,
        workoutId: 'w-b',
        to: d(25),
        toDayId: 'off',
        toDayIndex: 2,
      );
      await settle();
      final s = container.read(adherenceProvider).value!;
      expect((s.done, s.planned), (3, 3));
      expect(s.streak, 4);
      expect(s.missed, isEmpty);
    });
  });

  test('PRG-02 NFR-01 two years of history stays fast', () {
    final today = DateTime.utc(2026, 11, 24);
    final records = [
      for (var i = 730; i >= 0; i--)
        () {
          final date = today.subtract(Duration(days: i));
          final row = i % 3;
          return DayRecord(
            id: 'r$i',
            cycleId: 'c',
            date: date,
            dayId: ['a', 'b', 'off'][row],
            dayIndex: row,
            status: row == 2
                ? DayStatus.rest
                : (i % 11 == 0 ? DayStatus.missed : DayStatus.done),
          );
        }(),
    ];
    final watch = Stopwatch()..start();
    final h = dayHistory(
      records: records,
      activeCycleId: 'c',
      cycles: {'c': cycle},
      today: today,
      todayRow: null,
    );
    final s = adherenceSummary(h, from: null, today: today);
    watch.stop();
    expect(h, hasLength(731));
    expect(s.planned, greaterThan(400));
    expect(s.bestStreak, greaterThan(0));
    expect(h.last.status, isNot(m.DayStatus.pending));
    expect(watch.elapsedMilliseconds, lessThan(100));
  });
}
