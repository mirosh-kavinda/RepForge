import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/data/local/app_database.dart';
import 'package:repforge/data/sync/sync_codecs.dart';

final t0 = DateTime.utc(2026, 11, 20, 9);

// One row of every synced table.
Future<void> seed(AppDatabase db) async {
  await db
      .into(db.userProfiles)
      .insert(
        UserProfilesCompanion.insert(
          id: const Value('p'),
          units: 'metric',
          sex: const Value('female'),
          birthYear: const Value(1990),
          heightCm: const Value(168),
          activityLevel: const Value('moderate'),
          goal: const Value('strength'),
          updatedAt: t0,
        ),
      );
  await db
      .into(db.bodySnapshots)
      .insert(
        BodySnapshotsCompanion.insert(
          id: const Value('b'),
          date: DateTime.utc(2026, 11, 20),
          weightKg: const Value(62.5),
          updatedAt: t0,
        ),
      );
  await db
      .into(db.workoutTemplates)
      .insert(
        WorkoutTemplatesCompanion.insert(
          id: const Value('w'),
          name: 'Push',
          exercises: '[]',
          updatedAt: t0,
        ),
      );
  await db
      .into(db.cycles)
      .insert(
        CyclesCompanion.insert(
          id: const Value('c'),
          name: 'PPL',
          days: '[{"id":"a","workoutId":"w"}]',
          isActive: true,
          startDate: DateTime.utc(2026, 11),
          startDayIndex: 0,
          updatedAt: t0,
        ),
      );
  await db
      .into(db.scheduleDays)
      .insert(
        ScheduleDaysCompanion.insert(
          id: const Value('d'),
          cycleId: 'c',
          date: DateTime.utc(2026, 11, 19),
          dayId: 'a',
          dayIndex: 0,
          status: 'done',
          updatedAt: t0,
        ),
      );
  await db
      .into(db.workoutSessions)
      .insert(
        WorkoutSessionsCompanion.insert(
          id: const Value('s'),
          name: 'Push',
          exercises: '[]',
          date: DateTime.utc(2026, 11, 19),
          startedAt: t0,
          endedAt: Value(t0.add(const Duration(hours: 1))),
          note: const Value('good'),
          updatedAt: t0,
        ),
      );
  for (var i = 1; i <= 2; i++) {
    await db
        .into(db.sessionSets)
        .insert(
          SessionSetsCompanion.insert(
            id: 's-$i',
            sessionId: 's',
            rowId: 'r',
            exerciseId: 'Bench_Press',
            setNo: i,
            kg: 60,
            reps: const Value(8),
            loggedAt: t0.add(Duration(minutes: i)),
            updatedAt: t0,
          ),
        );
  }
  await db
      .into(db.customExercises)
      .insert(
        CustomExercisesCompanion.insert(
          id: const Value('x'),
          name: 'Landmine press',
          equipment: 'barbell',
          primaryMuscles: '["shoulders"]',
          secondaryMuscles: '[]',
          updatedAt: t0,
        ),
      );
  await db
      .into(db.goals)
      .insert(
        GoalsCompanion.insert(
          id: const Value('g'),
          type: 'bodyWeight',
          startValue: 64,
          targetValue: 60,
          createdAt: t0,
          updatedAt: t0,
        ),
      );
}

const ids = {
  'userProfile': 'p',
  'bodySnapshot': 'b',
  'workoutTemplate': 'w',
  'cycle': 'c',
  'scheduleDay': 'd',
  'session': 's',
  'customExercise': 'x',
  'goal': 'g',
};

void main() {
  late AppDatabase a;
  late AppDatabase b;

  setUp(() {
    a = AppDatabase(NativeDatabase.memory());
    b = AppDatabase(NativeDatabase.memory());
  });
  tearDown(() async {
    await a.close();
    await b.close();
  });

  group('SYN-01 codecs', () {
    test('every synced table round-trips through a document', () async {
      await seed(a);
      final from = syncCodecs(a);
      final to = syncCodecs(b);
      expect(from.keys.toSet(), ids.keys.toSet());
      for (final MapEntry(key: entity, value: id) in ids.entries) {
        final doc = await from[entity]!.toRemote(a, id, withBody: true);
        expect(doc, isNotNull, reason: entity);
        expect(doc!.containsKey('syncState'), isFalse, reason: entity);
        await to[entity]!.apply(b, id, doc);
        final original = await from[entity]!.readLocal(a, id);
        final copy = await to[entity]!.readLocal(b, id);
        expect(
          {...copy!}..remove('syncState'),
          {...original!}..remove('syncState'),
          reason: entity,
        );
        expect(copy['syncState'], 'synced', reason: entity);
      }
    });

    test('AC3 a workout is one document with its sets', () async {
      await seed(a);
      final doc = await syncCodecs(
        a,
      )['session']!.toRemote(a, 's', withBody: true);
      expect(doc!['sets'], hasLength(2));
      expect(doc.containsKey('rest'), isFalse);
      await syncCodecs(b)['session']!.apply(b, 's', doc);
      expect(await b.select(b.sessionSets).get(), hasLength(2));
    });

    test('AC7 body fields stay home; pulling keeps the local ones', () async {
      await seed(a);
      final codec = syncCodecs(a)['userProfile']!;
      final doc = await codec.toRemote(a, 'p', withBody: false);
      for (final k in ['sex', 'birthYear', 'heightCm', 'activityLevel']) {
        expect(doc!.containsKey(k), isFalse, reason: k);
      }
      expect(doc!['goal'], 'strength');
      await codec.apply(a, 'p', {...doc, 'units': 'imperial'});
      final row = await codec.readLocal(a, 'p');
      expect(row!['units'], 'imperial');
      expect(row['heightCm'], 168);
    });

    test('a row that is gone has no document', () async {
      expect(
        await syncCodecs(a)['goal']!.toRemote(a, 'nope', withBody: true),
        isNull,
      );
    });
  });
}
