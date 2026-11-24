// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bodyRepository)
final bodyRepositoryProvider = BodyRepositoryProvider._();

final class BodyRepositoryProvider
    extends $FunctionalProvider<BodyRepository, BodyRepository, BodyRepository>
    with $Provider<BodyRepository> {
  BodyRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bodyRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bodyRepositoryHash();

  @$internal
  @override
  $ProviderElement<BodyRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BodyRepository create(Ref ref) {
    return bodyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BodyRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BodyRepository>(value),
    );
  }
}

String _$bodyRepositoryHash() => r'3bb3cd221aa5b9bb4b06812f8b0c691de34cbf25';

@ProviderFor(bodyProfile)
final bodyProfileProvider = BodyProfileProvider._();

final class BodyProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<BodyProfile>,
          BodyProfile,
          Stream<BodyProfile>
        >
    with $FutureModifier<BodyProfile>, $StreamProvider<BodyProfile> {
  BodyProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bodyProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bodyProfileHash();

  @$internal
  @override
  $StreamProviderElement<BodyProfile> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<BodyProfile> create(Ref ref) {
    return bodyProfile(ref);
  }
}

String _$bodyProfileHash() => r'c2c9ef6400d4d8f0a9f324b5da5d265ee2e01316';

@ProviderFor(bodySnapshots)
final bodySnapshotsProvider = BodySnapshotsProvider._();

final class BodySnapshotsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BodySnapshot>>,
          List<BodySnapshot>,
          Stream<List<BodySnapshot>>
        >
    with
        $FutureModifier<List<BodySnapshot>>,
        $StreamProvider<List<BodySnapshot>> {
  BodySnapshotsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bodySnapshotsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bodySnapshotsHash();

  @$internal
  @override
  $StreamProviderElement<List<BodySnapshot>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BodySnapshot>> create(Ref ref) {
    return bodySnapshots(ref);
  }
}

String _$bodySnapshotsHash() => r'af700463b2783ff49995f4a664a790837f8d94af';

@ProviderFor(bodySnapshot)
final bodySnapshotProvider = BodySnapshotFamily._();

final class BodySnapshotProvider
    extends
        $FunctionalProvider<
          AsyncValue<BodySnapshot?>,
          BodySnapshot?,
          FutureOr<BodySnapshot?>
        >
    with $FutureModifier<BodySnapshot?>, $FutureProvider<BodySnapshot?> {
  BodySnapshotProvider._({
    required BodySnapshotFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bodySnapshotProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bodySnapshotHash();

  @override
  String toString() {
    return r'bodySnapshotProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<BodySnapshot?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BodySnapshot?> create(Ref ref) {
    final argument = this.argument as String;
    return bodySnapshot(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BodySnapshotProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bodySnapshotHash() => r'dcde3f5a851b0ad672d9375eb45ac172af9f4fb5';

final class BodySnapshotFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<BodySnapshot?>, String> {
  BodySnapshotFamily._()
    : super(
        retry: null,
        name: r'bodySnapshotProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BodySnapshotProvider call(String id) =>
      BodySnapshotProvider._(argument: id, from: this);

  @override
  String toString() => r'bodySnapshotProvider';
}
