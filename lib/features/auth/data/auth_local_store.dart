import '../../../data/local/app_database.dart';

// Auth state that must be known offline and before Firebase starts (AC1, AC6, AC8).
class AuthLocalStore {
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
}
