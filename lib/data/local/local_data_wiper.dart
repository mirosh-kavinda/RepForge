import 'app_database.dart';

// Removes everything the user owns from this phone. Tables are wiped unless
// listed here, so a new user table is covered without touching this file.
class LocalDataWiper {
  LocalDataWiper(this._db);

  final AppDatabase _db;

  static const keptTables = {
    'catalog_exercises',
    'exercise_muscles',
    'app_meta',
  };
  static const keptMetaKeys = {catalogVersionKey};

  Future<void> wipeUserData() => _db.transaction(() async {
    for (final table in _db.allTables) {
      if (!keptTables.contains(table.actualTableName)) {
        await _db.delete(table).go();
      }
    }
    await (_db.delete(
      _db.appMeta,
    )..where((m) => m.key.isNotIn(keptMetaKeys))).go();
  });
}
