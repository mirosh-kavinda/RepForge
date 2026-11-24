import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/data/providers.dart';
import '../local/database_provider.dart';
import '../remote/firestore_remote_store.dart';
import 'remote_store.dart';
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
