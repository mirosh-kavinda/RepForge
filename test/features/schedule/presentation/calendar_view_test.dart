import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/app.dart';
import 'package:repforge/app/theme/rf_scales.dart';
import 'package:repforge/core/clock.dart';
import 'package:repforge/features/library/data/providers.dart';
import 'package:repforge/features/schedule/domain/cycle.dart';
import 'package:repforge/features/schedule/domain/day_record.dart';
import 'package:repforge/features/schedule/presentation/calendar_view.dart';
import 'package:repforge/features/workout/data/starter_templates.dart';

import '../../../helpers/app_overrides.dart';
import '../../workout/fakes.dart';
import '../fake_cycle_repository.dart';
import '../fake_day_record_repository.dart';

late DateTime now;

final starters = [
  for (final t in starterTemplates) t.copyWith(id: t.name.toLowerCase()),
];

// Push, Legs, Rest; anchored Mon 23 Nov 2026 on Push.
final ppl = Cycle(
  id: 'c1',
  name: 'PPL',
  days: const [
    CycleDay(id: 'd1', workoutId: 'push'),
    CycleDay(id: 'd2', workoutId: 'legs'),
    CycleDay(id: 'd3'),
  ],
  isActive: true,
  startDate: DateTime.utc(2026, 11, 23),
  startDayIndex: 0,
);

DayRecord rec(int day, DayStatus s, {String dayId = 'd1', String c = 'c1'}) =>
    DayRecord(
      id: '$c$day',
      cycleId: c,
      date: DateTime.utc(2026, 11, day),
      dayId: dayId,
      dayIndex: 0,
      status: s,
    );

Future<void> openCalendar(
  WidgetTester tester, {
  List<Cycle>? cycles,
  List<DayRecord> records = const [],
  double textScale = 1,
  Size size = const Size(390, 844),
}) async {
  now = DateTime(2026, 11, 23, 10);
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = size;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...signedInOverrides(
          templates: FakeTemplateRepository(starters),
          cycles: FakeCycleRepository(cycles ?? [ppl]),
          days: FakeDayRecordRepository(records),
        ),
        exerciseCatalogProvider.overrideWith((ref) async => FakeCatalog()),
        clockProvider.overrideWithValue(() => now),
      ],
      child: MediaQuery.withClampedTextScaling(
        minScaleFactor: textScale,
        maxScaleFactor: textScale,
        child: const RepForgeApp(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Schedule'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Calendar'));
  await tester.pumpAndSettle();
}

Finder cell(String label) => find.bySemanticsLabel(RegExp('^$label'));

