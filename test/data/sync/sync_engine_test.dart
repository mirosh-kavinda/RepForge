import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/data/local/app_database.dart';
import 'package:repforge/data/sync/remote_store.dart';
import 'package:repforge/data/sync/sync_engine.dart';
import 'package:repforge/data/sync/sync_state.dart';
import 'package:repforge/data/sync/synced_writer.dart';
import 'package:repforge/features/goals/data/drift_goal_repository.dart';
import 'package:repforge/features/goals/domain/goal.dart';

import 'fake_remote_store.dart';

const uid = 'u1';

Goal goal(String id, {double target = 100}) => Goal(
  id: id,
  type: GoalType.strength,
  exerciseId: 'Bench_Press',
  startValue: 90,
  target: target,
  createdAt: DateTime.utc(2026, 11),
);

void main() {
  late AppDatabase db;
  late FakeRemoteStore remote;
  late SyncEngine engine;
  late DriftGoalRepository goals;
  late DateTime clock;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    remote = FakeRemoteStore();
    clock = DateTime.utc(2026, 11, 24, 9);
    DateTime now() => clock = clock.add(const Duration(seconds: 1));
    engine = SyncEngine(db, remote, now: now);
    goals = DriftGoalRepository(db, now: now);
  });
  tearDown(() => db.close());

  Future<int> outbox() async => (await db.select(db.outbox).get()).length;

  Future<String?> syncState(String id) async => (await (db.select(
    db.goals,
  )..where((g) => g.id.equals(id))).getSingle()).syncState.name;

  group('SYN-01 push', () {
    test('AC1 edge one write per record, in its latest state', () async {
      await goals.save(goal('a'));
      await goals.updateTarget('a', 110, null);
      await goals.save(goal('b'));
      await engine.push(uid, withBody: true);
      expect(remote.commits.single, hasLength(2));
      expect(remote.doc(uid, 'goals', 'a')!['targetValue'], 110);
      expect(await outbox(), 0);
      expect(await syncState('a'), SyncState.synced.name);
    });

    test('AC2 a failed push keeps everything queued', () async {
      await goals.save(goal('a'));
      remote.failWith = const SyncFailure(SyncErrorKind.offline);
      await expectLater(
        engine.push(uid, withBody: true),
        throwsA(isA<SyncFailure>()),
      );
      expect(await outbox(), 1);
      expect(await syncState('a'), SyncState.pending.name);
      remote.failWith = null;
      await engine.push(uid, withBody: true);
      expect(remote.doc(uid, 'goals', 'a'), isNotNull);
    });

    test(
      'AC2 30 days offline: everything lands, oldest first, ≤ 500 a batch',
      () async {
        for (var day = 0; day < 30; day++) {
          for (var i = 0; i < 20; i++) {
            await goals.save(goal('d$day-$i', target: 100.0 + day));
          }
        }
        await engine.push(uid, withBody: true);
        expect([for (final c in remote.commits) c.length], [500, 100]);
        expect(remote.commits.first.first.id, 'd0-0');
        expect(remote.all(uid, 'goals'), hasLength(600));
        expect(await outbox(), 0);
      },
    );

    test('AC11 a deletion is backed up', () async {
      await goals.save(goal('a'));
      await engine.push(uid, withBody: true);
      await goals.delete('a');
      await engine.push(uid, withBody: true);
      expect(remote.doc(uid, 'goals', 'a')!['deletedAt'], isA<int>());
    });

    test('AC7 body backup off: snapshots wait, the profile goes without '
        'body fields', () async {
      final writer = SyncedWriter(db, now: () => clock);
      await writer.run(
        table: 'user_profiles',
        entity: 'userProfile',
        id: 'p',
        op: OutboxOp.create,
        write: (now) => db
            .into(db.userProfiles)
            .insert(
              UserProfilesCompanion.insert(
                id: const Value('p'),
                units: 'metric',
                heightCm: const Value(170),
                updatedAt: now,
              ),
            ),
      );
      await writer.run(
        table: 'body_snapshots',
        entity: 'bodySnapshot',
        id: 'b',
        op: OutboxOp.create,
        write: (now) => db
            .into(db.bodySnapshots)
            .insert(
              BodySnapshotsCompanion.insert(
                id: const Value('b'),
                date: DateTime.utc(2026, 11, 24),
                weightKg: const Value(80),
                updatedAt: now,
              ),
            ),
      );
      await engine.push(uid, withBody: false);
      expect(remote.doc(uid, 'profile', 'p')!.containsKey('heightCm'), isFalse);
      expect(remote.doc(uid, 'bodySnapshots', 'b'), isNull);
      expect(await outbox(), 1);
      await engine.push(uid, withBody: true);
      expect(remote.doc(uid, 'bodySnapshots', 'b'), isNotNull);
      expect(await outbox(), 0);
    });

    test('edge a refused document is set aside; the rest go', () async {
      for (final id in ['a', 'b', 'c']) {
        await goals.save(goal(id));
      }
      remote.refuse.add('b');
      await engine.push(uid, withBody: true);
      expect(remote.all(uid, 'goals').keys.toSet(), {'a', 'c'});
      expect(await outbox(), 0);
      expect(await db.readMeta('sync.setAside.goal.b'), isNotNull);
      expect(await syncState('b'), SyncState.pending.name);
    });

    test('edge times with microseconds are still marked synced', () async {
      final fine = DriftGoalRepository(
        db,
        now: () => DateTime.utc(2026, 11, 24, 9, 0, 0, 123, 456),
      );
      await fine.save(goal('a'));
      await engine.push(uid, withBody: true);
      expect(await syncState('a'), SyncState.synced.name);
    });

    test('AC10 status updates when only an error is recorded', () async {
      final seen = <SyncErrorKind?>[];
      final sub = engine.watchStatus().listen((s) => seen.add(s.error));
      await pumpEventQueue();
      await engine.recordError(SyncErrorKind.offline);
      await pumpEventQueue();
      await sub.cancel();
      expect(seen, [null, SyncErrorKind.offline]);
    });

    test('AC9 status: waiting count and last backed up', () async {
      await goals.save(goal('a'));
      await goals.updateTarget('a', 105, null);
      await goals.save(goal('b'));
      var s = await engine.watchStatus().first;
      expect((s.waiting, s.backedUpAt), (2, null));
      await engine.push(uid, withBody: true);
      s = await engine.watchStatus().first;
      expect(s.waiting, 0);
      expect(s.backedUpAt, isNotNull);
      await engine.recordError(SyncErrorKind.offline);
      expect((await engine.watchStatus().first).error, SyncErrorKind.offline);
    });
  });

  group('SYN-01 pull', () {
    Map<String, Object?> doc(String id, int updatedAt, {double target = 120}) =>
        {
          'id': id,
          'type': 'strength',
          'exerciseId': 'Bench_Press',
          'startValue': 90.0,
          'targetValue': target,
          'deadline': null,
          'pinned': false,
          'createdAt': DateTime.utc(2026, 11).millisecondsSinceEpoch,
          'achievedAt': null,
          'updatedAt': updatedAt,
          'deletedAt': null,
        };

    test('AC4 a change from my other phone arrives', () async {
      remote.put(uid, 'goals', 'x', doc('x', 1000));
      await engine.pull(uid);
      final all = await goals.watchAll().first;
      expect(all.single.target, 120);
      expect(await syncState('x'), SyncState.synced.name);
      expect(await outbox(), 0, reason: 'pulling is not a local change');
    });

    test('AC5 edge a newer unsent local change wins', () async {
      await goals.save(goal('x', target: 101));
      final localAt = (await (db.select(
        db.goals,
      )..where((g) => g.id.equals('x'))).getSingle()).updatedAt;
      remote.put(
        uid,
        'goals',
        'x',
        doc('x', localAt.millisecondsSinceEpoch - 1000),
      );
      await engine.pull(uid);
      expect((await goals.watchAll().first).single.target, 101);
      remote.put(
        uid,
        'goals',
        'x',
        doc('x', localAt.millisecondsSinceEpoch + 1000, target: 130),
      );
      await engine.pull(uid);
      expect((await goals.watchAll().first).single.target, 130);
    });

    test('AC11 a deletion from my other phone hides it here', () async {
      await goals.save(goal('x'));
      await engine.push(uid, withBody: true);
      final d = Map.of(remote.doc(uid, 'goals', 'x')!)
        ..['updatedAt'] =
            (remote.doc(uid, 'goals', 'x')!['updatedAt']! as int) + 5000
        ..['deletedAt'] = 99;
      remote.put(uid, 'goals', 'x', d);
      await engine.pull(uid);
      expect(await goals.watchAll().first, isEmpty);
    });

    test('AC4 the cursor is server time, kept per account', () async {
      remote.put(uid, 'goals', 'x', doc('x', 1000));
      await engine.pull(uid);
      final first = await db.readMeta('sync.pulledAt.$uid.goals');
      expect(first, '${remote.serverTime}');
      remote.put(uid, 'goals', 'y', doc('y', 2000));
      await engine.pull(uid);
      expect(await goals.watchAll().first, hasLength(2));
      expect(await db.readMeta('sync.pulledAt.other.goals'), isNull);
    });

    test(
      'AC2 AC4 a late upload with an old updatedAt is still pulled',
      () async {
        remote.put(uid, 'goals', 'new', doc('new', 9000));
        await engine.pull(uid);
        // The other phone was offline for weeks: its change is older, but
        // reaches the server now.
        remote.put(uid, 'goals', 'old', doc('old', 10));
        await engine.pull(uid);
        expect(
          {for (final g in await goals.watchAll().first) g.id},
          {'new', 'old'},
        );
      },
    );

    test('edge a document that can\'t be applied is skipped', () async {
      remote.put(uid, 'goals', 'bad', {...doc('bad', 1000), 'type': null});
      remote.put(uid, 'goals', 'good', doc('good', 1000));
      await engine.pull(uid);
      expect([for (final g in await goals.watchAll().first) g.id], ['good']);
    });

    test('edge pulled times come back in UTC', () async {
      remote.put(uid, 'scheduleDays', 'd', {
        'id': 'd',
        'cycleId': 'c',
        'date': DateTime.utc(2026, 11, 20).millisecondsSinceEpoch,
        'dayId': 'a',
        'dayIndex': 0,
        'status': 'done',
        'workoutId': null,
        'linkedDate': null,
        'updatedAt': 1000,
        'deletedAt': null,
      });
      await engine.pull(uid);
      final row = await db.select(db.scheduleDays).getSingle();
      expect(row.date, DateTime.utc(2026, 11, 20));
      expect(row.date.isUtc, isTrue);
    });

    test(
      'edge two phones marked the same day: the newer record wins',
      () async {
        await db
            .into(db.scheduleDays)
            .insert(
              ScheduleDaysCompanion.insert(
                id: const Value('mine'),
                cycleId: 'c',
                date: DateTime.utc(2026, 11, 20),
                dayId: 'a',
                dayIndex: 0,
                status: 'missed',
                updatedAt: DateTime.utc(2026, 11, 20, 1),
              ),
            );
        remote.put(uid, 'scheduleDays', 'theirs', {
          'id': 'theirs',
          'cycleId': 'c',
          'date': DateTime.utc(2026, 11, 20).millisecondsSinceEpoch,
          'dayId': 'a',
          'dayIndex': 0,
          'status': 'done',
          'workoutId': null,
          'linkedDate': null,
          'updatedAt': DateTime.utc(2026, 11, 20, 9).millisecondsSinceEpoch,
          'deletedAt': null,
        });
        await engine.pull(uid);
        final rows = await db.select(db.scheduleDays).get();
        expect([for (final r in rows) (r.id, r.status)], [('theirs', 'done')]);
      },
    );

    test(
      'AC5 a finished workout here keeps its sets; its note follows',
      () async {
        final t = DateTime.utc(2026, 11, 24, 9);
        await db
            .into(db.workoutSessions)
            .insert(
              WorkoutSessionsCompanion.insert(
                id: const Value('s'),
                name: 'Push',
                exercises: '[]',
                date: DateTime.utc(2026, 11, 24),
                startedAt: t,
                endedAt: Value(t),
                updatedAt: t,
              ),
            );
        remote.put(uid, 'sessions', 's', {
          'id': 's',
          'name': 'Changed',
          'exercises': '[]',
          'templateId': null,
          'cycleId': null,
          'dayId': null,
          'dayIndex': null,
          'date': DateTime.utc(2026, 11, 24).millisecondsSinceEpoch,
          'startedAt': t.millisecondsSinceEpoch,
          'endedAt': t.millisecondsSinceEpoch,
          'note': 'from my other phone',
          'updatedAt': t.millisecondsSinceEpoch + 5000,
          'deletedAt': null,
          'sets': [
            {
              'id': 'x',
              'sessionId': 's',
              'rowId': 'r',
              'exerciseId': 'e',
              'setNo': 1,
              'kg': 1.0,
              'reps': 1,
              'seconds': null,
              'isPr': false,
              'loggedAt': t.millisecondsSinceEpoch,
              'updatedAt': t.millisecondsSinceEpoch,
            },
          ],
        });
        await engine.pull(uid);
        final s = await db.select(db.workoutSessions).getSingle();
        expect(s.name, 'Push');
        expect(s.note, 'from my other phone');
        expect(await db.select(db.sessionSets).get(), isEmpty);
      },
    );

    test('edge a run for a signed-out account writes nothing', () async {
      remote.put(uid, 'goals', 'x', doc('x', 1000));
      await engine.pull(uid, current: () => false);
      expect(await goals.watchAll().first, isEmpty);
      expect(await db.readMeta('sync.pulledAt.$uid.goals'), isNull);
    });

    test('AC5 a finished workout in the cloud is never replaced', () async {
      final writer = SyncedWriter(db, now: () => clock);
      await writer.run(
        table: 'workout_sessions',
        entity: 'session',
        id: 's',
        op: OutboxOp.create,
        write: (now) => db
            .into(db.workoutSessions)
            .insert(
              WorkoutSessionsCompanion.insert(
                id: const Value('s'),
                name: 'Push',
                exercises: '[]',
                date: DateTime.utc(2026, 11, 24),
                startedAt: now,
                endedAt: Value(now),
                updatedAt: now,
              ),
            ),
      );
      await engine.push(uid, withBody: true);
      remote.put(uid, 'sessions', 's', {
        ...remote.doc(uid, 'sessions', 's')!,
        'name': 'Changed',
      });
      await expectLater(
        remote.commit(uid, [
          (
            collection: 'sessions',
            id: 's',
            data: {...remote.doc(uid, 'sessions', 's')!, 'name': 'Again'},
          ),
        ]),
        throwsA(isA<SyncFailure>()),
      );
    });
  });
}
