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

@ProviderFor(restoreState)
final restoreStateProvider = RestoreStateProvider._();

final class RestoreStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<RestoreState?>,
          RestoreState?,
          Stream<RestoreState?>
        >
    with $FutureModifier<RestoreState?>, $StreamProvider<RestoreState?> {
  RestoreStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'restoreStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$restoreStateHash();

  @$internal
  @override
  $StreamProviderElement<RestoreState?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<RestoreState?> create(Ref ref) {
    return restoreState(ref);
  }
}

String _$restoreStateHash() => r'9cf203cfec2469fbe55f469053c45f679fe9f705';

@ProviderFor(restoreProgress)
final restoreProgressProvider = RestoreProgressProvider._();

final class RestoreProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<RestoreProgress?>,
          RestoreProgress?,
          Stream<RestoreProgress?>
        >
    with $FutureModifier<RestoreProgress?>, $StreamProvider<RestoreProgress?> {
  RestoreProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'restoreProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$restoreProgressHash();

  @$internal
  @override
  $StreamProviderElement<RestoreProgress?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<RestoreProgress?> create(Ref ref) {
    return restoreProgress(ref);
  }
}

String _$restoreProgressHash() => r'f58a6b193902e51c5f84883b114ef803d116a0eb';

@ProviderFor(backupSummary)
final backupSummaryProvider = BackupSummaryProvider._();

final class BackupSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<BackupSummary?>,
          BackupSummary?,
          FutureOr<BackupSummary?>
        >
    with $FutureModifier<BackupSummary?>, $FutureProvider<BackupSummary?> {
  BackupSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupSummaryHash();

  @$internal
  @override
  $FutureProviderElement<BackupSummary?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BackupSummary?> create(Ref ref) {
    return backupSummary(ref);
  }
}

String _$backupSummaryHash() => r'118e6c459db2586e1f4507ca530f3d19dd1151d7';

@ProviderFor(online)
final onlineProvider = OnlineProvider._();

final class OnlineProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  OnlineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onlineProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onlineHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return online(ref);
  }
}

String _$onlineHash() => r'9765813d9c1d30269743141c9a6c7aa0e1a68d1b';

@ProviderFor(restoreController)
final restoreControllerProvider = RestoreControllerProvider._();

final class RestoreControllerProvider
    extends $FunctionalProvider<RestoreActions, RestoreActions, RestoreActions>
    with $Provider<RestoreActions> {
  RestoreControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'restoreControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$restoreControllerHash();

  @$internal
  @override
  $ProviderElement<RestoreActions> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RestoreActions create(Ref ref) {
    return restoreController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RestoreActions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RestoreActions>(value),
    );
  }
}

String _$restoreControllerHash() => r'e7f881293ff79d9b2651aee924a97c16c666f3b9';
