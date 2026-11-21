import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:repforge/data/local/app_database.dart';
import 'package:repforge/features/library/data/catalog_importer.dart';
import 'package:repforge/features/library/data/drift_exercise_catalog_repository.dart';
import 'package:repforge/features/library/domain/exercise.dart';
import 'package:repforge/features/library/domain/exercise_query.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('FND-03 AC6 search p95 < 100 ms on device', (tester) async {
    await tester.runAsync(() async {
      // Same file-backed, background-isolate setup as openAppDatabase(), separate file.
      final db = AppDatabase(driftDatabase(name: 'fnd03_perf'));
      final seed = await rootBundle.loadString('assets/exercises/seed.json');

      final importTimer = Stopwatch()..start();
      final importResult = await CatalogImporter(
        db,
        loadSeed: () async => seed,
      ).run();
      importTimer.stop();

      final repo = DriftExerciseCatalogRepository(db);
      const queries = [
        ExerciseQuery(text: 'bench'),
        ExerciseQuery(text: 'dumbbell curl'),
        ExerciseQuery(text: 's'),
        ExerciseQuery(text: 'pr'),
        ExerciseQuery(muscles: {Muscle.chest, Muscle.triceps}),
        ExerciseQuery(
          muscles: {Muscle.quadriceps},
          levels: {ExerciseLevel.beginner},
        ),
        ExerciseQuery(
          text: 'press',
          equipment: {Equipment.barbell, Equipment.dumbbell},
        ),
        ExerciseQuery(categories: {ExerciseCategory.stretching}),
        ExerciseQuery(),
      ];
      for (final q in queries) {
        await repo.search(q);
      }
      final times = <double>[];
      for (var i = 0; i < 200; i++) {
        final sw = Stopwatch()..start();
        await repo.search(queries[i % queries.length]);
        times.add(sw.elapsedMicroseconds / 1000);
      }
      times.sort();
      final p50 = times[times.length ~/ 2];
      final p95 = times[(times.length * 0.95).floor() - 1];
      final worstFiltered = times.last;
      binding.reportData = {
        'import': importResult.name,
        'importMs': importTimer.elapsedMilliseconds,
        'p50Ms': p50,
        'p95Ms': p95,
        'maxMs': worstFiltered,
      };
      // ignore: avoid_print
      print(
        'FND03 import(${importResult.name})=${importTimer.elapsedMilliseconds}ms p50=$p50 p95=$p95 max=$worstFiltered',
      );
      await db.close();
      expect(p95, lessThan(100));
    });
  });
}
