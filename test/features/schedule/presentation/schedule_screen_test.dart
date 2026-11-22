import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/app.dart';
import 'package:repforge/core/clock.dart';
import 'package:repforge/features/library/data/providers.dart';
import 'package:repforge/features/schedule/domain/cycle.dart';
import 'package:repforge/features/schedule/domain/day_record.dart';
import 'package:repforge/features/schedule/presentation/cycle_editor_screen.dart';
import 'package:repforge/features/schedule/presentation/cycles_screen.dart';
import 'package:repforge/features/schedule/presentation/schedule_screen.dart';
import 'package:repforge/features/workout/data/starter_templates.dart';
import 'package:repforge/features/workout/domain/workout_template.dart';

import '../../../helpers/app_overrides.dart';
import '../../workout/fakes.dart';
import '../fake_cycle_repository.dart';
import '../fake_day_record_repository.dart';

final now = DateTime(2026, 11, 23, 10); // Monday

final starters = [
  for (final t in starterTemplates) t.copyWith(id: t.name.toLowerCase()),
];

Cycle cycle(
  String id,
  String name, {
  bool active = false,
  List<CycleDay> days = const [
    CycleDay(id: 'd1', workoutId: 'push'),
    CycleDay(id: 'd2', workoutId: 'legs'),
    CycleDay(id: 'd3'),
  ],
}) => Cycle(
  id: id,
  name: name,
  days: days,
  isActive: active,
  // SCH-02: anchored today on day 3 (Rest).
  startDate: DateTime.utc(2026, 11, 23),
  startDayIndex: 2,
);

Future<FakeCycleRepository> pumpApp(
  WidgetTester tester, {
  List<Cycle> cycles = const [],
  List<DayRecord> records = const [],
  List<WorkoutTemplate>? workouts,
  bool openSchedule = true,
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);
  final repo = FakeCycleRepository(cycles);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...signedInOverrides(
          templates: FakeTemplateRepository(workouts ?? starters),
          cycles: repo,
          days: FakeDayRecordRepository(records),
        ),
        exerciseCatalogProvider.overrideWith((ref) async => FakeCatalog()),
        clockProvider.overrideWithValue(() => now),
      ],
      child: const RepForgeApp(),
    ),
  );
  await tester.pumpAndSettle();
  if (openSchedule) {
    await tester.tap(find.text('Schedule'));
    await tester.pumpAndSettle();
  }
  return repo;
}

