import 'package:drift/drift.dart';

import '../../../core/ids.dart';
import '../../../core/metrics/units.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/base_columns.dart';
import '../../../data/sync/sync_state.dart';
import '../../../data/sync/synced_writer.dart';
import '../domain/onboarding_answers.dart';
import '../domain/onboarding_repository.dart';

class DriftOnboardingRepository implements OnboardingRepository {
  DriftOnboardingRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  static const doneKey = 'onboarding.done';

  final AppDatabase _db;
  final DateTime Function() _now;

  @override
  Stream<bool> watchDone() =>
      _db.watchMeta(doneKey).map((v) => v == 'true').distinct();

  @override
  Stream<UnitSystem> watchUnits() =>
      (_db.selectActive(_db.userProfiles)
            ..orderBy([(p) => OrderingTerm.desc(p.updatedAt)])
            ..limit(1))
          .watchSingleOrNull()
          .map(
            (p) => p == null
                ? UnitSystem.metric
                : UnitSystem.values.byName(p.units),
          )
          .distinct();

  @override
  Future<bool> skipIfProfile() => _db.transaction(() async {
    final p = await (_db.selectActive(
      _db.userProfiles,
    )..limit(1)).getSingleOrNull();
    if (p == null) return false;
    await _db.writeMeta(doneKey, 'true');
    return true;
  });

  @override
  Future<void> complete(
    OnboardingAnswers a, {
    Future<void> Function()? alsoWrite,
  }) => _db.transaction(() async {
    final writer = SyncedWriter(_db, now: _now);
    final profileId = newId();
    await writer.run(
      table: 'user_profiles',
      entity: 'userProfile',
      id: profileId,
      op: OutboxOp.create,
      write: (now) => _db
          .into(_db.userProfiles)
          .insert(
            UserProfilesCompanion.insert(
              id: Value(profileId),
              goal: Value(a.goal?.name),
              level: Value(a.level?.name),
              units: a.units.name,
              sex: Value(a.sex?.name),
              birthYear: Value(a.birthYear),
              heightCm: Value(a.heightCm),
              activityLevel: Value(a.activity?.name),
              updatedAt: now,
            ),
          ),
    );
    if (a.weightKg != null || a.waistCm != null) {
      final snapshotId = newId();
      final local = _now();
      await writer.run(
        table: 'body_snapshots',
        entity: 'bodySnapshot',
        id: snapshotId,
        op: OutboxOp.create,
        write: (now) => _db
            .into(_db.bodySnapshots)
            .insert(
              BodySnapshotsCompanion.insert(
                id: Value(snapshotId),
                // The phone's calendar day, stored as UTC midnight.
                date: DateTime.utc(local.year, local.month, local.day),
                weightKg: Value(a.weightKg),
                waistCm: Value(a.waistCm),
                updatedAt: now,
              ),
            ),
      );
    }
    await alsoWrite?.call();
    // Last, so a failure above leaves onboarding not done (edge case).
    await _db.writeMeta(doneKey, 'true');
  });
}
