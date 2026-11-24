// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(goalRepository)
final goalRepositoryProvider = GoalRepositoryProvider._();

final class GoalRepositoryProvider
    extends $FunctionalProvider<GoalRepository, GoalRepository, GoalRepository>
    with $Provider<GoalRepository> {
  GoalRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalRepositoryHash();

  @$internal
  @override
  $ProviderElement<GoalRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoalRepository create(Ref ref) {
    return goalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoalRepository>(value),
    );
  }
}

String _$goalRepositoryHash() => r'ffd358a8b521ae581fcaf58a8c55667d871c8259';

@ProviderFor(goals)
final goalsProvider = GoalsProvider._();

final class GoalsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Goal>>,
          List<Goal>,
          Stream<List<Goal>>
        >
    with $FutureModifier<List<Goal>>, $StreamProvider<List<Goal>> {
  GoalsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalsHash();

  @$internal
  @override
  $StreamProviderElement<List<Goal>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Goal>> create(Ref ref) {
    return goals(ref);
  }
}

String _$goalsHash() => r'71f302ceb94bb61812897048d168cff290b1f31b';

@ProviderFor(goalHistory)
final goalHistoryProvider = GoalHistoryFamily._();

final class GoalHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Measurement>>,
          List<Measurement>,
          FutureOr<List<Measurement>>
        >
    with
        $FutureModifier<List<Measurement>>,
        $FutureProvider<List<Measurement>> {
  GoalHistoryProvider._({
    required GoalHistoryFamily super.from,
    required (GoalType, String?) super.argument,
  }) : super(
         retry: null,
         name: r'goalHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$goalHistoryHash();

  @override
  String toString() {
    return r'goalHistoryProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Measurement>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Measurement>> create(Ref ref) {
    final argument = this.argument as (GoalType, String?);
    return goalHistory(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is GoalHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$goalHistoryHash() => r'3ea346678a50e60a9b3500c9b1819df8205b88b7';

final class GoalHistoryFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Measurement>>,
          (GoalType, String?)
        > {
  GoalHistoryFamily._()
    : super(
        retry: null,
        name: r'goalHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GoalHistoryProvider call(GoalType type, String? exerciseId) =>
      GoalHistoryProvider._(argument: (type, exerciseId), from: this);

  @override
  String toString() => r'goalHistoryProvider';
}

@ProviderFor(goalStatusOf)
final goalStatusOfProvider = GoalStatusOfFamily._();

final class GoalStatusOfProvider
    extends
        $FunctionalProvider<
          AsyncValue<GoalStatus>,
          GoalStatus,
          FutureOr<GoalStatus>
        >
    with $FutureModifier<GoalStatus>, $FutureProvider<GoalStatus> {
  GoalStatusOfProvider._({
    required GoalStatusOfFamily super.from,
    required Goal super.argument,
  }) : super(
         retry: null,
         name: r'goalStatusOfProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$goalStatusOfHash();

  @override
  String toString() {
    return r'goalStatusOfProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<GoalStatus> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<GoalStatus> create(Ref ref) {
    final argument = this.argument as Goal;
    return goalStatusOf(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GoalStatusOfProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$goalStatusOfHash() => r'dc489335e8cb171af893d8716f7ea05f13feb0cf';

final class GoalStatusOfFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<GoalStatus>, Goal> {
  GoalStatusOfFamily._()
    : super(
        retry: null,
        name: r'goalStatusOfProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GoalStatusOfProvider call(Goal goal) =>
      GoalStatusOfProvider._(argument: goal, from: this);

  @override
  String toString() => r'goalStatusOfProvider';
}

@ProviderFor(goalSettler)
final goalSettlerProvider = GoalSettlerProvider._();

final class GoalSettlerProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  GoalSettlerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalSettlerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalSettlerHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return goalSettler(ref);
  }
}

String _$goalSettlerHash() => r'37c2ef769e7b81bd486947a829443ee7af612625';

@ProviderFor(homeGoalOf)
final homeGoalOfProvider = HomeGoalOfProvider._();

final class HomeGoalOfProvider
    extends
        $FunctionalProvider<
          AsyncValue<Goal?>,
          AsyncValue<Goal?>,
          AsyncValue<Goal?>
        >
    with $Provider<AsyncValue<Goal?>> {
  HomeGoalOfProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeGoalOfProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeGoalOfHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<Goal?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<Goal?> create(Ref ref) {
    return homeGoalOf(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<Goal?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<Goal?>>(value),
    );
  }
}

String _$homeGoalOfHash() => r'5b45461e22054a6bd012361567be1298e82e7512';

@ProviderFor(goalLifts)
final goalLiftsProvider = GoalLiftsProvider._();

final class GoalLiftsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<({double current, String id, String name})>>,
          List<({double current, String id, String name})>,
          FutureOr<List<({double current, String id, String name})>>
        >
    with
        $FutureModifier<List<({double current, String id, String name})>>,
        $FutureProvider<List<({double current, String id, String name})>> {
  GoalLiftsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalLiftsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalLiftsHash();

  @$internal
  @override
  $FutureProviderElement<List<({double current, String id, String name})>>
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<({double current, String id, String name})>> create(Ref ref) {
    return goalLifts(ref);
  }
}

String _$goalLiftsHash() => r'c806f82ddb5686974d829e86bb45d61f606465d9';

@ProviderFor(goalLiftName)
final goalLiftNameProvider = GoalLiftNameFamily._();

final class GoalLiftNameProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  GoalLiftNameProvider._({
    required GoalLiftNameFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'goalLiftNameProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$goalLiftNameHash();

  @override
  String toString() {
    return r'goalLiftNameProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as String;
    return goalLiftName(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GoalLiftNameProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$goalLiftNameHash() => r'3e460794ea89ed0638818b3e38811c7c6565c19a';

final class GoalLiftNameFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, String> {
  GoalLiftNameFamily._()
    : super(
        retry: null,
        name: r'goalLiftNameProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GoalLiftNameProvider call(String id) =>
      GoalLiftNameProvider._(argument: id, from: this);

  @override
  String toString() => r'goalLiftNameProvider';
}
