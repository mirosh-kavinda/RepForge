import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/l10n/generated/app_localizations.dart';
import 'package:repforge/app/theme/rf_scales.dart';
import 'package:repforge/app/theme/rf_theme.dart';
import 'package:repforge/app/widgets/rf_button.dart';
import 'package:repforge/data/local/app_database.dart';
import 'package:repforge/features/library/data/catalog_importer.dart';
import 'package:repforge/features/library/data/combined_catalog.dart';
import 'package:repforge/features/library/data/drift_exercise_catalog_repository.dart';
import 'package:repforge/features/library/data/providers.dart';
import 'package:repforge/features/library/domain/exercise.dart';
import 'package:repforge/features/library/presentation/custom_exercise_form.dart';
import 'package:repforge/features/library/presentation/exercise_picker_screen.dart';

import '../fake_custom_exercise_repository.dart';

late AppDatabase _db;
late DriftExerciseCatalogRepository _repo;
late FakeCustomExerciseRepository _custom;

// Opens the picker from a button and records what it pops with.
Future<List<List<String>?>> pumpPicker(
  WidgetTester tester, {
  Set<String> added = const {},
  int capacity = 30,
  double textScale = 1,
  List<Exercise> mine = const [],
}) async {
  _custom = FakeCustomExerciseRepository(mine);
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);
  final popped = <List<String>?>[];
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        customExerciseRepositoryProvider.overrideWithValue(_custom),
        exerciseCatalogProvider.overrideWith(
          (ref) async => CombinedCatalog(_repo, _custom),
        ),
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
                onPressed: () async => popped.add(
                  await Navigator.of(context).push<List<String>>(
                    MaterialPageRoute(
                      builder: (_) => ExercisePickerScreen(
                        alreadyAdded: added,
                        capacity: capacity,
                      ),
                    ),
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
  return popped;
}

Future<void> search(WidgetTester tester, String text) async {
  await tester.enterText(find.byKey(ExercisePickerScreen.searchKey), text);
  await tester.pumpAndSettle();
}

Finder row(String name) => find.text(name, skipOffstage: false);

void main() {
  setUpAll(() async {
    _db = AppDatabase(NativeDatabase.memory());
    final seed = File('assets/exercises/seed.json').readAsStringSync();
    await CatalogImporter(_db, loadSeed: () async => seed).run();
    _repo = DriftExerciseCatalogRepository(_db);
  });
  tearDownAll(() => _db.close());

  group('WKT-01 exercise picker', () {
    testWidgets('AC3 search by name, pick several, add in pick order', (
      tester,
    ) async {
      final popped = await pumpPicker(tester);
      await search(tester, 'leg press');
      await tester.tap(row('Leg Press'));
      await search(tester, 'barbell squat');
      await tester.tap(row('Barbell Squat'));
      await tester.pump();
      expect(find.text('Add (2)'), findsOneWidget);

      await tester.tap(find.byKey(ExercisePickerScreen.addKey));
      await tester.pumpAndSettle();
      expect(popped.single, ['Leg_Press', 'Barbell_Squat']);
    });

    testWidgets('AC3 tapping a picked row unpicks it; Add needs one', (
      tester,
    ) async {
      await pumpPicker(tester);
      await search(tester, 'plank');
      await tester.tap(row('Plank'));
      await tester.pump();
      await tester.tap(row('Plank'));
      await tester.pump();
      expect(find.text('Add (0)'), findsOneWidget);
      final add = tester.widget<RfButton>(
        find.byKey(ExercisePickerScreen.addKey),
      );
      expect(add.onPressed, isNull);
    });

    testWidgets('AC3 muscle group and equipment filter the list', (
      tester,
    ) async {
      await pumpPicker(tester);
      await tester.tap(find.text('Legs'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Equipment: All'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Machine').last);
      await tester.pumpAndSettle();
      expect(find.text('Equipment: Machine'), findsOneWidget);
      await search(tester, 'press');
      expect(row('Leg Press'), findsOneWidget);
      expect(row('Barbell Squat'), findsNothing);
    });

    testWidgets('AC3 already-added exercises are marked and can be added', (
      tester,
    ) async {
      final popped = await pumpPicker(tester, added: {'Plank'});
      await search(tester, 'plank');
      expect(find.text('Added'), findsOneWidget);
      await tester.tap(row('Plank'));
      await tester.pump();
      await tester.tap(find.byKey(ExercisePickerScreen.addKey));
      await tester.pumpAndSettle();
      expect(popped.single, ['Plank']);
    });

    testWidgets('edge capacity stops further picks and says why', (
      tester,
    ) async {
      await pumpPicker(tester, capacity: 1);
      await search(tester, 'plank');
      await tester.tap(row('Plank'));
      await tester.pump();
      expect(find.text('Up to 30 exercises per workout.'), findsOneWidget);
      await tester.tap(row('Push Up to Side Plank'));
      await tester.pump();
      expect(find.text('Add (1)'), findsOneWidget);
    });

    testWidgets('AC3 typing a muscle or equipment filters by it', (
      tester,
    ) async {
      await pumpPicker(tester);
      await search(tester, 'quads machine press');
      expect(row('Leg Press'), findsOneWidget);
      expect(row('Barbell Squat'), findsNothing);
      await search(tester, 'romanian hamstrings');
      expect(row('Romanian Deadlift'), findsOneWidget);
      await tester.tap(find.text('Chest'));
      await tester.pumpAndSettle();
      expect(find.text('No exercises match.'), findsOneWidget);
    });

    testWidgets('NFR-06 rows are labelled, 48 dp, fit at 200 % text', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpPicker(tester, textScale: 2);
      await search(tester, 'leg press');
      expect(tester.takeException(), isNull);
      expect(
        find.bySemanticsLabel(RegExp(r'^Pick Leg Press, Machine')),
        findsOneWidget,
      );
      final size = tester.getSize(
        find
            .ancestor(of: row('Leg Press'), matching: find.byType(Container))
            .first,
      );
      expect(size.height, greaterThanOrEqualTo(RfSize.minTarget));
      handle.dispose();
    });
  });

  group('EXL-03 picker', () {
    const hack = Exercise(
      id: 'c1',
      name: 'Zottman Hack',
      primaryMuscles: [Muscle.biceps],
      secondaryMuscles: [],
      equipment: Equipment.dumbbell,
      category: ExerciseCategory.strength,
      level: ExerciseLevel.beginner,
      instructions: [],
      images: [],
      custom: true,
    );

    testWidgets('AC3 mine are found and marked Custom', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpPicker(tester, mine: [hack]);
      await search(tester, 'zottman');
      expect(
        find.bySemanticsLabel(RegExp('^Pick Zottman Hack, Custom · Dumbbell')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('AC4 nothing found: New exercise named as searched', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpPicker(tester);
      await search(tester, 'Zottman Hack');
      await tester.tap(find.byKey(ExercisePickerScreen.createKey));
      await tester.pumpAndSettle();
      expect(find.byType(CustomExerciseForm), findsOneWidget);
      expect(find.text('Zottman Hack'), findsOneWidget);
      await tester.tap(find.text('Biceps').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(CustomExerciseForm.saveKey));
      await tester.pumpAndSettle();
      expect(find.byType(ExercisePickerScreen), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('^Pick Zottman Hack')),
        findsOneWidget,
      );
      handle.dispose();
    });
  });
}
