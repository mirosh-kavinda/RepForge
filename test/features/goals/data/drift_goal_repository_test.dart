import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/data/local/app_database.dart';
import 'package:repforge/data/local/local_data_wiper.dart';
import 'package:repforge/features/goals/data/drift_goal_repository.dart';
import 'package:repforge/features/goals/domain/goal.dart';

Goal goal(String id, {int day = 1, bool pinned = false}) => Goal(
  id: id,
  type: GoalType.strength,
  exerciseId: 'Bench_Press',
  startValue: 90,
  target: 100,
  deadline: DateTime.utc(2027, 2, 1),
  pinned: pinned,
  createdAt: DateTime.utc(2026, 11, day),
);

void main() {
  late AppDatabase db;
  late DriftGoalRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftGoalRepository(db, now: () => DateTime.utc(2026, 11, 24, 9));
  });
  tearDown(() => db.close());

  Future<List<String>> outbox() async => [
    for (final r in await db.select(db.outbox).get())
      '${r.entity}:${r.op.name}',
  ];

  group('GOL-01 goal repository', () {
    test('AC12 saved on the phone, newest first, queued for backup', () async {
      await repo.save(goal('a'));
      await repo.save(goal('b', day: 5));
      final all = await repo.watchAll().first;
      expect([for (final g in all) g.id], ['b', 'a']);
      expect(all.last, goal('a'));
      expect(await outbox(), ['goal:create', 'goal:create']);
    });

    test('AC8 saving again replaces it as an update', () async {
      await repo.save(goal('a'));
      await repo.save(goal('a').copyWith(target: 105, deadline: null));
      final g = (await repo.watchAll().first).single;
      expect((g.target, g.deadline, g.startValue), (105, null, 90));
      expect(await outbox(), ['goal:create', 'goal:update']);
    });

    test('AC10 pinning one unpins the others', () async {
      await repo.save(goal('a', pinned: true));
      await repo.save(goal('b', day: 2));
      await repo.pin('b');
      final all = await repo.watchAll().first;
      expect({for (final g in all) g.id: g.pinned}, {'a': false, 'b': true});
      await repo.unpin('b');
      expect((await repo.watchAll().first).every((g) => !g.pinned), isTrue);
    });

    test('AC6 AC7 achieving sets the date and unpins', () async {
      await repo.save(goal('a', pinned: true));
      await repo.achieve('a', DateTime.utc(2026, 11, 20));
      final g = (await repo.watchAll().first).single;
      expect(g.achievedAt, DateTime.utc(2026, 11, 20));
      expect(g.pinned, isFalse);
      expect(g.isActive, isFalse);
    });

    test('AC9 delete hides it; restore brings it back', () async {
      await repo.save(goal('a'));
      await repo.delete('a');
      expect(await repo.watchAll().first, isEmpty);
      await repo.restore('a');
      expect(await repo.watchAll().first, hasLength(1));
      expect(await outbox(), ['goal:create', 'goal:delete', 'goal:update']);
    });

    test('sign-out wipes goals', () async {
      await repo.save(goal('a'));
      await LocalDataWiper(db).wipeUserData();
      expect(await db.select(db.goals).get(), isEmpty);
    });
  });

  group('GOL-01 review fixes', () {
    test('AC9 AC10 Undo restores unpinned, so one pin at most', () async {
      await repo.save(goal('a'));
      await repo.save(goal('b', day: 2));
      await repo.pin('a');
      await repo.delete('a');
      await repo.pin('b');
      await repo.restore('a');
      final pins = [
        for (final g in await repo.watchAll().first)
          if (g.pinned) g.id,
      ];
      expect(pins, ['b']);
    });

    test('AC8 an edit changes target and deadline only', () async {
      await repo.save(goal('a'));
      await repo.achieve('a', DateTime.utc(2026, 11, 20));
      await repo.updateTarget('a', 105, null);
      final g = (await repo.watchAll().first).single;
      expect((g.target, g.deadline, g.startValue), (105, null, 90));
      expect(g.achievedAt, DateTime.utc(2026, 11, 20));
      expect(await outbox(), ['goal:create', 'goal:update', 'goal:update']);
    });
  });
}
