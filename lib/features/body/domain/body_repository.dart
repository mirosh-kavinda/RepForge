import 'body_snapshot.dart';

abstract interface class BodyRepository {
  // Height, sex, birth year and last activity level from the profile.
  Stream<BodyProfile> watchProfile();

  // Active snapshots, newest first (AC1, AC7).
  Stream<List<BodySnapshot>> watchAll();

  Future<BodySnapshot?> byId(String id);

  // AC3, AC6: today's snapshot, replacing one already saved today; saves the
  // activity level to the profile in the same transaction. Returns its id.
  Future<String> saveToday(BodyInput input, BodyResults results);

  Future<void> delete(String id);

  Future<void> restore(String id);
}
