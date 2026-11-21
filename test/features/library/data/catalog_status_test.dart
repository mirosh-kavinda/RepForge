import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/app.dart';
import 'package:repforge/data/local/app_database.dart';
import 'package:repforge/data/local/database_provider.dart';
import 'package:repforge/features/home/presentation/home_screen.dart';
import 'package:repforge/features/library/data/providers.dart';
import 'package:repforge/features/library/domain/exercise_query.dart';

import '../../../helpers/app_overrides.dart';

void main() {
  group('FND-03 catalog status', () {
    test('AC10 catalog reads are loading until the import completes', () async {
      final seed = Completer<String>();
      final db = AppDatabase(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [
          ...signedInOverrides(),
          appDatabaseProvider.overrideWithValue(db),
          seedLoaderProvider.overrideWithValue(() => seed.future),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(db.close);

      container.listen(exerciseCatalogProvider, (_, _) {});
      expect(container.read(exerciseCatalogProvider).isLoading, isTrue);

      seed.complete(
        '{"catalogVersion":1,"source":"t","exercises":[{"id":"a","name":"Plank",'
        '"primaryMuscles":["abdominals"],"secondaryMuscles":[],"equipment":"body only",'
        '"category":"strength","level":"beginner","mechanic":null,"force":"static",'
        '"instructions":[],"images":[],"hash":"h"}]}',
      );
      final repo = await container.read(exerciseCatalogProvider.future);
      final found = await repo.search(const ExerciseQuery(text: 'pla'));
      expect(found.single.name, 'Plank');
    });

    test(
      'AC10 a failed import surfaces an error, leaves no catalog and retries next launch',
      () async {
        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);
        final failing = ProviderContainer(
          overrides: [
            ...signedInOverrides(),
            appDatabaseProvider.overrideWithValue(db),
            seedLoaderProvider.overrideWithValue(
              () async => throw const FormatException('corrupt seed'),
            ),
          ],
        );
        final errored = Completer<void>();
        failing.listen(exerciseCatalogProvider, (_, next) {
          if (next.hasError && !errored.isCompleted) errored.complete();
        }, fireImmediately: true);
        await errored.future;
        expect(await db.select(db.catalogExercises).get(), isEmpty);
        failing.dispose();

        final relaunch = ProviderContainer(
          overrides: [
            ...signedInOverrides(),
            appDatabaseProvider.overrideWithValue(db),
            seedLoaderProvider.overrideWithValue(
              () async => File('assets/exercises/seed.json').readAsString(),
            ),
          ],
        );
        addTearDown(relaunch.dispose);
        final repo = await relaunch.read(exerciseCatalogProvider.future);
        expect(await repo.search(const ExerciseQuery()), hasLength(876));
      },
    );

    test(
      'AC3 the bundled seed asset loads through the default loader',
      () async {
        TestWidgetsFlutterBinding.ensureInitialized();
        final container = ProviderContainer(overrides: signedInOverrides());
        addTearDown(container.dispose);
        final raw = await container.read(seedLoaderProvider)();
        expect(raw, startsWith('{"catalogVersion":'));
      },
    );

    testWidgets('AC10 the first screen shows while the import is pending', (
      tester,
    ) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final never = Completer<String>();
      final container = ProviderContainer(
        overrides: [
          ...signedInOverrides(),
          appDatabaseProvider.overrideWithValue(db),
          seedLoaderProvider.overrideWithValue(() => never.future),
        ],
      );
      addTearDown(container.dispose);
      startCatalogImport(container);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const RepForgeApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(container.read(catalogImportProvider).isLoading, isTrue);
    });
  });
}
