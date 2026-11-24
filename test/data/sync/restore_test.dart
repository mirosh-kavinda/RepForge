import 'package:drift/drift.dart' show Table, TableInfo;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/data/local/app_database.dart';
import 'package:repforge/data/local/local_data_wiper.dart';
import 'package:repforge/data/sync/remote_store.dart';
import 'package:repforge/data/sync/restore.dart';
import 'package:repforge/data/sync/sync_engine.dart';
import 'package:repforge/features/goals/data/drift_goal_repository.dart';
import 'package:repforge/features/goals/domain/goal.dart';
import 'package:repforge/features/logger/data/drift_session_repository.dart';
import 'package:repforge/features/schedule/data/drift_day_record_repository.dart';

import 'fake_remote_store.dart';

const uid = 'u1';
final t0 = DateTime.utc(2024, 11, 24, 9);

Map<String, Object?> goalDoc(String id, {int updatedAt = 1000}) => {
  'id': id,
  'type': 'strength',
  'exerciseId': 'Bench_Press',
  'startValue': 90.0,
  'targetValue': 100.0,
  'deadline': null,
  'pinned': false,
  'createdAt': t0.millisecondsSinceEpoch,
  'achievedAt': null,
  'updatedAt': updatedAt,
  'deletedAt': null,
};

Map<String, Object?> sessionDoc(String id, DateTime day, {int sets = 3}) {
  final at = day.add(const Duration(hours: 9)).millisecondsSinceEpoch;
  return {
    'id': id,
    'templateId': null,
    'name': 'Push',
    'exercises': '[]',
    'cycleId': null,
    'dayId': null,
    'dayIndex': null,
    'date': day.millisecondsSinceEpoch,
    'startedAt': at,
    'endedAt': at + 3600000,
    'note': null,
    'updatedAt': at,
    'deletedAt': null,
    'sets': [
      for (var i = 1; i <= sets; i++)
        {
          'id': '$id-$i',
          'sessionId': id,
          'rowId': 'r',
          'exerciseId': 'Bench_Press',
          'setNo': i,
          'kg': 60.0 + i,
          'reps': 8,
          'seconds': null,
          'isPr': i == sets,
          'loggedAt': at + i * 60000,
          'updatedAt': at,
        },
    ],
  };
}

Map<String, Object?> dayDoc(String id, DateTime day) => {
  'id': id,
  'cycleId': 'c',
  'date': day.millisecondsSinceEpoch,
  'dayId': 'a',
  'dayIndex': 0,
  'status': 'done',
  'workoutId': null,
  'linkedDate': null,
  'updatedAt': day.millisecondsSinceEpoch,
  'deletedAt': null,
};

