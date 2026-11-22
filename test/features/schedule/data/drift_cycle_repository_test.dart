import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/data/local/app_database.dart';
import 'package:repforge/data/local/local_data_wiper.dart';
import 'package:repforge/data/sync/sync_state.dart';
import 'package:repforge/features/schedule/data/drift_cycle_repository.dart';
import 'package:repforge/features/schedule/domain/cycle.dart';
import 'package:repforge/features/schedule/domain/cycle_repository.dart';

void main() {
  late AppDatabase db;
  late DriftCycleRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftCycleRepository(db);
  });
  tearDown(() => db.close());

  Cycle cycle(String id, {String name = 'PPL', bool active = true}) => Cycle(
    id: id,
    name: name,
    days: const [
      CycleDay(id: 'd1', workoutId: 'push'),
      CycleDay(id: 'd2'),
    ],
    isActive: active,
    startDate: DateTime.utc(2026, 11, 21),
    startDayIndex: 1,
  );

  Future<List<(String, OutboxOp)>> outbox() async => [
    for (final r in await db.select(db.outbox).get()) (r.entityId, r.op),
  ];

  group('SCH-01 cycle repository', () {
    test('AC13 save round-trips every field and queues a create', () async {
      await repo.save(cycle('a'));
      expect(await repo.byId('a'), cycle('a'));
      expect(await repo.watchActive().first, cycle('a'));
      expect(await outbox(), [('a', OutboxOp.create)]);
    });

    test('AC5 saving an active cycle deactivates the others', () async {
      await repo.save(cycle('a'));
      await repo.save(cycle('b', name: 'Upper'));
      expect((await repo.byId('a'))!.isActive, isFalse);
      expect((await repo.watchActive().first)!.id, 'b');
      expect(await outbox(), [
        ('a', OutboxOp.create),
        ('a', OutboxOp.update),
        ('b', OutboxOp.create),
      ]);
    });

    test('AC9 saving an inactive cycle leaves the active one alone', () async {
      await repo.save(cycle('a'));
      await repo.save(cycle('b', active: false));
      expect((await repo.watchActive().first)!.id, 'a');
      expect((await repo.watchAll().first).map((c) => c.name), ['PPL', 'PPL']);
    });

    test(
      'AC9 the active cycle cannot be deleted; others delete and undo',
      () async {
        await repo.save(cycle('a'));
        await repo.save(cycle('b', active: false));
        final before = (await outbox()).length;
        await expectLater(
          repo.delete('a'),
          throwsA(isA<ActiveCycleDeleteError>()),
        );
        expect(await outbox(), hasLength(before), reason: 'AC13 refused');
        await repo.delete('b');
        expect((await repo.watchAll().first).map((c) => c.id), ['a']);
        expect(await repo.byId('b'), isNull);
        expect((await outbox()).last, ('b', OutboxOp.delete), reason: 'AC13');
        await repo.restore('b');
        expect(await repo.byId('b'), cycle('b', active: false));
        expect((await outbox()).last, ('b', OutboxOp.update), reason: 'AC13');
      },
    );

    test('sign-out wipes cycles', () async {
      await repo.save(cycle('a'));
      await LocalDataWiper(db).wipeUserData();
      expect(await repo.watchAll().first, isEmpty);
    });
  });
}
