import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/app.dart';
import 'package:repforge/core/clock.dart';
import 'package:repforge/features/home/presentation/streak_chip.dart';
import 'package:repforge/features/library/data/providers.dart';
import 'package:repforge/features/progress/data/providers.dart';
import 'package:repforge/features/progress/presentation/progress_screen.dart';
import 'package:repforge/features/schedule/domain/cycle.dart';
import 'package:repforge/features/schedule/domain/day_record.dart';

import '../../../helpers/app_overrides.dart';
import '../../library/library_fakes.dart';
import '../../schedule/fake_cycle_repository.dart';
import '../../schedule/fake_day_record_repository.dart';

DateTime d(int day) => DateTime.utc(2026, 11, day);

// Train, Train, Rest from Nov 20, so today (24) is row 1, training.
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

DayRecord rec(DateTime date, DayStatus s, String dayId, int i) => DayRecord(
  id: 'r${date.day}',
  cycleId: 'c',
  date: date,
  dayId: dayId,
  dayIndex: i,
  status: s,
);

final fourDays = [
  rec(d(20), DayStatus.done, 'a', 0),
  rec(d(21), DayStatus.done, 'b', 1),
  rec(d(22), DayStatus.rest, 'off', 2),
  rec(d(23), DayStatus.done, 'a', 0),
];

late FakeDayRecordRepository days;

Future<void> openHome(
  WidgetTester tester, {
  List<Cycle> cycles = const [],
  List<DayRecord> records = const [],
  double textScale = 1,
  bool failing = false,
}) async {
  days = FakeDayRecordRepository(records);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...signedInOverrides(cycles: FakeCycleRepository(cycles), days: days),
        exerciseCatalogProvider.overrideWith((ref) async => LibraryCatalog()),
        clockProvider.overrideWithValue(() => DateTime(2026, 11, 24, 8)),
        if (failing)
          statusHistoryProvider.overrideWithValue(
            AsyncError(StateError('db'), StackTrace.empty),
          ),
      ],
      child: MediaQuery.withClampedTextScaling(
        minScaleFactor: textScale,
        maxScaleFactor: textScale,
        child: const RepForgeApp(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('PRG-02 streak chip', () {
    testWidgets('AC1 shows the streak; tapping opens Progress', (tester) async {
      await openHome(tester, cycles: [cycle], records: fourDays);
      expect(find.text('4-day streak'), findsOneWidget);
      await tester.tap(find.byKey(StreakChip.chipKey));
      await tester.pumpAndSettle();
      expect(find.byType(ProgressScreen), findsOneWidget);
    });

    testWidgets('AC1 a streak of 0 invites a start', (tester) async {
      await openHome(
        tester,
        cycles: [cycle],
        records: [rec(d(23), DayStatus.missed, 'a', 0)],
      );
      expect(find.text('Start a streak today'), findsOneWidget);
    });

    testWidgets('AC1 no schedule history: no chip', (tester) async {
      await openHome(tester);
      expect(find.byKey(StreakChip.chipKey), findsNothing);
    });

    testWidgets('a failing history hides the chip; Home still works', (
      tester,
    ) async {
      await openHome(tester, cycles: [cycle], records: fourDays, failing: true);
      expect(find.byKey(StreakChip.chipKey), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AC9 finishing today extends it at once', (tester) async {
      await openHome(tester, cycles: [cycle], records: fourDays);
      expect(find.text('4-day streak'), findsOneWidget);
      await days.markDone(cycleId: 'c', date: d(24), dayId: 'b', dayIndex: 1);
      await tester.pumpAndSettle();
      expect(find.text('5-day streak'), findsOneWidget);
    });

    testWidgets('NFR-06 labelled button, 48 dp, fits at 200 % text', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openHome(tester, cycles: [cycle], records: fourDays, textScale: 2);
      expect(tester.takeException(), isNull);
      expect(
        tester.getSemantics(find.byKey(StreakChip.chipKey)),
        matchesSemantics(
          label: '4-day streak',
          hint: 'Opens Progress',
          isButton: true,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSize(find.byKey(StreakChip.chipKey)).height,
        greaterThanOrEqualTo(48),
      );
      handle.dispose();
    });
  });
}
