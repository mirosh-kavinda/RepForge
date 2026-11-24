import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/app.dart';
import 'package:repforge/core/metrics/units.dart';
import 'package:repforge/features/library/data/providers.dart';
import 'package:repforge/features/onboarding/data/providers.dart';
import 'package:repforge/features/schedule/presentation/schedule_screen.dart';
import 'package:repforge/features/workout/domain/workout_template.dart';
import 'package:repforge/features/workout/presentation/template_editor_screen.dart';
import 'package:repforge/features/workout/presentation/workouts_screen.dart';

import '../../../helpers/app_overrides.dart';
import '../fakes.dart';

const legDay = WorkoutTemplate(
  id: 't1',
  name: 'Leg Day',
  exercises: [
    TemplateExercise(id: 'r1', exerciseId: 'Barbell_Squat', sets: 4),
    TemplateExercise(id: 'r2', exerciseId: 'Leg_Press'),
  ],
);

Future<FakeTemplateRepository> pumpWorkouts(
  WidgetTester tester, {
  List<WorkoutTemplate> initial = const [legDay],
  double textScale = 1,
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);
  final repo = FakeTemplateRepository(initial);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...signedInOverrides(templates: repo),
        exerciseCatalogProvider.overrideWith((ref) async => FakeCatalog()),
        unitSystemProvider.overrideWith(
          (ref) => Stream.value(UnitSystem.metric),
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
  await tester.tap(find.text('Schedule'));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    find.byKey(ScheduleScreen.workoutsKey),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(find.byKey(ScheduleScreen.workoutsKey));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(ScheduleScreen.workoutsKey));
  await tester.pumpAndSettle();
  return repo;
}

Future<void> menu(WidgetTester tester, String name, String action) async {
  await tester.tap(find.byTooltip('Actions for $name'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(action).last);
  await tester.pumpAndSettle();
}

void main() {
  group('WKT-01 My workouts', () {
    testWidgets('AC1 Schedule opens My workouts with summaries', (
      tester,
    ) async {
      final repo = await pumpWorkouts(tester);
      expect(find.byType(WorkoutsScreen), findsOneWidget);
      expect(find.text('Leg Day'), findsOneWidget);
      // 4×160 + 3×160 = 1120 s ≈ 18.7 → 20.
      expect(find.text('2 exercises · 7 sets · ~20 min'), findsOneWidget);
      expect(repo.startersCalls, 1, reason: 'AC12 starters checked first');
    });

    testWidgets('AC1 empty state offers New workout', (tester) async {
      await pumpWorkouts(tester, initial: const []);
      expect(find.text('No workouts yet'), findsOneWidget);
      await tester.tap(find.byKey(WorkoutsScreen.newKey));
      await tester.pumpAndSettle();
      expect(find.byType(TemplateEditorScreen), findsOneWidget);
      expect(find.text('New workout'), findsWidgets);
    });

    testWidgets('AC1 tapping a workout opens it; saving returns here', (
      tester,
    ) async {
      final repo = await pumpWorkouts(tester);
      await tester.tap(find.text('Leg Day'));
      await tester.pumpAndSettle();
      expect(find.text('Edit workout'), findsOneWidget);
      await tester.enterText(
        find.byKey(TemplateEditorScreen.nameKey),
        'Legs A',
      );
      await tester.tap(find.byKey(TemplateEditorScreen.saveKey));
      await tester.pumpAndSettle();
      expect(find.byType(WorkoutsScreen), findsOneWidget);
      expect(find.text('Legs A'), findsOneWidget);
      expect(repo.active.single.id, 't1');
    });

    testWidgets('AC10 Duplicate opens an unsaved copy', (tester) async {
      final repo = await pumpWorkouts(tester);
      await menu(tester, 'Leg Day', 'Duplicate');
      expect(find.byType(TemplateEditorScreen), findsOneWidget);
      expect(find.text('Leg Day (copy)'), findsOneWidget);
      expect(repo.saved, isEmpty);
      await tester.tap(find.byKey(TemplateEditorScreen.saveKey));
      await tester.pumpAndSettle();
      expect(find.text('Leg Day (copy)'), findsOneWidget);
      expect(repo.active, hasLength(2));
    });

    testWidgets('AC11 Delete hides it at once; Undo restores it', (
      tester,
    ) async {
      final repo = await pumpWorkouts(tester);
      await menu(tester, 'Leg Day', 'Delete');
      expect(find.text('Leg Day'), findsNothing);
      expect(find.text('Leg Day deleted'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('Leg Day'), findsOneWidget);
      expect(repo.active.single, legDay);
    });

    testWidgets('AC9 back with changes asks first under the app router', (
      tester,
    ) async {
      final repo = await pumpWorkouts(tester);
      await tester.tap(find.text('Leg Day'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(TemplateEditorScreen.nameKey), 'X');
      await tester.pump();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsOneWidget);
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(find.byType(WorkoutsScreen), findsOneWidget);
      expect(repo.saved, isEmpty);
    });

    testWidgets('NFR-06 Schedule entry fits at 200 % text', (tester) async {
      await pumpWorkouts(tester, textScale: 2);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byKey(ScheduleScreen.workoutsKey), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('NFR-06 labelled, fits at 200 % text', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpWorkouts(tester, textScale: 2);
      expect(tester.takeException(), isNull);
      expect(
        find.bySemanticsLabel('Leg Day, 2 exercises · 7 sets · ~20 min'),
        findsOneWidget,
      );
      expect(find.byTooltip('Actions for Leg Day'), findsOneWidget);
      handle.dispose();
    });
  });
}
