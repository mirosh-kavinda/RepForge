import 'package:repforge/data/sync/remote_store.dart';
import 'package:repforge/data/sync/sync_engine.dart';

class FakeRunner implements SyncRunner {
  final calls = <String>[];
  SyncErrorKind? error;
  SyncFailure? failWith;
  StillFor? lastCurrent;
  var pushes = 0;

  @override
  Future<void> push(
    String uid, {
    required bool withBody,
    StillFor current = _always,
  }) async {
    lastCurrent = current;
    pushes++;
    if (failWith case final e?) throw e;
    calls.add('push:$uid:${withBody ? 'body' : 'nobody'}');
  }

  // Fails pulls only (AC4 edge: a bad pull doesn't block the backup).
  SyncFailure? failPullWith;

  @override
  Future<void> pull(String uid, {StillFor current = _always}) async {
    if (failPullWith case final e?) throw e;
    if (failWith case final e?) throw e;
    calls.add('pull:$uid');
  }

  @override
  Future<void> recordError(SyncErrorKind? kind) async => error = kind;
}

bool _always() => true;
