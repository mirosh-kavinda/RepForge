import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/app.dart';
import 'package:repforge/app/router.dart';
import 'package:repforge/app/widgets/rf_button.dart';
import 'package:repforge/features/library/data/combined_catalog.dart';
import 'package:repforge/features/library/data/providers.dart';
import 'package:repforge/features/library/domain/exercise.dart';
import 'package:repforge/features/library/presentation/custom_exercise_form.dart';

import '../../../helpers/app_overrides.dart';
import '../fake_custom_exercise_repository.dart';
import '../library_fakes.dart';

late FakeCustomExerciseRepository custom;
String? popped;

Future<void> openForm(
  WidgetTester tester, {
  String? editId,
  List<Exercise> existing = const [],
  double textScale = 1,
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);
  custom = FakeCustomExerciseRepository(existing, {'Leg Press'});
  popped = null;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...signedInOverrides(custom: custom),
        exerciseCatalogProvider.overrideWith(
          (ref) async => CombinedCatalog(LibraryCatalog(), custom),
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
  final router = ProviderScope.containerOf(
    tester.element(find.byType(RepForgeApp)),
  ).read(routerProvider)..go(Routes.library);
  await tester.pumpAndSettle();
  unawaited(
    router
        .push<String>(
          editId == null ? Routes.exerciseNew : Routes.exerciseEdit(editId),
        )
        .then((id) => popped = id),
  );
  await tester.pumpAndSettle();
}

Finder get save => find.byKey(CustomExerciseForm.saveKey);

bool saveEnabled(WidgetTester tester) =>
    tester.widget<RfButton>(save).onPressed != null;

Future<void> tapChip(WidgetTester tester, String label, {int at = 0}) async {
  final f = find.text(label).at(at);
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<void> tapSave(WidgetTester tester) async {
  await tester.tap(save);
  await tester.pumpAndSettle();
}

void main() {
  group('EXL-03 custom exercise form', () {
    testWidgets('AC2 Save needs a name and a main muscle', (tester) async {
      final handle = tester.ensureSemantics();
      await openForm(tester);
      expect(saveEnabled(tester), isFalse);
      await tester.enterText(find.byKey(CustomExerciseForm.nameKey), 'Hack');
      await tester.pumpAndSettle();
      expect(saveEnabled(tester), isFalse);
      expect(find.text('Pick at least one main muscle'), findsOneWidget);
      await tapChip(tester, 'Quads');
      expect(saveEnabled(tester), isTrue);
      await tester.enterText(find.byKey(CustomExerciseForm.nameKey), '   ');
      await tester.pumpAndSettle();
      expect(saveEnabled(tester), isFalse);
      handle.dispose();
    });

    testWidgets('AC1 saved with equipment, muscles and notes; form closes', (
      tester,
    ) async {
      await openForm(tester);
      await tester.enterText(
        find.byKey(CustomExerciseForm.nameKey),
        '  Hack   Squat ',
      );
      await tester.tap(find.byKey(CustomExerciseForm.equipmentKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Machine').last);
      await tester.pumpAndSettle();
      await tapChip(tester, 'Quads');
      // The other-muscle row: Quads is hidden there, Glutes shows twice.
      await tapChip(tester, 'Glutes', at: 1);
      await tester.ensureVisible(find.byKey(CustomExerciseForm.notesKey));
      await tester.enterText(find.byKey(CustomExerciseForm.notesKey), 'Seat 4');
      await tester.pumpAndSettle();
      await tapSave(tester);
      final e = custom.saved.single;
      expect(e.name, 'Hack Squat');
      expect(e.equipment, Equipment.machine);
      expect(e.primaryMuscles, [Muscle.quadriceps]);
      expect(e.secondaryMuscles, [Muscle.glutes]);
      expect(e.notes, 'Seat 4');
      expect(e.custom, isTrue);
      expect(popped, e.id);
      expect(find.byType(CustomExerciseForm), findsNothing);
    });

    testWidgets('AC2 a name I already use is refused', (tester) async {
      await openForm(
        tester,
        existing: [
          ex('c1', 'Hack Squat', [Muscle.quadriceps]),
        ],
      );
      await tester.enterText(
        find.byKey(CustomExerciseForm.nameKey),
        'hack  squat',
      );
      await tapChip(tester, 'Quads');
      await tapSave(tester);
      expect(
        find.text('You already have an exercise called hack squat'),
        findsOneWidget,
      );
      expect(custom.saved, isEmpty);
      expect(find.byType(CustomExerciseForm), findsOneWidget);
    });

    testWidgets('AC2 a catalog name is refused', (tester) async {
      await openForm(tester);
      await tester.enterText(
        find.byKey(CustomExerciseForm.nameKey),
        'Leg Press',
      );
      await tapChip(tester, 'Quads');
      await tapSave(tester);
      expect(find.text('Leg Press is already in the library'), findsOneWidget);
      expect(custom.saved, isEmpty);
    });

    testWidgets('AC6 edit loads the exercise; its own name is fine', (
      tester,
    ) async {
      await openForm(
        tester,
        editId: 'c1',
        existing: [
          ex(
            'c1',
            'Hack Squat',
            [Muscle.quadriceps],
            equipment: Equipment.machine,
          ).copyWith(custom: true, notes: 'Seat 4'),
        ],
      );
      expect(find.text('Edit exercise'), findsOneWidget);
      expect(find.text('Hack Squat'), findsOneWidget);
      expect(find.text('Seat 4'), findsOneWidget);
      await tester.enterText(
        find.byKey(CustomExerciseForm.nameKey),
        'Hack Squat (Gym 2)',
      );
      await tapSave(tester);
      expect(custom.saved.single.id, 'c1');
      expect(custom.saved.single.name, 'Hack Squat (Gym 2)');
      expect(custom.saved.single.equipment, Equipment.machine);
    });

    testWidgets('error a failed save says so and keeps the input', (
      tester,
    ) async {
      await openForm(tester);
      custom.failWith = Exception('disk');
      await tester.enterText(find.byKey(CustomExerciseForm.nameKey), 'Hack');
      await tapChip(tester, 'Quads');
      await tapSave(tester);
      expect(find.text("Couldn't save the exercise"), findsOneWidget);
      expect(find.text('Hack'), findsOneWidget);
    });

    testWidgets('NFR-06 fits at 200 % text', (tester) async {
      await openForm(tester, textScale: 2);
      expect(tester.takeException(), isNull);
      expect(tester.getSize(save).height, greaterThanOrEqualTo(48));
    });
  });

  group('EXL-03 form details', () {
    testWidgets('NFR-06 chips say main or other to screen readers', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await openForm(tester);
      expect(find.bySemanticsLabel('Quads, main'), findsOneWidget);
      expect(find.bySemanticsLabel('Quads, other'), findsOneWidget);
      await tapChip(tester, 'Quads');
      expect(
        find.bySemanticsLabel('Quads, other'),
        findsNothing,
        reason: 'a main muscle is not offered as other',
      );
      handle.dispose();
    });

    testWidgets('edge notes stop at 1,000 characters with a counter', (
      tester,
    ) async {
      await openForm(tester);
      final notes = find.byKey(CustomExerciseForm.notesKey);
      await tester.ensureVisible(notes);
      await tester.enterText(notes, 'x' * 1005);
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(notes).controller!.text, hasLength(1000));
      expect(find.text('1000/1000'), findsOneWidget);
    });
  });
}
