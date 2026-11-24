import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/data/local/app_database.dart';
import 'package:repforge/data/sync/providers.dart';
import 'package:repforge/data/sync/restore.dart';
import 'package:repforge/data/sync/sync_engine.dart';
import 'package:repforge/data/sync/sync_scheduler.dart';
import 'package:repforge/features/auth/data/providers.dart';
import 'package:repforge/features/auth/domain/auth_user.dart';
import 'package:repforge/features/onboarding/data/drift_onboarding_repository.dart';
import 'package:repforge/features/onboarding/data/providers.dart';

import 'fake_remote_store.dart';
import 'fake_sync_runner.dart';

const uid = 'u1';

Map<String, Object?> profileDoc() => {
  'id': 'p',
  'goal': 'strength',
  'level': null,
  'units': 'imperial',
  'sex': null,
  'birthYear': null,
  'heightCm': null,
  'activityLevel': null,
  'defaultRestSec': 90,
  'barKgMetric': null,
  'barKgImperial': null,
  'platesMetric': null,
  'platesImperial': null,
  'updatedAt': 1000,
  'deletedAt': null,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late FakeRemoteStore remote;
  late SyncEngine engine;
  late ProviderContainer container;
  late SyncScheduler scheduler;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    remote = FakeRemoteStore();
    engine = SyncEngine(db, remote);
    scheduler = SyncScheduler(
      engine: FakeRunner(),
      users: const Stream.empty(),
      waiting: const Stream.empty(),
      online: const Stream.empty(),
      resumes: const Stream.empty(),
      bodyBackup: () async => true,
    );
    container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith(
          (ref) => Stream.value(
            const AuthUser(
              uid: uid,
              kind: AuthKind.account,
              providers: {SignInProvider.google},
            ),
          ),
        ),
        syncEngineProvider.overrideWithValue(engine),
        syncSchedulerProvider.overrideWithValue(scheduler),
        onboardingRepositoryProvider.overrideWithValue(
          DriftOnboardingRepository(db),
        ),
      ],
    );
    container.listen(currentUserProvider, (_, _) {});
  });
  tearDown(() async {
    scheduler.dispose();
    container.dispose();
    await db.close();
  });

  Future<bool> onboarded() => DriftOnboardingRepository(db).watchDone().first;

  group('SYN-02 restore controller', () {
    test('AC2 AC5 a backup with a profile replaces onboarding', () async {
      remote.put(uid, 'profile', 'p', profileDoc());
      await engine.pull(uid);
      await pumpEventQueue();
      final skipped = await container.read(restoreControllerProvider).restore();
      expect(skipped, isTrue);
      expect(await onboarded(), isTrue);
      expect(await RestoreStore(db).read(uid), RestoreState.restoring);
      final p = await db.select(db.userProfiles).getSingle();
      expect((p.units, p.defaultRestSec), ('imperial', 90));
    });

    test('AC5 without a profile, onboarding still runs', () async {
      remote.put(uid, 'goals', 'g', {
        'id': 'g',
        'type': 'strength',
        'exerciseId': 'Bench_Press',
        'startValue': 90.0,
        'targetValue': 100.0,
        'deadline': null,
        'pinned': false,
        'createdAt': 1,
        'achievedAt': null,
        'updatedAt': 1000,
        'deletedAt': null,
      });
      await engine.pull(uid);
      await pumpEventQueue();
      final skipped = await container.read(restoreControllerProvider).restore();
      expect(skipped, isFalse);
      expect(await onboarded(), isFalse);
    });

    test('AC6 Start fresh through the controller', () async {
      remote.put(uid, 'profile', 'p', profileDoc());
      await engine.pull(uid);
      await pumpEventQueue();
      await container.read(restoreControllerProvider).startFresh();
      expect(await RestoreStore(db).read(uid), RestoreState.fresh);
      expect(await db.select(db.userProfiles).get(), isEmpty);
    });
  });
}
