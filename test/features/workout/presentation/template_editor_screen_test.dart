import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/l10n/generated/app_localizations.dart';
import 'package:repforge/app/theme/rf_theme.dart';
import 'package:repforge/app/widgets/rf_button.dart';
import 'package:repforge/app/widgets/rf_stepper.dart';
import 'package:repforge/core/metrics/units.dart';
import 'package:repforge/features/library/data/providers.dart';
import 'package:repforge/features/library/presentation/exercise_picker_screen.dart';
import 'package:repforge/features/onboarding/data/providers.dart';
import 'package:repforge/features/workout/data/providers.dart';
import 'package:repforge/features/workout/domain/workout_template.dart';
import 'package:repforge/features/workout/presentation/exercise_targets_sheet.dart';
import 'package:repforge/features/workout/presentation/template_editor_screen.dart';

import '../fakes.dart';

const legDay = WorkoutTemplate(
  id: 't1',
  name: 'Leg Day',
  exercises: [
    TemplateExercise(
      id: 'r1',
      exerciseId: 'Barbell_Squat',
      sets: 4,
      repMin: 5,
      repMax: 8,
      targetKg: 102.5,
      restSec: 180,
    ),
    TemplateExercise(id: 'r2', exerciseId: 'Leg_Press', restSec: 120),
    TemplateExercise(id: 'r3', exerciseId: 'Plank', restSec: 60),
  ],
);

Future<FakeTemplateRepository> pumpEditor(
  WidgetTester tester, {
  String? id,
  String? copyOf,
  UnitSystem units = UnitSystem.metric,
  double textScale = 1,
  FakeTemplateRepository? repo,
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);
  final r = repo ?? FakeTemplateRepository([legDay]);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        templateRepositoryProvider.overrideWithValue(r),
        exerciseCatalogProvider.overrideWith((ref) async => FakeCatalog()),
        unitSystemProvider.overrideWith((ref) => Stream.value(units)),
      ],
      child: MaterialApp(
        theme: rfTheme(Brightness.dark),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        builder: (context, app) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: app!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        TemplateEditorScreen(id: id, copyOf: copyOf),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return r;
}

bool saveEnabled(WidgetTester tester) =>
    tester
        .widget<RfButton>(find.byKey(TemplateEditorScreen.saveKey))
        .onPressed !=
    null;

