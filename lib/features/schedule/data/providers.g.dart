// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cycleRepository)
final cycleRepositoryProvider = CycleRepositoryProvider._();

final class CycleRepositoryProvider
    extends
        $FunctionalProvider<CycleRepository, CycleRepository, CycleRepository>
    with $Provider<CycleRepository> {
  CycleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cycleRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cycleRepositoryHash();

  @$internal
  @override
  $ProviderElement<CycleRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CycleRepository create(Ref ref) {
    return cycleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CycleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CycleRepository>(value),
    );
  }
}

String _$cycleRepositoryHash() => r'd666b9a8ea9665d587910543a618906833f1ae3f';

@ProviderFor(cycles)
final cyclesProvider = CyclesProvider._();

final class CyclesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Cycle>>,
          List<Cycle>,
          Stream<List<Cycle>>
        >
    with $FutureModifier<List<Cycle>>, $StreamProvider<List<Cycle>> {
  CyclesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cyclesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cyclesHash();

  @$internal
  @override
  $StreamProviderElement<List<Cycle>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Cycle>> create(Ref ref) {
    return cycles(ref);
  }
}

String _$cyclesHash() => r'580d2541f042960f80c7dd396bc81a587ea73aee';

@ProviderFor(activeCycle)
final activeCycleProvider = ActiveCycleProvider._();

final class ActiveCycleProvider
    extends $FunctionalProvider<AsyncValue<Cycle?>, Cycle?, Stream<Cycle?>>
    with $FutureModifier<Cycle?>, $StreamProvider<Cycle?> {
  ActiveCycleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeCycleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeCycleHash();

  @$internal
  @override
  $StreamProviderElement<Cycle?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Cycle?> create(Ref ref) {
    return activeCycle(ref);
  }
}

String _$activeCycleHash() => r'f48e5f674a4026f9f38c32251d71f921c3522288';
