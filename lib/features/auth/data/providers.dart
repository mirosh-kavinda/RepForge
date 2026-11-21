import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/firebase_bootstrap.dart';
import '../../../app/flavor.dart';
import '../../../data/local/database_provider.dart';
import '../../../data/local/local_data_wiper.dart';
import '../domain/account_preferences.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';
import 'auth_local_store.dart';
import 'firebase_auth_repository.dart';
import 'provider_credentials.dart';

part 'providers.g.dart';

// Failures surface as values; Riverpod's in-session retry would only hide them.
Duration? _noRetry(int retryCount, Object error) => null;

@Riverpod(keepAlive: true, retry: _noRetry)
Future<bool> firebaseReady(Ref ref) async {
  try {
    return await bootstrapFirebase();
  } on Object {
    return false;
  }
}

@Riverpod(keepAlive: true)
AuthLocalStore authLocalStore(Ref ref) =>
    AuthLocalStore(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
AccountPreferencesStore accountPreferencesStore(Ref ref) =>
    ref.watch(authLocalStoreProvider);

@Riverpod(keepAlive: true, retry: _noRetry)
Stream<bool> useProviderProfile(Ref ref) =>
    ref.watch(accountPreferencesStoreProvider).watchUseProviderProfile();

@Riverpod(keepAlive: true, retry: _noRetry)
Stream<bool> authChoiceMade(Ref ref) =>
    ref.watch(authLocalStoreProvider).watchChoiceMade();

Future<bool> _isOnline() async => !(await Connectivity().checkConnectivity())
    .contains(ConnectivityResult.none);

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final repo = FirebaseAuthRepository(
    auth: ref
        .watch(firebaseReadyProvider.future)
        .then((ready) => ready ? FirebaseAuth.instance : null),
    providers: PlatformProviderCredentials(
      serverClientId: googleServerClientId,
    ),
    store: ref.watch(authLocalStoreProvider),
    wiper: LocalDataWiper(ref.watch(appDatabaseProvider)),
    isOnline: _isOnline,
  );
  unawaited(repo.start());
  final online = Connectivity().onConnectivityChanged.listen(
    (_) => repo.upgradeLocalGuest(),
  );
  ref.onDispose(() async {
    await online.cancel();
    await repo.dispose();
  });
  return repo;
}

@Riverpod(keepAlive: true, retry: _noRetry)
Stream<AuthUser?> currentUser(Ref ref) =>
    ref.watch(authRepositoryProvider).userChanges();

void startAuth(ProviderContainer container) =>
    container.read(authRepositoryProvider);
