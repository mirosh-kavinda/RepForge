import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/data/local/app_database.dart';
import 'package:repforge/data/local/local_data_wiper.dart';
import 'package:repforge/data/sync/sync_state.dart';
import 'package:repforge/features/logger/data/drift_session_repository.dart';
import 'package:repforge/features/logger/domain/session_repository.dart';
import 'package:repforge/features/logger/domain/workout_session.dart';
import 'package:repforge/features/schedule/data/drift_day_record_repository.dart';
import 'package:repforge/features/schedule/domain/day_record.dart';

final mon = DateTime.utc(2026, 11, 23);

WorkoutSession draft(String id, {DateTime? date}) => WorkoutSession(
  id: id,
  name: 'Push',
  templateId: 'push',
  exercises: const [
    SessionExercise(id: 'r1', exerciseId: 'bench', name: 'Bench Press'),
    SessionExercise(id: 'r2', exerciseId: 'dips', name: 'Dips'),
  ],
  date: date ?? mon,
  startedAt: DateTime.utc(2026, 11, 23, 9),
  cycleId: 'c1',
  dayId: 'd1',
  dayIndex: 0,
);

LoggedSet set(String id, int n, double kg, {String row = 'r1', int reps = 8}) =>
    LoggedSet(
      id: id,
      rowId: row,
      exerciseId: row == 'r1' ? 'bench' : 'dips',
      setNo: n,
      kg: kg,
      reps: reps,
    );

