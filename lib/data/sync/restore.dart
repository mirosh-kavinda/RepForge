import 'package:drift/drift.dart';

import '../local/app_database.dart';

// SYN-02: what this phone does with an account's backup.
// offered: shown the card, nothing pulled yet; restoring: pulling it down;
// done: restored, or there was nothing to restore; fresh: Start fresh chosen.
enum RestoreState { offered, restoring, done, fresh }

typedef RestoreProgress = ({int done, int total});

// Small enough that Home works within seconds (AC2); history comes after.
const essentialCollections = [
  'profile',
  'cycles',
  'workoutTemplates',
  'goals',
  'customExercises',
];
const historyCollections = ['scheduleDays', 'sessions', 'bodySnapshots'];
const allCollections = [...essentialCollections, ...historyCollections];

// Per account, in app_meta (cleared with it on sign-out).
class RestoreStore {
  RestoreStore(this._db);

  final AppDatabase _db;

  static String _state(String uid) => 'restore.$uid';
  static String _done(String uid) => 'restore.done.$uid';
  static String _total(String uid) => 'restore.total.$uid';
  static String _summary(String uid) => 'restore.summary.$uid';
  static String _offerCursor(String uid, String collection) =>
      'restore.offerCursor.$uid.$collection';

  Future<RestoreState?> read(String uid) async =>
      RestoreState.values.asNameMap()[await _db.readMeta(_state(uid))];

  Stream<RestoreState?> watch(String uid) =>
      _db.watchMeta(_state(uid)).map((v) => RestoreState.values.asNameMap()[v]);

  Future<void> write(String uid, RestoreState s) =>
      _db.writeMeta(_state(uid), s.name);

  // AC1, AC6, AC10: what the card shows and where Start fresh begins,
  // saved when the backup is first seen, so neither needs the network later.
  Future<void> offer(
    String uid,
    ({DateTime newest, int workouts}) summary,
    Map<String, ({int at, String id})> lastCursors,
  ) => _db.transaction(() async {
    await _db.writeMeta(
      _summary(uid),
      '${summary.newest.microsecondsSinceEpoch}|${summary.workouts}',
    );
    for (final MapEntry(:key, :value) in lastCursors.entries) {
      await _db.writeMeta(_offerCursor(uid, key), '${value.at}|${value.id}');
    }
    await write(uid, RestoreState.offered);
  });

  Future<({DateTime newest, int workouts})?> readSummary(String uid) async {
    final v = await _db.readMeta(_summary(uid));
    final parts = v?.split('|');
    if (parts == null || parts.length != 2) return null;
    final at = int.tryParse(parts[0]);
    final n = int.tryParse(parts[1]);
    if (at == null || n == null) return null;
    return (
      newest: DateTime.fromMicrosecondsSinceEpoch(at, isUtc: true),
      workouts: n,
    );
  }

  Future<String?> offerCursor(String uid, String collection) =>
      _db.readMeta(_offerCursor(uid, collection));

  // Only once the essentials are on the phone (AC2); a failed Restore stays
  // offered, so the card and its error remain.
  Future<void> start(String uid, int total) => _db.transaction(() async {
    await write(uid, RestoreState.restoring);
    await _db.writeMeta(_total(uid), '$total');
    await _db.writeMeta(_done(uid), '0');
  });

  Future<void> addDone(String uid, int n) async {
    final now = int.tryParse(await _db.readMeta(_done(uid)) ?? '') ?? 0;
    await _db.writeMeta(_done(uid), '${now + n}');
  }

  // AC3: null unless a restore is running; updates with every page.
  Stream<RestoreProgress?> watchProgress(String uid) => _db
      .customSelect(
        'SELECT '
        '(SELECT value FROM app_meta WHERE key = ?) AS s, '
        '(SELECT value FROM app_meta WHERE key = ?) AS d, '
        '(SELECT value FROM app_meta WHERE key = ?) AS t',
        variables: [
          Variable.withString(_state(uid)),
          Variable.withString(_done(uid)),
          Variable.withString(_total(uid)),
        ],
        readsFrom: {_db.appMeta},
      )
      .watchSingle()
      .map((r) {
        if (r.readNullable<String>('s') != RestoreState.restoring.name) {
          return null;
        }
        int read(String key) =>
            int.tryParse(r.readNullable<String>(key) ?? '') ?? 0;
        final total = read('t');
        final done = read('d');
        return (done: done > total ? total : done, total: total);
      });
}