Future<void> scrollTap(WidgetTester tester, Finder f) async {
  await tester.scrollUntilVisible(
    f,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<void> menu(WidgetTester tester, String name, String action) async {
  await tester.tap(find.byTooltip('Actions for $name'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(action).last);
  await tester.pumpAndSettle();
}

void main() {
  group('SCH-01 Schedule', () {
    testWidgets('AC6 shows the active cycle with today marked in text', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpApp(tester, cycles: [cycle('c1', 'PPL', active: true)]);
      expect(find.text('PPL'), findsOneWidget);
      expect(find.text('3-day cycle'), findsOneWidget);
      expect(find.textContaining('Miss a day?'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp(r'^Day 3, Rest, today')),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel(RegExp(r'^Day 1, Push, ')), findsOneWidget);
      handle.dispose();
    });

    testWidgets('AC6 AC10 empty state offers starter plans; one tap uses it', (
      tester,
    ) async {
      final repo = await pumpApp(tester);
      expect(find.text('No cycle yet'), findsOneWidget);
      expect(find.text('Recommended'), findsOneWidget);
      await scrollTap(tester, find.text('PPL + Rest'));
      final c = repo.saved.single;
      expect(c.days.map((d) => d.workoutId), ['push', 'pull', 'legs', null]);
      expect(
        (c.isActive, c.startDate, c.startDayIndex),
        (true, DateTime.utc(2026, 11, 23), 0),
      );
      expect(find.text('4-day cycle'), findsOneWidget);
    });

    testWidgets('edge a plan with a deleted starter workout is not offered', (
      tester,
    ) async {
      await pumpApp(
        tester,
        workouts: starters.where((w) => w.name != 'Legs').toList(),
      );
      expect(find.text('PPL + Rest'), findsNothing);
      expect(find.text('Upper / Lower'), findsOneWidget);
    });

    testWidgets('AC5 + New cycle opens the builder', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byKey(ScheduleScreen.newCycleKey));
      await tester.pumpAndSettle();
      expect(find.byType(CycleEditorScreen), findsOneWidget);
    });

    testWidgets('edge a failed plan save says so and saves nothing', (
      tester,
    ) async {
      final repo = await pumpApp(tester)
        ..failSaveWith = StateError('disk');
      await scrollTap(tester, find.text('PPL + Rest'));
      expect(find.text("Couldn't save. Try again."), findsOneWidget);
      expect(repo.active, isEmpty);
      expect(find.text('No cycle yet'), findsOneWidget);
    });

    testWidgets('edge a second tap during the save saves one cycle', (
      tester,
    ) async {
      final gate = Completer<void>();
      final repo = await pumpApp(tester)
        ..saveGate = gate;
      await scrollTap(tester, find.text('PPL + Rest'));
      await tester.tap(find.text('PPL + Rest'));
      await tester.pump();
      gate.complete();
      await tester.pumpAndSettle();
      expect(repo.saved, hasLength(1));
    });

    testWidgets('AC11 a deleted workout is flagged on the cycle card', (
      tester,
    ) async {
      await pumpApp(
        tester,
        cycles: [cycle('c1', 'PPL', active: true)],
        workouts: starters.where((w) => w.name != 'Legs').toList(),
      );
      expect(find.text('Workout deleted'), findsOneWidget);
    });
  });

  group('SCH-01 Home', () {
    testWidgets('AC7 Home shows today in the active cycle', (tester) async {
      await pumpApp(
        tester,
        cycles: [cycle('c1', 'PPL', active: true)],
        openSchedule: false,
      );
      // SCH-02 AC9: a rest day shows the rest-day variant.
      expect(find.text('Rest day'), findsOneWidget);
      expect(find.text('Day 3 of 3'), findsOneWidget);
    });

    testWidgets('AC7 Home with no cycle points to Schedule', (tester) async {
      await pumpApp(tester, openSchedule: false);
      expect(
        find.text('No cycle yet. Set one up in Schedule.'),
        findsOneWidget,
      );
    });

    testWidgets('AC11 Home names a deleted workout as deleted', (tester) async {
      await pumpApp(
        tester,
        cycles: [
          cycle(
            'c1',
            'PPL',
            active: true,
            days: const [
              CycleDay(id: 'd1', workoutId: 'push'),
              CycleDay(id: 'd2'),
              CycleDay(id: 'd3', workoutId: 'legs'),
            ],
          ),
        ],
        workouts: starters.where((w) => w.name != 'Legs').toList(),
        openSchedule: false,
      );
      expect(find.textContaining('Day 3 of 3'), findsOneWidget);
      expect(find.textContaining('Workout deleted'), findsOneWidget);
    });
  });

  group('SCH-01 My cycles', () {
    Future<FakeCycleRepository> openCycles(WidgetTester tester) async {
      final repo = await pumpApp(
        tester,
        cycles: [cycle('c1', 'PPL', active: true), cycle('c2', 'Deload')],
      );
      await scrollTap(tester, find.byKey(ScheduleScreen.cyclesKey));
      expect(find.byType(CyclesScreen), findsOneWidget);
      return repo;
    }

    testWidgets('AC9 lists cycles with the active one marked in text', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openCycles(tester);
      expect(
        find.bySemanticsLabel('PPL, Active, 3 days · 2 train, 1 rest'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Deload, 3 days · 2 train, 1 rest'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('AC9 make active with Today is day n', (tester) async {
      final repo = await openCycles(tester);
      await menu(tester, 'Deload', 'Make active');
      expect(find.text('Start Deload'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Increase Today is day'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(CyclesScreen.startKey));
      await tester.pumpAndSettle();
      final c = repo.saved.single;
      expect(
        (c.id, c.isActive, c.startDate, c.startDayIndex),
        ('c2', true, DateTime.utc(2026, 11, 23), 1),
      );
      expect(repo.active.firstWhere((x) => x.id == 'c1').isActive, isFalse);
    });

    testWidgets('AC9 active cannot be deleted; inactive deletes with Undo', (
      tester,
    ) async {
      final repo = await openCycles(tester);
      await menu(tester, 'PPL', 'Delete');
      expect(
        find.text('Switch to another cycle before deleting this one.'),
        findsOneWidget,
      );
      expect(find.text('PPL'), findsOneWidget);

      await menu(tester, 'Deload', 'Delete');
      expect(find.text('Deload'), findsNothing);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('Deload'), findsOneWidget);
      expect(repo.active, hasLength(2));
    });

    testWidgets('AC9 tap edits; Duplicate opens an inactive copy', (
      tester,
    ) async {
      await openCycles(tester);
      await tester.tap(find.text('Deload'));
      await tester.pumpAndSettle();
      expect(find.text('Edit cycle'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await menu(tester, 'PPL', 'Duplicate');
      expect(find.text('PPL (copy)'), findsOneWidget);
    });

    testWidgets('edge a failed make active says so; PPL stays active', (
      tester,
    ) async {
      final repo = await openCycles(tester)
        ..failSaveWith = StateError('disk');
      await menu(tester, 'Deload', 'Make active');
      await tester.tap(find.byKey(CyclesScreen.startKey));
      await tester.pumpAndSettle();
      expect(find.text("Couldn't save. Try again."), findsOneWidget);
      expect(repo.active.firstWhere((x) => x.id == 'c1').isActive, isTrue);
    });

    testWidgets('edge a failed delete says so and keeps the cycle', (
      tester,
    ) async {
      final repo = await openCycles(tester)
        ..failDeleteWith = StateError('disk');
      await menu(tester, 'Deload', 'Delete');
      expect(find.text("Couldn't save. Try again."), findsOneWidget);
      expect(find.text('Deload'), findsOneWidget);
      expect(repo.active, hasLength(2));
    });

    testWidgets('edge a failed Undo says so', (tester) async {
      final repo = await openCycles(tester)
        ..failRestoreWith = StateError('disk');
      await menu(tester, 'Deload', 'Delete');
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text("Couldn't save. Try again."), findsOneWidget);
      expect(repo.active.map((c) => c.id), ['c1']);
    });

    testWidgets('edge an empty list says so', (tester) async {
      await pumpApp(tester);
      await scrollTap(tester, find.byKey(ScheduleScreen.cyclesKey));
      expect(find.text('No saved cycles yet.'), findsOneWidget);
    });
  });

  group('SCH-02 Schedule follows the rolled day', () {
    DayRecord done(String cycleId, int day, String dayId) => DayRecord(
      id: '$cycleId$day',
      cycleId: cycleId,
      date: DateTime.utc(2026, 11, day),
      dayId: dayId,
      dayIndex: 0,
      status: DayStatus.done,
    );

    // Anchored Sat 21 on Push; Push done Sat, Legs not done Sun.
    final rolled = cycle(
      'c1',
      'PPL',
      active: true,
    ).copyWith(startDate: DateTime.utc(2026, 11, 21), startDayIndex: 0);

    testWidgets('AC10 the today marker follows the rolled position', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpApp(tester, cycles: [rolled], records: [done('c1', 21, 'd1')]);
      // The calendar would say day 3; Legs is still waiting.
      expect(
        find.bySemanticsLabel(RegExp(r'^Day 2, Legs, today, ')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp(r'^Day 3, Rest, today')),
        findsNothing,
      );
      handle.dispose();
    });

    testWidgets('AC10 a done today is labelled Done in text', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpApp(
        tester,
        cycles: [rolled],
        records: [done('c1', 21, 'd1'), done('c1', 23, 'd2')],
      );
      expect(
        find.bySemanticsLabel(RegExp(r'^Day 2, Legs, today, Done, ')),
        findsOneWidget,
      );
      expect(
        find.text('Legs · today · Done', findRichText: true),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('AC11 make active starts fresh from the chosen day', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final other = cycle(
        'c2',
        'Deload',
      ).copyWith(startDate: DateTime.utc(2026, 11, 1));
      await pumpApp(
        tester,
        cycles: [rolled, other],
        records: [
          done('c1', 21, 'd1'),
          done('c1', 23, 'd2'),
          done('c2', 2, 'd1'),
          done('c2', 22, 'd2'),
        ],
      );
      await scrollTap(tester, find.byKey(ScheduleScreen.cyclesKey));
      await menu(tester, 'Deload', 'Make active');
      await tester.tap(find.byKey(CyclesScreen.startKey));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Deload'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp(r'^Day 1, Push, today, (?!Done)')),
        findsOneWidget,
      );
      handle.dispose();
    });
  });
}
