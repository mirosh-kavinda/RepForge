// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(firebaseReady)
final firebaseReadyProvider = FirebaseReadyProvider._();

final class FirebaseReadyProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  FirebaseReadyProvider._()
    : super(
        from: null,
        argument: null,
        retry: _noRetry,
        name: r'firebaseReadyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseReadyHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return firebaseReady(ref);
  }
}

String _$firebaseReadyHash() => r'778a2588d28447d44314fd6350af2b56d7eac389';

@ProviderFor(authLocalStore)
final authLocalStoreProvider = AuthLocalStoreProvider._();

final class AuthLocalStoreProvider
    extends $FunctionalProvider<AuthLocalStore, AuthLocalStore, AuthLocalStore>
    with $Provider<AuthLocalStore> {
  AuthLocalStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authLocalStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authLocalStoreHash();

  @$internal
  @override
  $ProviderElement<AuthLocalStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthLocalStore create(Ref ref) {
    return authLocalStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthLocalStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthLocalStore>(value),
    );
  }
}

String _$authLocalStoreHash() => r'9d9d68854bb3ceb4e1a529c451a7eee3bb6634e5';

@ProviderFor(accountPreferencesStore)
final accountPreferencesStoreProvider = AccountPreferencesStoreProvider._();

final class AccountPreferencesStoreProvider
    extends
        $FunctionalProvider<
          AccountPreferencesStore,
          AccountPreferencesStore,
          AccountPreferencesStore
        >
    with $Provider<AccountPreferencesStore> {
  AccountPreferencesStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountPreferencesStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountPreferencesStoreHash();

  @$internal
  @override
  $ProviderElement<AccountPreferencesStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AccountPreferencesStore create(Ref ref) {
    return accountPreferencesStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountPreferencesStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountPreferencesStore>(value),
    );
  }
}

String _$accountPreferencesStoreHash() =>
    r'ada4e30f0c8a85d24d91aa67ed1eb1ae71573b14';

@ProviderFor(useProviderProfile)
final useProviderProfileProvider = UseProviderProfileProvider._();

final class UseProviderProfileProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  UseProviderProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: _noRetry,
        name: r'useProviderProfileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$useProviderProfileHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return useProviderProfile(ref);
  }
}

String _$useProviderProfileHash() =>
    r'c4a9f137b7571101325be707a076ded5681fc47e';

@ProviderFor(authChoiceMade)
final authChoiceMadeProvider = AuthChoiceMadeProvider._();

final class AuthChoiceMadeProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  AuthChoiceMadeProvider._()
    : super(
        from: null,
        argument: null,
        retry: _noRetry,
        name: r'authChoiceMadeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authChoiceMadeHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return authChoiceMade(ref);
  }
}

String _$authChoiceMadeHash() => r'ba32b3072d6687428aec33347791ddb86070ef27';

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'160d27162dd17fae1c3522fe63a372c4469413d1';

@ProviderFor(currentUser)
final currentUserProvider = CurrentUserProvider._();

final class CurrentUserProvider
    extends
        $FunctionalProvider<AsyncValue<AuthUser?>, AuthUser?, Stream<AuthUser?>>
    with $FutureModifier<AuthUser?>, $StreamProvider<AuthUser?> {
  CurrentUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: _noRetry,
        name: r'currentUserProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserHash();

  @$internal
  @override
  $StreamProviderElement<AuthUser?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AuthUser?> create(Ref ref) {
    return currentUser(ref);
  }
}

String _$currentUserHash() => r'396586a1ee36d43d393e01fe3ef972d6b02fc51c';
