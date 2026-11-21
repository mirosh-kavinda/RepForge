import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/features/library/domain/exercise.dart';
import 'package:repforge/features/library/domain/exercise_catalog_repository.dart';
import 'package:repforge/features/library/domain/exercise_query.dart';

import '../../../../tool/seed/seed_builder.dart' as seed;

class _InMemoryCatalog implements ExerciseCatalogRepository {
  _InMemoryCatalog(this.items);

  final List<Exercise> items;

  @override
  Future<Exercise?> byId(String id) async =>
      items.where((e) => e.id == id).firstOrNull;

  @override
  Future<List<Exercise>> search(ExerciseQuery query) async => items;
}

void main() {
  group('FND-03 taxonomy', () {
    test('domain enums cover exactly the seed taxonomy', () {
      expect(Muscle.values.map((e) => e.key).toSet(), seed.muscles);
      expect(Equipment.values.map((e) => e.key).toSet(), seed.equipment);
      expect(
        ExerciseCategory.values.map((e) => e.key).toSet(),
        seed.categories,
      );
      expect(ExerciseLevel.values.map((e) => e.key).toSet(), seed.levels);
      expect(Mechanic.values.map((e) => e.key).toSet(), seed.mechanics);
      expect(Force.values.map((e) => e.key).toSet(), seed.forces);
    });

    test('fromKey round-trips and rejects unknown keys', () {
      expect(Muscle.fromKey('middle back'), Muscle.middleBack);
      expect(Equipment.fromKey('EZ bar'), Equipment.ezBar);
      expect(() => Muscle.fromKey('wings'), throwsArgumentError);
    });

    test('AC4 AC5 empty query has no text and no filters', () {
      const q = ExerciseQuery();
      expect(q.isEmpty, isTrue);
      expect(q.copyWith(text: ' ').isEmpty, isTrue);
      expect(q.copyWith(muscles: {Muscle.chest}).isEmpty, isFalse);
    });

    test('Exercise has value equality', () {
      Exercise make() => const Exercise(
        id: 'a',
        name: 'A',
        primaryMuscles: [Muscle.chest],
        secondaryMuscles: [],
        equipment: Equipment.barbell,
        category: ExerciseCategory.strength,
        level: ExerciseLevel.beginner,
        instructions: [],
        images: [],
      );
      expect(make(), make());
    });

    test(
      'the repository contract can be implemented without the data layer',
      () async {
        const plank = Exercise(
          id: 'plank',
          name: 'Plank',
          primaryMuscles: [Muscle.abdominals],
          secondaryMuscles: [],
          equipment: Equipment.bodyOnly,
          category: ExerciseCategory.strength,
          level: ExerciseLevel.beginner,
          instructions: [],
          images: [],
        );
        final ExerciseCatalogRepository repo = _InMemoryCatalog([plank]);
        expect(await repo.byId('plank'), plank);
        expect(await repo.search(const ExerciseQuery()), [plank]);
      },
    );
  });
}
