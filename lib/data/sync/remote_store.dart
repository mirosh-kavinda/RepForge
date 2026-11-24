// SYN-01: the cloud copy, as seen by the sync engine. Documents live at
// users/{uid}/{collection}/{id}; values are JSON (dates as epoch ms).

typedef RemoteWrite = ({
  String collection,
  String id,
  Map<String, Object?> data,
});

// [data] carries `syncedAt`: the server's time of the write, in epoch
// microseconds (Firestore's precision).
typedef RemoteDoc = ({String id, Map<String, Object?> data});

// Where a pull got to: the last document's server time and id. One batch
// stamps up to 500 documents with the same time, so the id breaks ties
// (SYN-02 AC8).
typedef PullCursor = ({int at, String id});

// What a backup holds, for the restore card (SYN-02 AC1).
typedef BackupSummary = ({DateTime newest, int workouts});

// Firestore's limit for one atomic batch (NFR-10).
const maxBatch = 500;

// Documents per pull page (SYN-02).
const pageSize = 200;

// Set by the server on every write; the pull cursor (AC2, AC4). Device time
// can't be the cursor: a phone back after 30 days writes old updatedAt values.
const syncedAtField = 'syncedAt';

abstract interface class RemoteStore {
  // Writes all of [writes] (≤ [maxBatch]) or none, stamping [syncedAtField].
  Future<void> commit(String uid, List<RemoteWrite> writes);

  // Up to [limit] docs of [collection] after [after] (all when null), in
  // (syncedAt, id) order.
  Future<List<RemoteDoc>> changedSince(
    String uid,
    String collection,
    PullCursor? after, {
    int limit = pageSize,
  });

  // The newest document's cursor; null for an empty collection (SYN-02
  // Start fresh: pulls begin after it).
  Future<PullCursor?> last(String uid, String collection);

  // Docs in [collection]; only live (not deleted) ones when [liveOnly].
  Future<int> count(String uid, String collection, {bool liveOnly = true});

  // The newest write in [collections] and the live workout count; null when
  // the account has no backup at all.
  Future<BackupSummary?> summary(String uid, Iterable<String> collections);
}

// Why a sync attempt failed. The first three are shown in words (AC10);
// [rejected] is one document the server refused (rules), set aside.
enum SyncErrorKind { offline, signedOut, server, rejected }

class SyncFailure implements Exception {
  const SyncFailure(this.kind);

  final SyncErrorKind kind;

  @override
  String toString() => 'SyncFailure(${kind.name})';
}
