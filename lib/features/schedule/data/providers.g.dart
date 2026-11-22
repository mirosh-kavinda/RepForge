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

@ProviderFor(dayRecordRepository)
final dayRecordRepositoryProvider = DayRecordRepositoryProvider._();

final class DayRecordRepositoryProvider
    extends
        $FunctionalProvider<
          DayRecordRepository,
          DayRecordRepository,
          DayRecordRepository
        >
    with $Provider<DayRecordRepository> {
  DayRecordRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dayRecordRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dayRecordRepositoryHash();

  @$internal
  @override
  $ProviderElement<DayRecordRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DayRecordRepository create(Ref ref) {
    return dayRecordRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DayRecordRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DayRecordRepository>(value),
    );
  }
}

String _$dayRecordRepositoryHash() =>
    r'af529cc6076436c9577b757c33c8969acb7714d9';

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

@ProviderFor(dayRecords)
final dayRecordsProvider = DayRecordsFamily._();

final class DayRecordsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DayRecord>>,
          List<DayRecord>,
          Stream<List<DayRecord>>
        >
    with $FutureModifier<List<DayRecord>>, $StreamProvider<List<DayRecord>> {
  DayRecordsProvider._({
    required DayRecordsFamily super.from,
    required (String, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'dayRecordsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dayRecordsHash();

  @override
  String toString() {
    return r'dayRecordsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<DayRecord>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DayRecord>> create(Ref ref) {
    final argument = this.argument as (String, DateTime);
    return dayRecords(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is DayRecordsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dayRecordsHash() => r'84082bf12bec7fe62e3a0888bc3bfaa1ed1601b9';

final class DayRecordsFamily extends $Family
    with
        $FunctionalFamilyOverride<Stream<List<DayRecord>>, (String, DateTime)> {
  DayRecordsFamily._()
    : super(
        retry: null,
        name: r'dayRecordsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DayRecordsProvider call(String cycleId, DateTime from) =>
      DayRecordsProvider._(argument: (cycleId, from), from: this);

  @override
  String toString() => r'dayRecordsProvider';
}

@ProviderFor(latestDaySeen)
final latestDaySeenProvider = LatestDaySeenProvider._();

final class LatestDaySeenProvider
    extends
        $FunctionalProvider<AsyncValue<DateTime?>, DateTime?, Stream<DateTime?>>
    with $FutureModifier<DateTime?>, $StreamProvider<DateTime?> {
  LatestDaySeenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'latestDaySeenProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$latestDaySeenHash();

  @$internal
  @override
  $StreamProviderElement<DateTime?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<DateTime?> create(Ref ref) {
    return latestDaySeen(ref);
  }
}

String _$latestDaySeenHash() => r'b81f96047d0764e9b583845d3f384f7506a5b495';

@ProviderFor(cycleToday)
final cycleTodayProvider = CycleTodayProvider._();

final class CycleTodayProvider
    extends
        $FunctionalProvider<
          AsyncValue<ActiveToday?>,
          AsyncValue<ActiveToday?>,
          AsyncValue<ActiveToday?>
        >
    with $Provider<AsyncValue<ActiveToday?>> {
  CycleTodayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cycleTodayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cycleTodayHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<ActiveToday?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<ActiveToday?> create(Ref ref) {
    return cycleToday(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<ActiveToday?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<ActiveToday?>>(value),
    );
  }
}

String _$cycleTodayHash() => r'f3f68bcef563b82de98759bb0f0b40c51947e251';

@ProviderFor(cycleSettler)
final cycleSettlerProvider = CycleSettlerProvider._();

final class CycleSettlerProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  CycleSettlerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cycleSettlerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cycleSettlerHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return cycleSettler(ref);
  }
}

String _$cycleSettlerHash() => r'60776daac4fe3da43c56ce48e8c465a109b3ec16';
