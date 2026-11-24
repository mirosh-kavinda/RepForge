import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/data/local/app_database.dart';
import 'package:repforge/data/sync/sync_state.dart';
import 'package:repforge/features/library/data/drift_custom_exercise_repository.dart';
import 'package:repforge/features/library/domain/custom_exercise_repository.dart';
import 'package:repforge/features/library/domain/exercise.dart';

Exercise custom(String id, String name, {String? notes}) => Exercise(
  id: id,
  name: name,
  primaryMuscles: const [Muscle.quadriceps],
  secondaryMuscles: const [Muscle.glutes],
  equipment: Equipment.machine,
  category: ExerciseCategory.strength,
  level: ExerciseLevel.beginner,
  instructions: const [],
  images: const [],
  notes: notes,
);

void main() {
  late AppDatabase db;
  late DriftCustomExerciseRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftCustomExerciseRepository(
      db,
      now: () => DateTime.utc(2026, 11, 23, 10),
    );
    await db
        .into(db.catalogExercises)
        .insert(
          CatalogExercisesCompanion.insert(
            id: 'Leg_Press',
            name: 'Leg Press',
            equipment: 'machine',
            category: 'strength',
            level: 'beginner',
            instructions: '[]',
            images: '[]',
            contentHash: 'h',
          ),
        );
  });
  tearDown(() => db.close());

  Future<List<(String, OutboxOp)>> outbox() async => [
    for (final r in await db.select(db.outbox).get()) (r.entity, r.op),
  ];

  group('EXL-03 custom exercise repository', () {
    test('AC1 AC8 saved on the phone and queued for sync', () async {
      await repo.save(custom('c1', '  Hack   Squat ', notes: ' Seat 4 '));
      final e = (await repo.byId('c1'))!;
      expect(e.name, 'Hack Squat');
      expect(e.custom, isTrue);
      expect(e.notes, 'Seat 4');
      expect(e.primaryMuscles, [Muscle.quadriceps]);
      expect(e.secondaryMuscles, [Muscle.glutes]);
      expect(e.equipment, Equipment.machine);
      expect(await outbox(), [('customExercise', OutboxOp.create)]);
    });

    test('AC6 an edit is an update', () async {
      await repo.save(custom('c1', 'Hack Squat'));
      await repo.save(custom('c1', 'Hack Squat (Gym 2)'));
      expect((await repo.byId('c1'))!.name, 'Hack Squat (Gym 2)');
      expect((await outbox()).last, ('customExercise', OutboxOp.update));
    });

    test('AC7 delete hides it but byId still finds it; restore', () async {
      await repo.save(custom('c1', 'Hack Squat'));
      await repo.save(custom('c2', 'Belt Squat'));
      await repo.delete('c1');
      expect([for (final e in await repo.watchAll().first) e.id], ['c2']);
      expect((await repo.byId('c1'))!.name, 'Hack Squat');
      await repo.restore('c1');
      expect(
        [for (final e in await repo.watchAll().first) e.name],
        ['Belt Squat', 'Hack Squat'],
      );
      expect((await outbox()).map((e) => e.$2), [
        OutboxOp.create,
        OutboxOp.create,
        OutboxOp.delete,
        OutboxOp.update,
      ]);
    });

    test('AC2 name clashes with mine or the catalog', () async {
      await repo.save(custom('c1', 'Hack Squat'));
      expect(await repo.nameClash('hack  squat'), NameClash.custom);
      expect(
        await repo.nameClash('Hack Squat', exceptId: 'c1'),
        NameClash.none,
      );
      expect(await repo.nameClash(' leg press'), NameClash.catalog);
      expect(await repo.nameClash('Belt Squat'), NameClash.none);
    });

    test('edge a deleted name can be reused', () async {
      await repo.save(custom('c1', 'Hack Squat'));
      await repo.delete('c1');
      expect(await repo.nameClash('Hack Squat'), NameClash.none);
    });

    test('edge a retired catalog name does not clash', () async {
      await db
          .update(db.catalogExercises)
          .write(
            CatalogExercisesCompanion(retiredAt: Value(DateTime.utc(2026))),
          );
      expect(await repo.nameClash('Leg Press'), NameClash.none);
    });
  });
}
