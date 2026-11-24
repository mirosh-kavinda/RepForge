// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(progressPrefs)
final progressPrefsProvider = ProgressPrefsProvider._();

final class ProgressPrefsProvider
    extends $FunctionalProvider<ProgressPrefs, ProgressPrefs, ProgressPrefs>
    with $Provider<ProgressPrefs> {
  ProgressPrefsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'progressPrefsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$progressPrefsHash();

  @$internal
  @override
  $ProviderElement<ProgressPrefs> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProgressPrefs create(Ref ref) {
    return progressPrefs(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProgressPrefs value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProgressPrefs>(value),
    );
  }
}

String _$progressPrefsHash() => r'a2f2068cb6bead5361bbd28a69ca5e840c3c38c1';

@ProviderFor(SelectedRange)
final selectedRangeProvider = SelectedRangeProvider._();

final class SelectedRangeProvider
    extends $NotifierProvider<SelectedRange, ProgressRange> {
  SelectedRangeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedRangeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedRangeHash();

  @$internal
  @override
  SelectedRange create() => SelectedRange();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProgressRange value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProgressRange>(value),
    );
  }
}

String _$selectedRangeHash() => r'a78cb14b404ba752700a6870c858bd62658115e4';

abstract class _$SelectedRange extends $Notifier<ProgressRange> {
  ProgressRange build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ProgressRange, ProgressRange>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProgressRange, ProgressRange>,
              ProgressRange,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ChosenExercise)
final chosenExerciseProvider = ChosenExerciseProvider._();

final class ChosenExerciseProvider
    extends $AsyncNotifierProvider<ChosenExercise, String?> {
  ChosenExerciseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chosenExerciseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chosenExerciseHash();

  @$internal
  @override
  ChosenExercise create() => ChosenExercise();
}

String _$chosenExerciseHash() => r'0a4d79ff6ffc30f6f5e9236127b141105a282c35';

abstract class _$ChosenExercise extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(loggedExercises)
final loggedExercisesProvider = LoggedExercisesProvider._();

final class LoggedExercisesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<({String id, String name})>>,
          List<({String id, String name})>,
          FutureOr<List<({String id, String name})>>
        >
    with
        $FutureModifier<List<({String id, String name})>>,
        $FutureProvider<List<({String id, String name})>> {
  LoggedExercisesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loggedExercisesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loggedExercisesHash();

  @$internal
  @override
  $FutureProviderElement<List<({String id, String name})>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<({String id, String name})>> create(Ref ref) {
    return loggedExercises(ref);
  }
}

String _$loggedExercisesHash() => r'1e652285fae6bcfaa6279d06a972163661239a89';

@ProviderFor(strengthProgress)
final strengthProgressProvider = StrengthProgressProvider._();

final class StrengthProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<({String id, StrengthSeries series})?>,
          ({String id, StrengthSeries series})?,
          FutureOr<({String id, StrengthSeries series})?>
        >
    with
        $FutureModifier<({String id, StrengthSeries series})?>,
        $FutureProvider<({String id, StrengthSeries series})?> {
  StrengthProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'strengthProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$strengthProgressHash();

  @$internal
  @override
  $FutureProviderElement<({String id, StrengthSeries series})?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<({String id, StrengthSeries series})?> create(Ref ref) {
    return strengthProgress(ref);
  }
}

String _$strengthProgressHash() => r'8e9b965b0f23642179c31724f5c27778c9d0a0ca';

@ProviderFor(volumeProgress)
final volumeProgressProvider = VolumeProgressProvider._();

final class VolumeProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ChartPoint>>,
          List<ChartPoint>,
          FutureOr<List<ChartPoint>>
        >
    with $FutureModifier<List<ChartPoint>>, $FutureProvider<List<ChartPoint>> {
  VolumeProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'volumeProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$volumeProgressHash();

  @$internal
  @override
  $FutureProviderElement<List<ChartPoint>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ChartPoint>> create(Ref ref) {
    return volumeProgress(ref);
  }
}

String _$volumeProgressHash() => r'16c4e74bd59a0957652944512cedd3f61340f0e3';

@ProviderFor(bodyProgress)
final bodyProgressProvider = BodyProgressProvider._();

final class BodyProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<BodyTrends>,
          BodyTrends,
          FutureOr<BodyTrends>
        >
    with $FutureModifier<BodyTrends>, $FutureProvider<BodyTrends> {
  BodyProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bodyProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bodyProgressHash();

  @$internal
  @override
  $FutureProviderElement<BodyTrends> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<BodyTrends> create(Ref ref) {
    return bodyProgress(ref);
  }
}

String _$bodyProgressHash() => r'1135b57b7af5b719142718e917270ec0cb8c6a69';

@ProviderFor(statusHistory)
final statusHistoryProvider = StatusHistoryProvider._();

final class StatusHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DatedStatus>>,
          AsyncValue<List<DatedStatus>>,
          AsyncValue<List<DatedStatus>>
        >
    with $Provider<AsyncValue<List<DatedStatus>>> {
  StatusHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statusHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statusHistoryHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<DatedStatus>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<DatedStatus>> create(Ref ref) {
    return statusHistory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<DatedStatus>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<DatedStatus>>>(
        value,
      ),
    );
  }
}

String _$statusHistoryHash() => r'a42d2621970b78439a5a90871c3eaa36bf6646ef';

@ProviderFor(streak)
final streakProvider = StreakProvider._();

final class StreakProvider
    extends
        $FunctionalProvider<
          AsyncValue<int?>,
          AsyncValue<int?>,
          AsyncValue<int?>
        >
    with $Provider<AsyncValue<int?>> {
  StreakProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'streakProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$streakHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<int?>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AsyncValue<int?> create(Ref ref) {
    return streak(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<int?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<int?>>(value),
    );
  }
}

String _$streakHash() => r'18b001e0921a3f242cee1328b6b582d7f1ff979a';

@ProviderFor(adherence)
final adherenceProvider = AdherenceProvider._();

final class AdherenceProvider
    extends
        $FunctionalProvider<
          AsyncValue<AdherenceSummary>,
          AsyncValue<AdherenceSummary>,
          AsyncValue<AdherenceSummary>
        >
    with $Provider<AsyncValue<AdherenceSummary>> {
  AdherenceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adherenceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adherenceHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<AdherenceSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<AdherenceSummary> create(Ref ref) {
    return adherence(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<AdherenceSummary> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<AdherenceSummary>>(value),
    );
  }
}

String _$adherenceHash() => r'7324b5457cf97dc09e3bde8be64b16a0e86e9128';
