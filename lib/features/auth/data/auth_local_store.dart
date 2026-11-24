import 'package:drift/drift.dart';

import '../../../data/local/app_database.dart';
import '../domain/account_preferences.dart';

// Auth state that must be known offline and before Firebase starts (AC1, AC6, AC8).
class AuthLocalStore implements AccountPreferencesStore {
  AuthLocalStore(this._db);

  final AppDatabase _db;

  static const choiceKey = 'auth.choiceMade';
  static const localGuestKey = 'auth.localGuestId';
  static const pendingMergeKey = 'auth.pendingMergeFrom';

  Future<bool> choiceMade() async => await _db.readMeta(choiceKey) == 'true';

  Stream<bool> watchChoiceMade() =>
      _db.watchMeta(choiceKey).map((v) => v == 'true').distinct();

  Future<void> setChoiceMade() => _db.writeMeta(choiceKey, 'true');

  Future<void> clearChoice() => _db.deleteMeta(choiceKey);

  Future<String?> localGuestId() => _db.readMeta(localGuestKey);

  Future<void> setLocalGuestId(String id) => _db.writeMeta(localGuestKey, id);

  Future<void> clearLocalGuestId() => _db.deleteMeta(localGuestKey);

  Future<String?> pendingMergeFrom() => _db.readMeta(pendingMergeKey);

  Future<void> setPendingMergeFrom(String uid) =>
      _db.writeMeta(pendingMergeKey, uid);

  static const _prefKeys = (
    body: 'account.backUpBodyMetrics',
    photos: 'account.backUpPhotos',
    profile: 'account.useProviderProfile',
    settings: 'account.syncSettings',
    reminders: 'account.remindersEverywhere',
  );

  @override
  Future<AccountPreferences> load() async {
    Future<bool> read(String key) async => await _db.readMeta(key) != 'false';
    return AccountPreferences(
      backUpBodyMetrics: await read(_prefKeys.body),
      backUpPhotos: await read(_prefKeys.photos),
      useProviderProfile: await read(_prefKeys.profile),
      syncSettings: await read(_prefKeys.settings),
      remindersEverywhere: await read(_prefKeys.reminders),
    );
  }

  @override
  Stream<bool> watchUseProviderProfile() =>
      _db.watchMeta(_prefKeys.profile).map((v) => v != 'false').distinct();

  @override
  Future<void> save(AccountPreferences p) => _db.transaction(() async {
    // SYN-01 AC7: body backup turned on: queue the profile again, so it goes
    // up with its body fields (snapshots were left queued meanwhile). The
    // queue changing is what starts the backup.
    final wasOn = await _db.readMeta(_prefKeys.body) != 'false';
    if (!wasOn && p.backUpBodyMetrics) {
      for (final profile in await _db.select(_db.userProfiles).get()) {
        await _db.customInsert(
          'INSERT INTO outbox (entity, entity_id, op, created_at) '
          'VALUES (?, ?, ?, ?)',
          variables: [
            Variable.withString('userProfile'),
            Variable.withString(profile.id),
            Variable.withString('update'),
            Variable.withDateTime(DateTime.now().toUtc()),
          ],
          updates: {_db.outbox},
        );
      }
    }
    await _db.writeMeta(_prefKeys.body, '${p.backUpBodyMetrics}');
    await _db.writeMeta(_prefKeys.photos, '${p.backUpPhotos}');
    await _db.writeMeta(_prefKeys.profile, '${p.useProviderProfile}');
    await _db.writeMeta(_prefKeys.settings, '${p.syncSettings}');
    await _db.writeMeta(_prefKeys.reminders, '${p.remindersEverywhere}');
  });
}
