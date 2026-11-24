import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/data/local/app_database.dart';
import 'package:repforge/features/library/data/combined_catalog.dart';
import 'package:repforge/features/library/data/drift_custom_exercise_repository.dart';
import 'package:repforge/features/library/data/drift_exercise_catalog_repository.dart';
import 'package:repforge/features/library/domain/exercise.dart';
import 'package:repforge/features/library/domain/exercise_query.dart';

import '../fake_custom_exercise_repository.dart';
import '../library_fakes.dart';

Exercise mine(String id, String name, {Muscle muscle = Muscle.quadriceps}) =>
    ex(id, name, [muscle], equipment: Equipment.machine).copyWith(custom: true);

void main() {
  group('EXL-03 combined catalog', () {
    late FakeCustomExerciseRepository custom;
    late CombinedCatalog catalog;

    setUp(() {
      custom = FakeCustomExerciseRepository([
        mine('c1', 'Hack Squat'),
        mine('c2', 'Cable Fly Low', muscle: Muscle.chest),
      ]);
      catalog = CombinedCatalog(LibraryCatalog(), custom);
    });

    List<String> names(List<Exercise> l) => [for (final e in l) e.name];

    test('AC3 browsing: one A–Z list with mine in it', () async {
      expect(names(await catalog.search(const ExerciseQuery())), [
        'Barbell Squat',
        'Bench Press',
        'Cable Fly Low',
        'Hack Squat',
        'Leg Press',
        'Plank',
      ]);
    });

    test('AC3 searching: my matches first, then the catalog', () async {
      expect(names(await catalog.search(const ExerciseQuery(text: 'squat'))), [
        'Hack Squat',
        'Barbell Squat',
      ]);
      expect(
        names(
          await catalog.search(const ExerciseQuery(muscles: {Muscle.chest})),
        ),
        ['Cable Fly Low', 'Bench Press'],
      );
      expect(
        names(
          await catalog.search(
            const ExerciseQuery(equipment: {Equipment.machine}),
          ),
        ),
        ['Cable Fly Low', 'Hack Squat', 'Leg Press'],
      );
    });

    test('AC7 deleted: not found by search, still by id', () async {
      await custom.delete('c1');
      expect(
        names(await catalog.search(const ExerciseQuery(text: 'hack'))),
        isEmpty,
      );
      expect((await catalog.byId('c1'))!.name, 'Hack Squat');
      expect((await catalog.byId('Plank'))!.name, 'Plank');
    });

    test('NFR-01 200 custom exercises search well under 100 ms', () async {
      custom = FakeCustomExerciseRepository([
        for (var i = 0; i < 200; i++) mine('x$i', 'Custom Move $i'),
      ]);
      catalog = CombinedCatalog(LibraryCatalog(), custom);
      final sw = Stopwatch()..start();
      final hits = await catalog.search(const ExerciseQuery(text: 'move 19'));
      sw.stop();
      expect(names(hits), contains('Custom Move 19'));
      expect(sw.elapsedMilliseconds, lessThan(100));
    });
  });

  test('EXL-03 NFR-01 on Drift: 200 custom, search < 100 ms', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = DriftCustomExerciseRepository(db);
    for (var i = 0; i < 200; i++) {
      await repo.save(mine('x$i', 'Custom Move $i'));
    }
    final catalog = CombinedCatalog(DriftExerciseCatalogRepository(db), repo);
    await catalog.search(const ExerciseQuery(text: 'warm up'));
    final sw = Stopwatch()..start();
    final hits = await catalog.search(const ExerciseQuery(text: 'move 19'));
    sw.stop();
    expect([for (final e in hits) e.name], contains('Custom Move 19'));
    expect(sw.elapsedMilliseconds, lessThan(100));
  });
}
