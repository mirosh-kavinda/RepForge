import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/data/local/app_database.dart';
import 'package:repforge/data/local/local_data_wiper.dart';
import 'package:repforge/data/sync/sync_state.dart';
import 'package:repforge/features/workout/data/drift_template_repository.dart';
import 'package:repforge/features/workout/data/starter_templates.dart';
import 'package:repforge/features/workout/domain/workout_template.dart';

void main() {
  late AppDatabase db;
  late DriftTemplateRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftTemplateRepository(db);
  });
  tearDown(() => db.close());

  const legs = WorkoutTemplate(
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
        superset: 'A',
      ),
      TemplateExercise(
        id: 'r2',
        exerciseId: 'Plank',
        kind: TargetKind.time,
        seconds: 45,
        superset: 'A',
      ),
    ],
  );

  Future<List<(String, String, OutboxOp)>> outbox() async => [
    for (final r in await db.select(db.outbox).get())
      (r.entity, r.entityId, r.op),
  ];

  group('WKT-01 template repository', () {
    test('AC13 save round-trips every field and queues a create', () async {
      await repo.save(legs);
      expect(await repo.byId('t1'), legs);
      expect(await outbox(), [('workoutTemplate', 't1', OutboxOp.create)]);
      final row = await db.select(db.workoutTemplates).getSingle();
      expect(row.syncState, SyncState.pending);
    });

    test('AC13 saving again updates in place and queues an update', () async {
      await repo.save(legs);
      await repo.save(legs.copyWith(name: 'Legs B'));
      expect((await repo.byId('t1'))!.name, 'Legs B');
      expect(await db.select(db.workoutTemplates).get(), hasLength(1));
      expect((await outbox()).last, ('workoutTemplate', 't1', OutboxOp.update));
    });

    test('AC1 watchAll lists active workouts A–Z, ignoring case', () async {
      await repo.save(legs.copyWith(id: 'a', name: 'push'));
      await repo.save(legs.copyWith(id: 'b', name: 'Arms'));
      await repo.save(legs.copyWith(id: 'c', name: 'Legs'));
      final names = (await repo.watchAll().first).map((t) => t.name);
      expect(names, ['Arms', 'Legs', 'push']);
    });

    test('AC11 delete hides it, restore brings it back unchanged', () async {
      await repo.save(legs);
      await repo.delete('t1');
      expect(await repo.watchAll().first, isEmpty);
      expect(await repo.byId('t1'), isNull);
      await repo.restore('t1');
      expect(await repo.byId('t1'), legs);
      expect((await outbox()).map((o) => o.$3), [
        OutboxOp.create,
        OutboxOp.delete,
        OutboxOp.update,
      ]);
    });
  });

  group('WKT-01 starters', () {
    test('AC12 first run seeds six editable starters once', () async {
      await repo.ensureStarters();
      final all = await repo.watchAll().first;
      expect(all.map((t) => t.name).toSet(), {
        'Push',
        'Pull',
        'Legs',
        'Upper',
        'Lower',
        'Full Body',
      });
      for (final t in all) {
        expect(t.id, isNotEmpty);
        expect(t.exercises.length, inInclusiveRange(5, 6));
        expect(
          t.exercises.map((e) => e.id).toSet(),
          hasLength(t.exercises.length),
        );
      }
      expect(await outbox(), hasLength(6));

      await repo.ensureStarters();
      expect(await repo.watchAll().first, hasLength(6));
    });

    test('AC12 deleted starters are not recreated', () async {
      await repo.ensureStarters();
      for (final t in await repo.watchAll().first) {
        await repo.delete(t.id);
      }
      await repo.ensureStarters();
      expect(await repo.watchAll().first, isEmpty);
    });

    test('AC12 a new user after sign-out gets starters again', () async {
      await repo.ensureStarters();
      await LocalDataWiper(db).wipeUserData();
      expect(await repo.watchAll().first, isEmpty);
      await repo.ensureStarters();
      expect(await repo.watchAll().first, hasLength(6));
    });

    test('AC12 starter list matches the spec', () {
      expect(starterTemplates.map((t) => t.name), [
        'Push',
        'Pull',
        'Legs',
        'Upper',
        'Lower',
        'Full Body',
      ]);
    });
  });
}