void main() {
  group('SCH-05 calendar', () {
    testWidgets('AC1 Schedule starts on Cycle; Calendar opens this month', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      now = DateTime(2026, 11, 23, 10);
      await openCalendar(tester);
      expect(find.text('November 2026'), findsOneWidget);
      expect(cell('Monday, November 23, today, Push, planned'), findsOneWidget);
      await tester.tap(find.text('Cycle'));
      await tester.pumpAndSettle();
      expect(find.text('November 2026'), findsNothing);
      expect(find.text('PPL'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('AC2 weeks start on the locale first day; months move', (
      tester,
    ) async {
      tester.platformDispatcher.localesTestValue = const [Locale('en', 'GB')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      await openCalendar(tester);
      final heads = tester
          .widgetList<Text>(find.text('Mon'))
          .followedBy(tester.widgetList<Text>(find.text('Sun')));
      expect(heads, isNotEmpty);
      final mon = tester.getTopLeft(find.text('Mon')).dx;
      final sun = tester.getTopLeft(find.text('Sun')).dx;
      expect(mon, lessThan(sun), reason: 'Monday first in en_GB');
      await tester.tap(find.byKey(CalendarView.prevKey));
      await tester.pumpAndSettle();
      expect(find.text('October 2026'), findsOneWidget);
      await tester.tap(find.byKey(CalendarView.thisMonthKey));
      await tester.pumpAndSettle();
      expect(find.text('November 2026'), findsOneWidget);
    });

    testWidgets('AC2 en_US weeks start on Sunday', (tester) async {
      await openCalendar(tester);
      final mon = tester.getTopLeft(find.text('Mon')).dx;
      final sun = tester.getTopLeft(find.text('Sun')).dx;
      expect(sun, lessThan(mon));
    });

    testWidgets('AC3 past dates show their outcome; none shows nothing', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openCalendar(
        tester,
        records: [
          rec(20, DayStatus.done),
          rec(19, DayStatus.missed, dayId: 'd2'),
          rec(18, DayStatus.skipped),
        ],
      );
      expect(cell('Friday, November 20, Push, Done'), findsOneWidget);
      expect(cell('Thursday, November 19, Legs, Missed'), findsOneWidget);
      expect(cell('Wednesday, November 18, Push, Skipped'), findsOneWidget);
      expect(find.bySemanticsLabel('Tuesday, November 17'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('AC4 coming dates show the plan, marked planned', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openCalendar(tester);
      expect(cell('Tuesday, November 24, Legs, planned'), findsOneWidget);
      expect(cell('Wednesday, November 25, Rest, planned'), findsOneWidget);
      expect(cell('Thursday, November 26, Push, planned'), findsOneWidget);
      handle.dispose();
    });

    testWidgets("AC5 today's day action shows as on Home", (tester) async {
      final handle = tester.ensureSemantics();
      await openCalendar(tester, records: [rec(23, DayStatus.skipped)]);
      expect(cell('Monday, November 23, today, Push, Skipped'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('AC6 tapping a date opens read-only details', (tester) async {
      await openCalendar(tester, records: [rec(20, DayStatus.done)]);
      await tester.tap(find.bySemanticsLabel(RegExp('^Friday, November 20')));
      await tester.pumpAndSettle();
      expect(find.text('Friday, November 20'), findsOneWidget);
      expect(find.text('Push · Done'), findsOneWidget);
      expect(find.text('Cycle: PPL'), findsOneWidget);
      expect(find.text('Mark done'), findsNothing);
    });

    testWidgets('edge no active cycle: history shows, says so', (tester) async {
      final handle = tester.ensureSemantics();
      await openCalendar(
        tester,
        cycles: [ppl.copyWith(isActive: false)],
        records: [rec(20, DayStatus.done)],
      );
      expect(
        find.text('No active cycle. Past days still show here.'),
        findsOneWidget,
      );
      expect(cell('Friday, November 20, Push, Done'), findsOneWidget);
      expect(find.bySemanticsLabel('Tuesday, November 24'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('edge midnight moves the today mark to the next date', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openCalendar(tester);
      now = DateTime(2026, 11, 24, 0, 1);
      for (final st in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(st);
      }
      await tester.pumpAndSettle();
      expect(cell('Tuesday, November 24, today'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('NFR-06 48 dp cells at 360 dp; fits at 200 % text', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openCalendar(tester, textScale: 2, size: const Size(360, 800));
      expect(tester.takeException(), isNull);
      final today = cell('Monday, November 23, today');
      final size = tester.getSize(today);
      expect(size.width, greaterThanOrEqualTo(RfSize.minTarget));
      expect(size.height, greaterThanOrEqualTo(RfSize.minTarget));
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      handle.dispose();
    });

    testWidgets('AC1 today is named in visible text', (tester) async {
      await openCalendar(tester);
      expect(
        find.text('Today: Monday, November 23, Push, planned'),
        findsOneWidget,
      );
      expect(find.text('Workout, planned'), findsOneWidget, reason: 'legend');
    });

    testWidgets('AC5 a swap or move today is worded as on Home', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openCalendar(
        tester,
        records: [rec(23, DayStatus.planned).copyWith(workoutId: 'pull')],
      );
      expect(
        cell('Monday, November 23, today, Pull, planned, Swapped from Push'),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
      final week = ppl.copyWith(
        mode: CycleMode.weekdays,
        days: [
          for (var i = 0; i < 7; i++)
            CycleDay(id: 'w$i', workoutId: i.isEven ? 'push' : null),
        ],
      );
      await openCalendar(
        tester,
        cycles: [week],
        records: [
          rec(
            23,
            DayStatus.moved,
            dayId: 'w0',
          ).copyWith(workoutId: 'push', linkedDate: DateTime.utc(2026, 11, 25)),
          rec(
            25,
            DayStatus.planned,
            dayId: 'w2',
          ).copyWith(workoutId: 'push', linkedDate: DateTime.utc(2026, 11, 23)),
        ],
      );
      expect(
        cell('Monday, November 23, today, Push, Moved, Moved to Wednesday'),
        findsOneWidget,
      );
      expect(
        cell('Wednesday, November 25, Push, planned, Moved from Monday'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('AC3 rest, unplanned rest and a deleted workout read right', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openCalendar(
        tester,
        records: [
          rec(20, DayStatus.rest, dayId: 'd3'),
          rec(19, DayStatus.unplannedRest),
          rec(18, DayStatus.done).copyWith(workoutId: 'gone'),
        ],
      );
      expect(cell('Friday, November 20, Rest'), findsOneWidget);
      expect(
        cell('Thursday, November 19, Push, Unplanned rest'),
        findsOneWidget,
      );
      expect(
        cell('Wednesday, November 18, Workout deleted, Done'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('AC6 a coming date names the active cycle', (tester) async {
      await openCalendar(tester);
      await tester.tap(find.bySemanticsLabel(RegExp('^Tuesday, November 24')));
      await tester.pumpAndSettle();
      expect(find.text('Legs · planned'), findsOneWidget);
      expect(find.text('Cycle: PPL'), findsOneWidget);
    });

    testWidgets('edge two cycles on a date: the sheet lists each', (
      tester,
    ) async {
      final old = ppl.copyWith(id: 'old', name: 'Old', isActive: false);
      await openCalendar(
        tester,
        cycles: [ppl, old],
        records: [
          rec(20, DayStatus.missed, c: 'old', dayId: 'd2'),
          rec(20, DayStatus.done),
        ],
      );
      await tester.tap(find.bySemanticsLabel(RegExp('^Friday, November 20')));
      await tester.pumpAndSettle();
      expect(find.text('Push · Done'), findsOneWidget);
      expect(find.text('Cycle: Old · Legs · Missed'), findsOneWidget);
      expect(find.text('Cycle: PPL · Push · Done'), findsOneWidget);
    });

    testWidgets('edge a picked month stays when the day changes', (
      tester,
    ) async {
      await openCalendar(tester);
      await tester.tap(find.byKey(CalendarView.nextKey));
      await tester.pumpAndSettle();
      expect(find.text('December 2026'), findsOneWidget);
      now = DateTime(2026, 12, 1, 0, 1);
      for (final st in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(st);
      }
      await tester.pumpAndSettle();
      expect(find.text('December 2026'), findsOneWidget);
    });
  });
}