Future<void> rowAction(WidgetTester tester, String name, String action) async {
  await tester.tap(find.byTooltip('Actions for $name'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(action).last);
  await tester.pumpAndSettle();
}

Future<void> back(WidgetTester tester) async {
  await tester.pageBack();
  await tester.pumpAndSettle();
}

List<String> rowOrder(WidgetTester tester) => [
  for (final t in tester.widgetList<Text>(find.byType(Text)))
    if (fakeCatalogExercises.any((e) => e.name == t.data)) t.data!,
];

void main() {
  group('WKT-01 editor: new workout', () {
    testWidgets('AC2 Save needs a name and an exercise; saves and leaves', (
      tester,
    ) async {
      final repo = await pumpEditor(tester);
      expect(find.text('New workout'), findsOneWidget);
      expect(saveEnabled(tester), isFalse);
      expect(find.text('Add at least one exercise to save.'), findsOneWidget);

      await tester.enterText(
        find.byKey(TemplateEditorScreen.nameKey),
        ' Legs ',
      );
      await tester.pump();
      expect(saveEnabled(tester), isFalse);

      await tester.tap(find.byKey(TemplateEditorScreen.addKey));
      await tester.pumpAndSettle();
      expect(find.byType(ExercisePickerScreen), findsOneWidget);
      await tester.tap(find.text('Leg Press'));
      await tester.tap(find.text('Barbell Squat'));
      await tester.pump();
      await tester.tap(find.byKey(ExercisePickerScreen.addKey));
      await tester.pumpAndSettle();

      expect(rowOrder(tester), ['Leg Press', 'Barbell Squat']);
      expect(find.text('3 × 8–12 · rest 2:00'), findsNWidgets(2));
      expect(saveEnabled(tester), isTrue);

      await tester.tap(find.byKey(TemplateEditorScreen.saveKey));
      await tester.pumpAndSettle();
      expect(find.byType(TemplateEditorScreen), findsNothing);
      final saved = repo.saved.single;
      expect(saved.name, 'Legs');
      expect(saved.exercises.map((e) => e.exerciseId), [
        'Leg_Press',
        'Barbell_Squat',
      ]);
    });

    testWidgets('AC2 a name over 40 characters cannot be typed', (
      tester,
    ) async {
      await pumpEditor(tester);
      await tester.enterText(
        find.byKey(TemplateEditorScreen.nameKey),
        'a' * 45,
      );
      await tester.pump();
      final field = tester.widget<TextField>(
        find.byKey(TemplateEditorScreen.nameKey),
      );
      expect(field.controller!.text.length, 40);
    });
  });

  group('WKT-01 editor: existing workout', () {
    testWidgets('AC8 header shows counts, minutes and muscles', (tester) async {
      await pumpEditor(tester, id: 't1');
      expect(find.text('Edit workout'), findsOneWidget);
      expect(find.text('3 exercises'), findsOneWidget);
      expect(find.text('10 sets'), findsOneWidget);
      // 4×(40+180) + 3×(40+120) + 3×(40+60) = 880+480+300 = 1660 s ≈ 27.7 → 30.
      expect(find.text('~30 min'), findsOneWidget);
      expect(find.text('Quads · Glutes · Abs'), findsOneWidget);
      expect(find.text('4 × 5–8 · 102.5 kg · rest 3:00'), findsOneWidget);
    });

    testWidgets('AC4 targets sheet edits sets, kind, weight and rest', (
      tester,
    ) async {
      final repo = await pumpEditor(tester, id: 't1');
      await tester.tap(find.text('Plank'));
      await tester.pumpAndSettle();
      expect(find.byType(ExerciseTargetsSheet), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Increase Sets'));
      await tester.tap(find.text('Time'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(ExerciseTargetsSheet.weightKey), '20');
      await tester.tap(find.bySemanticsLabel('Decrease Rest'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ExerciseTargetsSheet.doneKey));
      await tester.pumpAndSettle();

      expect(find.text('4 × 45 s · 20 kg · rest 0:45'), findsOneWidget);
      expect(find.text('5 × 45 s'), findsNothing);
      await tester.tap(find.byKey(TemplateEditorScreen.saveKey));
      await tester.pumpAndSettle();
      final plank = repo.saved.single.exercises.last;
      expect(
        (plank.sets, plank.kind, plank.targetKg, plank.restSec),
        (4, TargetKind.time, 20.0, 45),
      );
    });

    testWidgets('AC4 fixed reps show one number; bad weight says why', (
      tester,
    ) async {
      await pumpEditor(tester, id: 't1');
      await tester.tap(find.text('Leg Press'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fixed'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Increase Reps'), findsOneWidget);
      await tester.enterText(find.byKey(ExerciseTargetsSheet.weightKey), '600');
      await tester.pump();
      expect(find.text('Enter 0 to 500 kg.'), findsOneWidget);
      final done = find.byKey(ExerciseTargetsSheet.doneKey);
      expect(tester.widget<RfButton>(done).onPressed, isNull);
      await tester.enterText(find.byKey(ExerciseTargetsSheet.weightKey), '');
      await tester.pump();
      await tester.tap(done);
      await tester.pumpAndSettle();
      expect(find.text('3 × 8 · rest 2:00'), findsOneWidget);
    });

    testWidgets('AC4 weight is entered and shown in lb, stored in kg', (
      tester,
    ) async {
      final repo = await pumpEditor(
        tester,
        id: 't1',
        units: UnitSystem.imperial,
      );
      expect(find.text('4 × 5–8 · 226 lb · rest 3:00'), findsOneWidget);
      await tester.tap(find.text('Leg Press'));
      await tester.pumpAndSettle();
      expect(find.text('Target weight (lb), optional'), findsOneWidget);
      await tester.enterText(find.byKey(ExerciseTargetsSheet.weightKey), '225');
      await tester.tap(find.byKey(ExerciseTargetsSheet.doneKey));
      await tester.pumpAndSettle();
      expect(find.text('3 × 8–12 · 225 lb · rest 2:00'), findsOneWidget);
      await tester.tap(find.byKey(TemplateEditorScreen.saveKey));
      await tester.pumpAndSettle();
      expect(repo.saved.single.exercises[1].targetKg, 102.06);
    });

    testWidgets('AC5 move down, move up and remove from the row menu', (
      tester,
    ) async {
      await pumpEditor(tester, id: 't1');
      await rowAction(tester, 'Barbell Squat', 'Move down');
      expect(rowOrder(tester), ['Leg Press', 'Barbell Squat', 'Plank']);
      await rowAction(tester, 'Plank', 'Move up');
      expect(rowOrder(tester), ['Leg Press', 'Plank', 'Barbell Squat']);
      await rowAction(tester, 'Leg Press', 'Remove');
      expect(rowOrder(tester), ['Plank', 'Barbell Squat']);
    });

    testWidgets('AC6 AC7 select adjacent rows, link, then unlink', (
      tester,
    ) async {
      await pumpEditor(tester, id: 't1');
      await rowAction(tester, 'Barbell Squat', 'Select for superset');
      expect(
        find.text('Pick 2 or more exercises next to each other.'),
        findsOneWidget,
      );
      final link = find.byKey(TemplateEditorScreen.linkKey);
      expect(tester.widget<RfButton>(link).onPressed, isNull);

      await tester.tap(find.text('Plank'));
      await tester.pump();
      expect(tester.widget<RfButton>(link).onPressed, isNull, reason: 'gap');
      await tester.tap(find.text('Barbell Squat'));
      await tester.tap(find.text('Leg Press'));
      await tester.pump();
      await tester.tap(link);
      await tester.pumpAndSettle();

      expect(find.text('Superset A'), findsNWidgets(2));
      expect(find.text('3 × 8–12 · no rest (superset)'), findsOneWidget);
      expect(find.text('3 × 8–12 · rest 1:00'), findsOneWidget);

      await tester.tap(find.text('Leg Press'));
      await tester.pumpAndSettle();
      expect(find.textContaining('No rest (superset).'), findsOneWidget);
      expect(find.bySemanticsLabel('Increase Rest'), findsNothing);
      await tester.tap(find.byKey(ExerciseTargetsSheet.doneKey));
      await tester.pumpAndSettle();

      await rowAction(tester, 'Plank', 'Unlink superset');
      expect(find.text('Superset A'), findsNothing);
      expect(find.text('3 × 8–12 · rest 2:00'), findsOneWidget);
    });
  });

  group('WKT-01 editor: review follow-ups', () {
    testWidgets('AC5 dragging a row by its handle reorders it', (tester) async {
      await pumpEditor(tester, id: 't1');
      final rowHeight = tester.getSize(find.byKey(const ValueKey('r1'))).height;
      final handle = find.descendant(
        of: find.byKey(const ValueKey('r1')),
        matching: find.byIcon(Icons.drag_indicator),
      );
      final gesture = await tester.startGesture(tester.getCenter(handle));
      await tester.pump(kLongPressTimeout);
      for (var i = 0; i < 10; i++) {
        await gesture.moveBy(Offset(0, rowHeight * 0.9 / 10));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pumpAndSettle();
      expect(rowOrder(tester), ['Leg Press', 'Barbell Squat', 'Plank']);
    });

    testWidgets('AC8 header updates live after edits', (tester) async {
      await pumpEditor(tester, id: 't1');
      await rowAction(tester, 'Plank', 'Remove');
      expect(find.text('2 exercises'), findsOneWidget);
      expect(find.text('7 sets'), findsOneWidget);
      // 4×220 + 3×160 = 1360 s ≈ 22.7 → 25.
      expect(find.text('~25 min'), findsOneWidget);
      expect(find.text('Quads · Glutes'), findsOneWidget);

      await tester.tap(find.text('Leg Press'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Increase Sets'));
      await tester.tap(find.byKey(ExerciseTargetsSheet.doneKey));
      await tester.pumpAndSettle();
      expect(find.text('8 sets'), findsOneWidget);
    });

    testWidgets('edge switching units never changes the stored weight', (
      tester,
    ) async {
      final repo = await pumpEditor(
        tester,
        id: 't1',
        units: UnitSystem.imperial,
      );
      await tester.tap(find.text('Barbell Squat'));
      await tester.pumpAndSettle();
      expect(find.text('225.97'), findsOneWidget, reason: 'stored, unrounded');
      await tester.tap(find.byKey(ExerciseTargetsSheet.doneKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TemplateEditorScreen.saveKey));
      await tester.pumpAndSettle();
      expect(repo.saved.single.exercises.first.targetKg, 102.5);
    });

    testWidgets('edge a missing workout says so', (tester) async {
      await pumpEditor(tester, id: 'gone');
      expect(find.text('This workout no longer exists.'), findsOneWidget);
    });
  });

  group('WKT-01 editor: leaving', () {
    testWidgets('AC9 no changes leaves at once', (tester) async {
      await pumpEditor(tester, id: 't1');
      await back(tester);
      expect(find.byType(TemplateEditorScreen), findsNothing);
    });

    testWidgets('AC9 changes ask first; keep editing stays, discard leaves', (
      tester,
    ) async {
      final repo = await pumpEditor(tester, id: 't1');
      await rowAction(tester, 'Plank', 'Remove');
      await back(tester);
      expect(find.text('Discard changes?'), findsOneWidget);
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      expect(find.byType(TemplateEditorScreen), findsOneWidget);

      await back(tester);
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(find.byType(TemplateEditorScreen), findsNothing);
      expect(repo.saved, isEmpty);
    });

    testWidgets('AC10 a copy opens unsaved with the copied name', (
      tester,
    ) async {
      final repo = await pumpEditor(tester, copyOf: 't1');
      expect(find.text('New workout'), findsOneWidget);
      expect(find.text('Leg Day (copy)'), findsOneWidget);
      expect(rowOrder(tester), ['Barbell Squat', 'Leg Press', 'Plank']);
      await back(tester);
      expect(find.text('Discard changes?'), findsOneWidget);
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TemplateEditorScreen.saveKey));
      await tester.pumpAndSettle();
      expect(repo.saved.single.id, isNot('t1'));
      expect(repo.active.map((t) => t.name), ['Leg Day', 'Leg Day (copy)']);
    });

    testWidgets('edge a failed save keeps the draft and says so', (
      tester,
    ) async {
      final repo = FakeTemplateRepository([legDay])
        ..failSaveWith = Exception('disk');
      await pumpEditor(tester, id: 't1', repo: repo);
      await rowAction(tester, 'Plank', 'Remove');
      await tester.tap(find.byKey(TemplateEditorScreen.saveKey));
      await tester.pumpAndSettle();
      expect(find.text("Couldn't save. Try again."), findsOneWidget);
      expect(find.byType(TemplateEditorScreen), findsOneWidget);
      expect(rowOrder(tester), ['Barbell Squat', 'Leg Press']);
    });
  });

  group('WKT-01 editor: accessibility', () {
    testWidgets('NFR-06 labelled controls, 48 dp, no overflow at 200 %', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpEditor(tester, id: 't1', textScale: 2);
      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel('Reorder Barbell Squat'), findsOneWidget);
      expect(find.byTooltip('Actions for Barbell Squat'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp(r'^Edit Barbell Squat, 4 × 5–8')),
        findsOneWidget,
      );
      final handleSize = tester.getSize(
        find
            .ancestor(
              of: find.byIcon(Icons.drag_indicator).first,
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(handleSize.height, greaterThanOrEqualTo(48));

      await tester.tap(find.text('Barbell Squat'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(RfStepper), findsWidgets);
      handle.dispose();
    });
  });
}
