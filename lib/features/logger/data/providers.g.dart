// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sessionRepository)
final sessionRepositoryProvider = SessionRepositoryProvider._();

final class SessionRepositoryProvider
    extends
        $FunctionalProvider<
          SessionRepository,
          SessionRepository,
          SessionRepository
        >
    with $Provider<SessionRepository> {
  SessionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionRepositoryHash();

  @$internal
  @override
  $ProviderElement<SessionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SessionRepository create(Ref ref) {
    return sessionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionRepository>(value),
    );
  }
}

String _$sessionRepositoryHash() => r'ebaaa244111aae10fae81af44e4883c75609833d';

@ProviderFor(activeSession)
final activeSessionProvider = ActiveSessionProvider._();

final class ActiveSessionProvider
    extends
        $FunctionalProvider<
          AsyncValue<WorkoutSession?>,
          WorkoutSession?,
          Stream<WorkoutSession?>
        >
    with $FutureModifier<WorkoutSession?>, $StreamProvider<WorkoutSession?> {
  ActiveSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeSessionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeSessionHash();

  @$internal
  @override
  $StreamProviderElement<WorkoutSession?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<WorkoutSession?> create(Ref ref) {
    return activeSession(ref);
  }
}

String _$activeSessionHash() => r'4ce54ae5062fc8fa3617b8ce005ec96088ede9ce';

@ProviderFor(lastSets)
final lastSetsProvider = LastSetsFamily._();

final class LastSetsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<int, LoggedSet>>,
          Map<int, LoggedSet>,
          FutureOr<Map<int, LoggedSet>>
        >
    with
        $FutureModifier<Map<int, LoggedSet>>,
        $FutureProvider<Map<int, LoggedSet>> {
  LastSetsProvider._({
    required LastSetsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'lastSetsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lastSetsHash();

  @override
  String toString() {
    return r'lastSetsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<int, LoggedSet>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<int, LoggedSet>> create(Ref ref) {
    final argument = this.argument as String;
    return lastSets(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LastSetsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lastSetsHash() => r'ef64dc87e964aa4c76d81e0d95e6a1154a460885';

final class LastSetsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<int, LoggedSet>>, String> {
  LastSetsFamily._()
    : super(
        retry: null,
        name: r'lastSetsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LastSetsProvider call(String exerciseId) =>
      LastSetsProvider._(argument: exerciseId, from: this);

  @override
  String toString() => r'lastSetsProvider';
}
