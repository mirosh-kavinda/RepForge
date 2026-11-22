import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/core/metrics/body.dart';
import 'package:repforge/core/metrics/units.dart';
import 'package:repforge/data/local/app_database.dart';
import 'package:repforge/data/local/local_data_wiper.dart';
import 'package:repforge/data/sync/sync_state.dart';
import 'package:repforge/features/onboarding/data/drift_onboarding_repository.dart';
import 'package:repforge/features/onboarding/domain/onboarding_answers.dart';
import 'package:repforge/features/schedule/data/drift_cycle_repository.dart';
import 'package:repforge/features/schedule/domain/cycle.dart';

void main() {
  late AppDatabase db;
  late DriftOnboardingRepository repo;
  final now = DateTime(2026, 11, 21, 23, 30);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftOnboardingRepository(db, now: () => now);
  });
  tearDown(() => db.close());

  const full = OnboardingAnswers(
    units: UnitSystem.imperial,
    goal: TrainingGoal.getStronger,
    level: TrainingLevel.intermediate,
    sex: Sex.female,
    birthYear: 1994,
    heightCm: 165.1,
    weightKg: 61.235,
  );

  group('ONB-01 finish onboarding', () {
    test(
      'AC6 saves profile (metric), first snapshot today and the flag',
      () async {
        await repo.complete(full);

        final profile = await db.select(db.userProfiles).getSingle();
        expect(profile.units, 'imperial');
        expect(profile.goal, 'getStronger');
        expect(profile.level, 'intermediate');
        expect(profile.sex, 'female');
        expect(profile.birthYear, 1994);
        expect(profile.heightCm, 165.1);
        expect(profile.syncState, SyncState.pending);

        final snapshot = await db.select(db.bodySnapshots).getSingle();
        expect(snapshot.weightKg, 61.235);
        expect(snapshot.date, DateTime.utc(2026, 11, 21));

        expect(await db.readMeta(DriftOnboardingRepository.doneKey), 'true');
      },
    );

    test('AC6 both records are queued for backup', () async {
      await repo.complete(full);
      final outbox = await db.select(db.outbox).get();
      expect(outbox.map((o) => o.entity), ['userProfile', 'bodySnapshot']);
      expect(outbox.every((o) => o.op == OutboxOp.create), isTrue);
    });

    test('AC6 no weight, no snapshot; unset answers stay null', () async {
      await repo.complete(const OnboardingAnswers(units: UnitSystem.metric));
      final profile = await db.select(db.userProfiles).getSingle();
      expect(profile.goal, isNull);
      expect(profile.sex, isNull);
      expect(profile.heightCm, isNull);
      expect(await db.select(db.bodySnapshots).get(), isEmpty);
      expect(await db.select(db.outbox).get(), hasLength(1));
    });

    test(
      'edge: a failure saves nothing and leaves onboarding not done',
      () async {
        await db.customStatement(
          'CREATE TRIGGER boom BEFORE INSERT ON body_snapshots '
          "BEGIN SELECT RAISE(ABORT, 'disk full'); END",
        );
        await expectLater(repo.complete(full), throwsA(anything));
        expect(await db.select(db.userProfiles).get(), isEmpty);
        expect(await db.select(db.outbox).get(), isEmpty);
        expect(await db.readMeta(DriftOnboardingRepository.doneKey), isNull);
      },
    );

    test('AC2 done is watchable and cleared by sign-out wipe', () async {
      final seen = <bool>[];
      final sub = repo.watchDone().listen(seen.add);
      await pumpEventQueue();
      await repo.complete(full);
      await pumpEventQueue();
      await LocalDataWiper(db).wipeUserData();
      await pumpEventQueue();
      await sub.cancel();
      expect(seen, [false, true, false]);
      expect(await db.select(db.userProfiles).get(), isEmpty);
      expect(await db.select(db.bodySnapshots).get(), isEmpty);
    });
  });

  group('WKT-01 watchUnits', () {
    test('metric until a profile exists, then the profile units', () async {
      expect(await repo.watchUnits().first, UnitSystem.metric);
      await repo.complete(full);
      expect(await repo.watchUnits().first, UnitSystem.imperial);
    });
  });

  group('SCH-01 starter cycle with onboarding', () {
    Cycle plan() => Cycle(
      id: 'c1',
      name: 'PPL + Rest',
      days: const [
        CycleDay(id: 'd1', workoutId: 'push'),
        CycleDay(id: 'd2'),
      ],
      isActive: true,
      startDate: DateTime.utc(2026, 11, 21),
      startDayIndex: 0,
    );

    test('AC10 the cycle commits with the profile and the flag', () async {
      final cycles = DriftCycleRepository(db);
      await repo.complete(full, alsoWrite: () => cycles.save(plan()));
      expect(await cycles.byId('c1'), plan());
      expect(await repo.watchDone().first, isTrue);
    });

    test(
      'ONB-01 edge a failure after the cycle write rolls back both',
      () async {
        final cycles = DriftCycleRepository(db);
        await expectLater(
          repo.complete(
            full,
            alsoWrite: () async {
              await cycles.save(plan());
              throw StateError('boom');
            },
          ),
          throwsA(isA<StateError>()),
        );
        expect(await cycles.byId('c1'), isNull);
        expect(await db.select(db.userProfiles).get(), isEmpty);
        expect(await db.select(db.outbox).get(), isEmpty);
        expect(await repo.watchDone().first, isFalse);
      },
    );
  });
}
