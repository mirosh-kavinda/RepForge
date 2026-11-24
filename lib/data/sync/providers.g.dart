// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(remoteStore)
final remoteStoreProvider = RemoteStoreProvider._();

final class RemoteStoreProvider
    extends $FunctionalProvider<RemoteStore, RemoteStore, RemoteStore>
    with $Provider<RemoteStore> {
  RemoteStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remoteStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remoteStoreHash();

  @$internal
  @override
  $ProviderElement<RemoteStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RemoteStore create(Ref ref) {
    return remoteStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemoteStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemoteStore>(value),
    );
  }
}

String _$remoteStoreHash() => r'94df258fc93167994d563bf72bc597027c2ab7a1';

@ProviderFor(syncEngine)
final syncEngineProvider = SyncEngineProvider._();

final class SyncEngineProvider
    extends $FunctionalProvider<SyncEngine, SyncEngine, SyncEngine>
    with $Provider<SyncEngine> {
  SyncEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncEngineHash();

  @$internal
  @override
  $ProviderElement<SyncEngine> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncEngine create(Ref ref) {
    return syncEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncEngine>(value),
    );
  }
}

String _$syncEngineHash() => r'6e57165442a85bf98cb142612711303cfd913fe3';

@ProviderFor(syncStatus)
final syncStatusProvider = SyncStatusProvider._();

final class SyncStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<SyncStatus>,
          SyncStatus,
          Stream<SyncStatus>
        >
    with $FutureModifier<SyncStatus>, $StreamProvider<SyncStatus> {
  SyncStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncStatusHash();

  @$internal
  @override
  $StreamProviderElement<SyncStatus> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<SyncStatus> create(Ref ref) {
    return syncStatus(ref);
  }
}

String _$syncStatusHash() => r'23ab869bc26eda020f628095d78f1b8c4d53cd5d';

@ProviderFor(syncScheduler)
final syncSchedulerProvider = SyncSchedulerProvider._();

final class SyncSchedulerProvider
    extends $FunctionalProvider<SyncScheduler, SyncScheduler, SyncScheduler>
    with $Provider<SyncScheduler> {
  SyncSchedulerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncSchedulerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncSchedulerHash();

  @$internal
  @override
  $ProviderElement<SyncScheduler> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncScheduler create(Ref ref) {
    return syncScheduler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncScheduler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncScheduler>(value),
    );
  }
}

String _$syncSchedulerHash() => r'31256a7e2fdf8c543bf7bc53eb7c48817f32e857';
