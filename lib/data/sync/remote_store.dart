// SYN-01: the cloud copy, as seen by the sync engine. Documents live at
// users/{uid}/{collection}/{id}; values are JSON (dates as epoch ms).

typedef RemoteWrite = ({
  String collection,
  String id,
  Map<String, Object?> data,
});

// [data] carries `syncedAt`: the server's time of the write, in epoch ms.
typedef RemoteDoc = ({String id, Map<String, Object?> data});

// Firestore's limit for one atomic batch (NFR-10).
const maxBatch = 500;

// Set by the server on every write; the pull cursor (AC2, AC4). Device time
// can't be the cursor: a phone back after 30 days writes old updatedAt values.
const syncedAtField = 'syncedAt';

abstract interface class RemoteStore {
  // Writes all of [writes] (≤ [maxBatch]) or none, stamping [syncedAtField].
  Future<void> commit(String uid, List<RemoteWrite> writes);

  // Docs of [collection] written to the server at or after [sinceMs] (server
  // time), oldest first.
  Future<List<RemoteDoc>> changedSince(
    String uid,
    String collection,
    int sinceMs,
  );
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