void main() {
  late AppDatabase db;
  late DriftSessionRepository repo;
  late DriftDayRecordRepository days;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    days = DriftDayRecordRepository(db);
    repo = DriftSessionRepository(
      db,
      days,
      now: () => DateTime.utc(2026, 11, 23, 10),
    );
  });
  tearDown(() => db.close());

  Future<List<(String, OutboxOp)>> outbox() async => [
    for (final r in await db.select(db.outbox).get()) (r.entity, r.op),
  ];

  group('LOG-01 session repository', () {
    test(
      'AC1 AC8 start keeps a copy; the in-progress one is watched',
      () async {
        expect(await repo.watchActive().first, isNull);
        final id = await repo.start(draft('s1'));
        final active = await repo.watchActive().first;
        expect((id, active?.name, active?.exercises.length), ('s1', 'Push', 2));
        expect(await outbox(), isEmpty, reason: 'nothing synced while running');
      },
    );

    test('edge starting again resumes the one in progress', () async {
      await repo.start(draft('s1'));
      expect(await repo.start(draft('s2')), 's1');
      expect(await db.select(db.workoutSessions).get(), hasLength(1));
    });

    test('AC3 AC5 log, change and delete sets; never queued', () async {
      await repo.start(draft('s1'));
      await repo.logSet('s1', set('a', 1, 60));
      await repo.logSet('s1', set('b', 2, 62.5));
      await repo.updateSet('b', kg: 65, reps: 6);
      await repo.deleteSet('a');
      final s = (await repo.watchActive().first)!;
      expect(s.sets.map((x) => (x.id, x.kg, x.reps)), [('b', 65.0, 6)]);
      expect(await outbox(), isEmpty);
    });

    test('AC6 AC7 the workout copy can change', () async {
      await repo.start(draft('s1'));
      await repo.setExercises('s1', const [
        SessionExercise(id: 'r1', exerciseId: 'bench', name: 'Bench Press'),
      ]);
      expect((await repo.watchActive().first)!.exercises, hasLength(1));
    });

    test('NFR-01 a set write takes under 50 ms', () async {
      await repo.start(draft('s1'));
      await repo.logSet('s1', set('warm', 1, 20));
      final sw = Stopwatch()..start();
      await repo.logSet('s1', set('a', 2, 60));
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(50));
    });

    test('AC9 NFR-10 finish: one session row queued (plus the SCH-02 day '
        'record), today done, nothing active', () async {
      await repo.start(draft('s1'));
      await repo.logSet('s1', set('a', 1, 60));
      await repo.logSet('s1', set('b', 2, 60));
      await repo.finish('s1');
      expect(await outbox(), [
        ('session', OutboxOp.create),
        ('scheduleDay', OutboxOp.create),
      ]);
      expect(await repo.watchActive().first, isNull);
      final row = await db.select(db.workoutSessions).getSingle();
      expect(row.endedAt, DateTime.utc(2026, 11, 23, 10));
      final day = (await days.watchSince('c1', mon).first).single;
      expect((day.date, day.dayId, day.status), (mon, 'd1', DayStatus.done));
    });

    test('AC9 finish with no sets writes nothing', () async {
      await repo.start(draft('s1'));
      await expectLater(repo.finish('s1'), throwsA(isA<NoSetsLogged>()));
      expect(await outbox(), isEmpty);
      expect(await repo.watchActive().first, isNotNull);
    });

    test('edge finish marks the date it was started for', () async {
      final sun = DateTime.utc(2026, 11, 22);
      await repo.start(draft('s1', date: sun));
      await repo.logSet('s1', set('a', 1, 60));
      await repo.finish('s1');
      expect((await days.watchSince('c1', sun).first).single.date, sun);
    });

    test(
      'edge a date settled missed past midnight is still marked done',
      () async {
        final sun = DateTime.utc(2026, 11, 22);
        await repo.start(draft('s1', date: sun));
        await repo.logSet('s1', set('a', 1, 60));
        await days.writeSettled([
          DayRecord(
            id: 'm',
            cycleId: 'c1',
            date: sun,
            dayId: 'd1',
            dayIndex: 0,
            status: DayStatus.missed,
          ),
        ]);
        await repo.finish('s1');
        expect(
          (await days.watchSince('c1', sun).first).single.status,
          DayStatus.done,
        );
      },
    );

    test('edge finish keeps a swapped workout on the day', () async {
      await days.plan(
        cycleId: 'c1',
        date: mon,
        dayId: 'd1',
        dayIndex: 0,
        workoutId: 'pull',
      );
      await repo.start(draft('s1'));
      await repo.logSet('s1', set('a', 1, 60));
      await repo.finish('s1');
      final day = (await days.watchSince('c1', mon).first).single;
      expect((day.status, day.workoutId), (DayStatus.done, 'pull'));
    });

    test('AC8 discard removes the workout and its sets', () async {
      await repo.start(draft('s1'));
      await repo.logSet('s1', set('a', 1, 60));
      await repo.discard('s1');
      expect(await repo.watchActive().first, isNull);
      expect(await db.select(db.sessionSets).get(), isEmpty);
      expect(await outbox(), isEmpty);
    });

    test(
      'AC2 last time: the latest finished session with the exercise',
      () async {
        await repo.start(draft('old'));
        await repo.logSet('old', set('o1', 1, 50));
        await repo.finish('old');
        await repo.start(draft('new', date: DateTime.utc(2026, 11, 24)));
        await repo.logSet('new', set('n1', 1, 55));
        await repo.logSet('new', set('n2', 2, 57.5));
        await repo.finish('new');
        await repo.start(draft('now', date: DateTime.utc(2026, 11, 25)));
        await repo.logSet('now', set('x', 1, 99));
        final last = await repo.lastSets('bench');
        expect(
          {for (final e in last.entries) e.key: e.value.kg},
          {1: 55.0, 2: 57.5},
        );
        expect(await repo.lastSets('squat'), isEmpty);
      },
    );

    test('sign-out wipes sessions and sets', () async {
      await repo.start(draft('s1'));
      await repo.logSet('s1', set('a', 1, 60));
      await LocalDataWiper(db).wipeUserData();
      expect(await db.select(db.workoutSessions).get(), isEmpty);
      expect(await db.select(db.sessionSets).get(), isEmpty);
    });

    test(
      'LOG-02 AC6 history is every finished set; Finish stores PRs',
      () async {
        await repo.start(draft('old'));
        await repo.logSet('old', set('o1', 1, 100, reps: 5));
        await repo.finish('old');
        expect((await repo.history('bench')).map((x) => x.kg), [100.0]);
        expect(
          (await db.select(db.sessionSets).getSingle()).isPr,
          isFalse,
          reason: 'first time: nothing to beat',
        );

        await repo.start(draft('new', date: DateTime.utc(2026, 11, 24)));
        await repo.logSet('new', set('n1', 1, 105, reps: 5));
        await repo.logSet('new', set('n2', 2, 95, reps: 5));
        expect(
          await repo.history('bench'),
          hasLength(1),
          reason: 'not running',
        );
        await repo.finish('new');
        final rows = await (db.select(
          db.sessionSets,
        )..where((r) => r.sessionId.equals('new'))).get();
        expect({for (final r in rows) r.id: r.isPr}, {'n1': true, 'n2': false});
      },
    );
  });
}
