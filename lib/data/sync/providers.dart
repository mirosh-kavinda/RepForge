import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/data/providers.dart';
import '../../features/onboarding/data/providers.dart';
import '../local/database_provider.dart';
import '../remote/firestore_remote_store.dart';
import 'remote_store.dart';
import 'restore.dart';
import 'sync_engine.dart';
import 'sync_scheduler.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
RemoteStore remoteStore(Ref ref) => FirestoreRemoteStore(
  ref.watch(firebaseReadyProvider.future).then((ready) {
    if (!ready) return null;
    final db = FirebaseFirestore.instance
      ..settings = const Settings(persistenceEnabled: false);
    return db;
  }),
);

@Riverpod(keepAlive: true)
SyncEngine syncEngine(Ref ref) =>
    SyncEngine(ref.watch(appDatabaseProvider), ref.watch(remoteStoreProvider));

// SYN-01 AC9, AC10.
@riverpod
Stream<SyncStatus> syncStatus(Ref ref) =>
    ref.watch(syncEngineProvider).watchStatus();

// SYN-01: runs while the app does (started from main).
@Riverpod(keepAlive: true)
SyncScheduler syncScheduler(Ref ref) {
  final resumes = StreamController<void>.broadcast();
  final lifecycle = AppLifecycleListener(onResume: () => resumes.add(null));
  final engine = ref.watch(syncEngineProvider);
  final scheduler = SyncScheduler(
    engine: engine,
    users: ref
        .watch(authRepositoryProvider)
        .userChanges()
        .map((u) => u == null ? null : (uid: u.uid, canBackUp: u.canBackUp)),
    waiting: engine.watchWaiting(),
    online: Connectivity().onConnectivityChanged.map(
      (r) => !r.contains(ConnectivityResult.none),
    ),
    resumes: resumes.stream,
    bodyBackup: () async =>
        (await ref.read(accountPreferencesStoreProvider).load())
            .backUpBodyMetrics,
  );
  ref.onDispose(() {
    scheduler.dispose();
    lifecycle.dispose();
    resumes.close().ignore();
  });
  return scheduler;
}

void startSync(ProviderContainer container) =>
    container.read(syncSchedulerProvider);

// SYN-02: the signed-in account that may back up, else null.
String? _uid(Ref ref) {
  final u = ref.watch(currentUserProvider).value;
  return u != null && u.canBackUp ? u.uid : null;
}

@riverpod
Stream<RestoreState?> restoreState(Ref ref) {
  final uid = _uid(ref);
  if (uid == null) return Stream.value(null);
  return RestoreStore(ref.watch(appDatabaseProvider)).watch(uid);
}

// SYN-02 AC3.
@riverpod
Stream<RestoreProgress?> restoreProgress(Ref ref) {
  final uid = _uid(ref);
  if (uid == null) return Stream.value(null);
  return RestoreStore(ref.watch(appDatabaseProvider)).watchProgress(uid);
}

// SYN-02 AC1, AC10: what the card describes, saved when the backup was
// first seen (no network needed); only while the backup is offered.
@riverpod
Future<BackupSummary?> backupSummary(Ref ref) async {
  final uid = _uid(ref);
  if (uid == null) return null;
  if (await ref.watch(restoreStateProvider.future) != RestoreState.offered) {
    return null;
  }
  return RestoreStore(ref.watch(appDatabaseProvider)).readSummary(uid);
}

// SYN-02 AC10.
@riverpod
Stream<bool> online(Ref ref) async* {
  final c = Connectivity();
  bool on(List<ConnectivityResult> r) => !r.contains(ConnectivityResult.none);
  yield on(await c.checkConnectivity());
  yield* c.onConnectivityChanged.map(on);
}

// SYN-02: the card's two choices.
abstract interface class RestoreActions {
  // True when a restored profile replaced onboarding.
  Future<bool> restore();

  Future<void> startFresh();
}

class RestoreController implements RestoreActions {
  RestoreController(this._ref);

  final Ref _ref;

  String? get _account {
    final u = _ref.read(currentUserProvider).value;
    return u != null && u.canBackUp ? u.uid : null;
  }

  // AC2, AC5: the essentials now (Home works); history follows in the
  // background run.
  @override
  Future<bool> restore() async {
    final uid = _account;
    if (uid == null) return false;
    // Edge: signed out mid-restore: stop writing.
    bool current() => _account == uid;
    await _ref.read(syncEngineProvider).beginRestore(uid, current: current);
    if (!current()) return false;
    final skipped = await _ref
        .read(onboardingRepositoryProvider)
        .skipIfProfile();
    unawaited(_ref.read(syncSchedulerProvider).backUpNow());
    return skipped;
  }

  // AC6.
  @override
  Future<void> startFresh() async {
    final uid = _account;
    if (uid == null) return;
    await _ref.read(syncEngineProvider).startFresh(uid);
    unawaited(_ref.read(syncSchedulerProvider).backUpNow());
  }
}

@Riverpod(keepAlive: true)
RestoreActions restoreController(Ref ref) => RestoreController(ref);