void main() {
  late AppDatabase db;
  late FakeRemoteStore remote;
  late SyncEngine engine;
  late RestoreStore restore;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    remote = FakeRemoteStore();
    engine = SyncEngine(db, remote, now: () => DateTime.utc(2026, 11, 24));
    restore = RestoreStore(db);
  });
  tearDown(() => db.close());

  Future<int> local(TableInfo<Table, Object?> t) async =>
      (await db.select(t).get()).length;

  group('SYN-02 offer', () {
    test('AC1 a backup waits for the choice; nothing comes down', () async {
      remote.put(uid, 'goals', 'g', goalDoc('g'));
      await engine.pull(uid);
      expect(await restore.read(uid), RestoreState.offered);
      expect(await local(db.goals), 0);
      // Still waiting on the next run.
      await engine.pull(uid);
      expect(await local(db.goals), 0);
    });

    test('edge no backup: syncing just starts', () async {
      await engine.pull(uid);
      expect(await restore.read(uid), RestoreState.done);
      remote.put(uid, 'goals', 'g', goalDoc('g'));
      await engine.pull(uid);
      expect(await local(db.goals), 1);
    });

    test('AC1 edge the summary counts live workouts only', () async {
      remote
        ..put(uid, 'sessions', 'a', sessionDoc('a', DateTime.utc(2026, 11)))
        ..put(uid, 'sessions', 'b', {
          ...sessionDoc('b', DateTime.utc(2026, 11, 2)),
          'deletedAt': 5,
        });
      final s = await remote.summary(uid, allCollections);
      expect(s!.workouts, 1);
    });
  });

  group('SYN-02 restore', () {
    setUp(() {
      remote
        ..put(uid, 'goals', 'g', goalDoc('g'))
        ..put(uid, 'sessions', 's1', sessionDoc('s1', DateTime.utc(2026, 11)))
        ..put(
          uid,
          'sessions',
          's2',
          sessionDoc('s2', DateTime.utc(2026, 11, 3)),
        )
        ..put(uid, 'scheduleDays', 'd1', dayDoc('d1', DateTime.utc(2026, 11)));
    });

    test('AC2 AC3 essentials first; history after, counted', () async {
      await engine.pull(uid);
      await engine.beginRestore(uid);
      expect(await local(db.goals), 1);
      expect(await local(db.workoutSessions), 0);
      expect(await restore.watchProgress(uid).first, (done: 0, total: 3));

      await engine.pull(uid);
      expect(await local(db.workoutSessions), 2);
      expect(await local(db.sessionSets), 6);
      expect(await local(db.scheduleDays), 1);
      expect(await restore.read(uid), RestoreState.done);
      expect(await restore.watchProgress(uid).first, isNull);
    });

    test(
      'AC6 Start fresh: the backup stays put; only new changes come',
      () async {
        await engine.pull(uid);
        await engine.startFresh(uid);
        await engine.pull(uid);
        expect(await local(db.goals), 0);
        expect(await local(db.workoutSessions), 0);
        expect(remote.all(uid, 'goals'), hasLength(1));
        remote.put(uid, 'goals', 'new', goalDoc('new', updatedAt: 2000));
        await engine.pull(uid);
        expect(
          [for (final g in await db.select(db.goals).get()) g.id],
          ['new'],
        );
      },
    );

    test('AC7 phone data and backup are both kept', () async {
      final goals = DriftGoalRepository(db, now: () => t0);
      await goals.save(
        Goal(
          id: 'mine',
          type: GoalType.bodyWeight,
          startValue: 80,
          target: 75,
          createdAt: t0,
        ),
      );
      await engine.pull(uid);
      await engine.beginRestore(uid);
      await engine.pull(uid);
      await engine.push(uid, withBody: true);
      expect(
        {for (final g in await db.select(db.goals).get()) g.id},
        {'mine', 'g'},
      );
      expect(remote.all(uid, 'goals').keys.toSet(), {'mine', 'g'});
    });
  });

  group('SYN-02 paging', () {
    test('AC8 a full batch at one server time pages without looping', () async {
      remote.putBatch(uid, 'sessions', {
        for (var i = 0; i < 450; i++)
          's$i': sessionDoc('s$i', DateTime.utc(2025).add(Duration(days: i))),
      });
      await restore.write(uid, RestoreState.done);
      await engine.pull(uid);
      expect(await local(db.workoutSessions), 450);
      expect(
        [
          for (final p in remote.pages)
            if (p.$1 == 'sessions') p.$2,
        ],
        [200, 200, 50],
      );
    });

    test('AC8 a stopped restore carries on, without duplicates', () async {
      remote.putBatch(uid, 'sessions', {
        for (var i = 0; i < 450; i++)
          's$i': sessionDoc('s$i', DateTime.utc(2025).add(Duration(days: i))),
      });
      await engine.pull(uid);
      await engine.beginRestore(uid);
      final served = remote.pages.length;
      // 5 essentials + schedule days, then one page of sessions before the stop.
      remote.failAfterPages = served + 7;
      await expectLater(engine.pull(uid), throwsA(isA<SyncFailure>()));
      expect(await restore.read(uid), RestoreState.restoring);
      final partway = await local(db.workoutSessions);
      expect(partway, greaterThan(0));
      expect(partway, lessThan(450));

      remote.failAfterPages = null;
      await engine.pull(uid);
      expect(await local(db.workoutSessions), 450);
      expect(await local(db.sessionSets), 450 * 3);
      expect(await restore.read(uid), RestoreState.done);
    });
  });

  group('SYN-02 two years', () {
    test('AC4 AC9 restores fast; stats rebuild from it', () async {
      // ≈ 2 years: 1,100 workouts of 5 sets, 730 days, in batches.
      final start = DateTime.utc(2024, 11, 24);
      for (var b = 0; b < 1100; b += 500) {
        remote.putBatch(uid, 'sessions', {
          for (var i = b; i < b + 500 && i < 1100; i++)
            's$i': sessionDoc(
              's$i',
              start.add(Duration(hours: i * 15)),
              sets: 5,
            ),
        });
      }
      remote.putBatch(uid, 'scheduleDays', {
        for (var i = 0; i < 730; i++)
          'd$i': {...dayDoc('d$i', start.add(Duration(days: i)))},
      });
      remote.putBatch(uid, 'bodySnapshots', {
        for (var i = 0; i < 100; i++)
          'b$i': {
            'id': 'b$i',
            'date': start.add(Duration(days: i * 7)).millisecondsSinceEpoch,
            'weightKg': 80.0 - i / 20,
            'waistCm': null,
            'neckCm': null,
            'hipCm': null,
            'scaleBodyFatPct': null,
            'activity': null,
            'results': null,
            'updatedAt': start.millisecondsSinceEpoch,
            'deletedAt': null,
          },
      });
      final watch = Stopwatch()..start();
      await engine.pull(uid);
      await engine.beginRestore(uid);
      await engine.pull(uid);
      watch.stop();
      expect(await local(db.workoutSessions), 1100);
      expect(await local(db.sessionSets), 5500);
      expect(await local(db.scheduleDays), 730);
      expect(await local(db.bodySnapshots), 100);
      // AC9: PR flags come back with their sets.
      final prs = await (db.select(
        db.sessionSets,
      )..where((s) => s.isPr.equals(true))).get();
      expect(prs, hasLength(1100));
      // The phone's share of the 30 s budget (the rest is the network).
      expect(watch.elapsed, lessThan(const Duration(seconds: 15)));

      // AC9: the logger's history reads the restored workouts as its own.
      final sessions = DriftSessionRepository(db, DriftDayRecordRepository(db));
      expect(await sessions.exerciseSetCounts(), {'Bench_Press': 5500});
      final log = await sessions.exerciseLog('Bench_Press', limit: null);
      expect(log, hasLength(1100));
    });
  });

  test('SYN-02 AC7 the phone\'s data uploads while the choice waits', () async {
    remote.put(uid, 'goals', 'g', goalDoc('g'));
    final goals = DriftGoalRepository(db, now: () => t0);
    await goals.save(
      Goal(
        id: 'mine',
        type: GoalType.bodyWeight,
        startValue: 80,
        target: 75,
        createdAt: t0,
      ),
    );
    await engine.pull(uid);
    expect(await restore.read(uid), RestoreState.offered);
    await engine.push(uid, withBody: true);
    expect(remote.doc(uid, 'goals', 'mine'), isNotNull);
  });

  group('SYN-02 review fixes', () {
    test('AC6 AC10 Start fresh works offline, from the saved offer', () async {
      remote.put(uid, 'goals', 'g', goalDoc('g'));
      await engine.pull(uid);
      remote.failWith = const SyncFailure(SyncErrorKind.offline);
      await engine.startFresh(uid);
      expect(await restore.read(uid), RestoreState.fresh);
      expect(await restore.readSummary(uid), isNotNull);
      remote.failWith = null;
      remote.put(uid, 'goals', 'new', goalDoc('new', updatedAt: 2000));
      await engine.pull(uid);
      expect([for (final g in await db.select(db.goals).get()) g.id], ['new']);
    });

    test('a failed Restore stays offered, so the card stays', () async {
      remote.put(uid, 'goals', 'g', goalDoc('g'));
      await engine.pull(uid);
      remote.failWith = const SyncFailure(SyncErrorKind.offline);
      await expectLater(engine.beginRestore(uid), throwsA(isA<SyncFailure>()));
      expect(await restore.read(uid), RestoreState.offered);
      remote.failWith = null;
      await engine.beginRestore(uid);
      expect(await restore.read(uid), RestoreState.restoring);
    });

    test('edge nothing is pushed before the offer is decided', () async {
      final goals = DriftGoalRepository(db, now: () => t0);
      await goals.save(
        Goal(
          id: 'mine',
          type: GoalType.bodyWeight,
          startValue: 80,
          target: 75,
          createdAt: t0,
        ),
      );
      await engine.push(uid, withBody: true);
      expect(remote.all(uid, 'goals'), isEmpty);
      // Decided (no backup): the guest's data goes, and isn't "a backup".
      await engine.pull(uid);
      expect(await restore.read(uid), RestoreState.done);
      await engine.push(uid, withBody: true);
      expect(remote.all(uid, 'goals').keys, ['mine']);
    });

    test('edge already syncing before restore existed: carries on', () async {
      remote.put(uid, 'goals', 'g', goalDoc('g'));
      // An early SYN-01 cursor: milliseconds, no id.
      await db.writeMeta('sync.pulledAt.$uid.goals', '1');
      await engine.pull(uid);
      expect(await restore.read(uid), RestoreState.done);
      expect(await local(db.goals), 1);
    });

    test('edge signed out mid-restore: nothing of it stays', () async {
      remote.putBatch(uid, 'sessions', {
        for (var i = 0; i < 450; i++)
          's$i': sessionDoc('s$i', DateTime.utc(2025).add(Duration(days: i))),
      });
      await engine.pull(uid);
      await engine.beginRestore(uid);
      var pagesLeft = 1;
      bool current() => pagesLeft-- > 0;
      await engine.pull(uid, current: current);
      // Signed out: the wipe, then no more writes from that run.
      await LocalDataWiper(db).wipeUserData();
      await engine.pull(uid, current: () => false);
      expect(await local(db.workoutSessions), 0);
      final keys = [
        for (final m in await db.select(db.appMeta).get())
          if (m.key.startsWith('sync.') || m.key.startsWith('restore.')) m.key,
      ];
      expect(keys, isEmpty);
    });

    test('AC3 progress counts deleted records too, and ends', () async {
      remote
        ..put(uid, 'sessions', 's1', sessionDoc('s1', DateTime.utc(2026, 11)))
        ..put(uid, 'sessions', 's2', {
          ...sessionDoc('s2', DateTime.utc(2026, 11, 2)),
          'deletedAt': 5,
        });
      await engine.pull(uid);
      await engine.beginRestore(uid);
      expect(await restore.watchProgress(uid).first, (done: 0, total: 2));
      await engine.pullOnly(uid, historyCollections, counting: true);
      expect(await restore.watchProgress(uid).first, (done: 2, total: 2));
    });
  });
}
