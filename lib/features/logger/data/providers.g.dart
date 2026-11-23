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

@ProviderFor(restAlarm)
final restAlarmProvider = RestAlarmProvider._();

final class RestAlarmProvider
    extends $FunctionalProvider<RestAlarm, RestAlarm, RestAlarm>
    with $Provider<RestAlarm> {
  RestAlarmProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'restAlarmProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$restAlarmHash();

  @$internal
  @override
  $ProviderElement<RestAlarm> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RestAlarm create(Ref ref) {
    return restAlarm(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RestAlarm value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RestAlarm>(value),
    );
  }
}

String _$restAlarmHash() => r'bb9229615bdcda7cc0e74a4470bee413f2fbda55';

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

@ProviderFor(exerciseHistory)
final exerciseHistoryProvider = ExerciseHistoryFamily._();

final class ExerciseHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LoggedSet>>,
          List<LoggedSet>,
          FutureOr<List<LoggedSet>>
        >
    with $FutureModifier<List<LoggedSet>>, $FutureProvider<List<LoggedSet>> {
  ExerciseHistoryProvider._({
    required ExerciseHistoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'exerciseHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$exerciseHistoryHash();

  @override
  String toString() {
    return r'exerciseHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<LoggedSet>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<LoggedSet>> create(Ref ref) {
    final argument = this.argument as String;
    return exerciseHistory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExerciseHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$exerciseHistoryHash() => r'1b1b273e28b283b4a3fe885c9a94881837b1ab83';

final class ExerciseHistoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<LoggedSet>>, String> {
  ExerciseHistoryFamily._()
    : super(
        retry: null,
        name: r'exerciseHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ExerciseHistoryProvider call(String exerciseId) =>
      ExerciseHistoryProvider._(argument: exerciseId, from: this);

  @override
  String toString() => r'exerciseHistoryProvider';
}

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

@ProviderFor(summaryShare)
final summaryShareProvider = SummaryShareProvider._();

final class SummaryShareProvider
    extends $FunctionalProvider<SummaryShare, SummaryShare, SummaryShare>
    with $Provider<SummaryShare> {
  SummaryShareProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'summaryShareProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$summaryShareHash();

  @$internal
  @override
  $ProviderElement<SummaryShare> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SummaryShare create(Ref ref) {
    return summaryShare(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SummaryShare value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SummaryShare>(value),
    );
  }
}

String _$summaryShareHash() => r'd5bd487de0ab5f2621be2a480b71e156f4ebad36';

@ProviderFor(workoutSummary)
final workoutSummaryProvider = WorkoutSummaryFamily._();

final class WorkoutSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<WorkoutSummary?>,
          WorkoutSummary?,
          FutureOr<WorkoutSummary?>
        >
    with $FutureModifier<WorkoutSummary?>, $FutureProvider<WorkoutSummary?> {
  WorkoutSummaryProvider._({
    required WorkoutSummaryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'workoutSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$workoutSummaryHash();

  @override
  String toString() {
    return r'workoutSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<WorkoutSummary?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WorkoutSummary?> create(Ref ref) {
    final argument = this.argument as String;
    return workoutSummary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkoutSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$workoutSummaryHash() => r'991c8dff085c5aa4b881ca6508a5ca02a976cc01';

final class WorkoutSummaryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<WorkoutSummary?>, String> {
  WorkoutSummaryFamily._()
    : super(
        retry: null,
        name: r'workoutSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WorkoutSummaryProvider call(String sessionId) =>
      WorkoutSummaryProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'workoutSummaryProvider';
}

@ProviderFor(finishedOn)
final finishedOnProvider = FinishedOnFamily._();

final class FinishedOnProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<({String id, String name})>>,
          List<({String id, String name})>,
          FutureOr<List<({String id, String name})>>
        >
    with
        $FutureModifier<List<({String id, String name})>>,
        $FutureProvider<List<({String id, String name})>> {
  FinishedOnProvider._({
    required FinishedOnFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'finishedOnProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$finishedOnHash();

  @override
  String toString() {
    return r'finishedOnProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<({String id, String name})>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<({String id, String name})>> create(Ref ref) {
    final argument = this.argument as DateTime;
    return finishedOn(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FinishedOnProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$finishedOnHash() => r'8e88416045b2d272222ecf61d2e6ba80c03b6e36';

final class FinishedOnFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<({String id, String name})>>,
          DateTime
        > {
  FinishedOnFamily._()
    : super(
        retry: null,
        name: r'finishedOnProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FinishedOnProvider call(DateTime date) =>
      FinishedOnProvider._(argument: date, from: this);

  @override
  String toString() => r'finishedOnProvider';
}

@ProviderFor(recentExercises)
final recentExercisesProvider = RecentExercisesProvider._();

final class RecentExercisesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          Stream<List<String>>
        >
    with $FutureModifier<List<String>>, $StreamProvider<List<String>> {
  RecentExercisesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentExercisesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentExercisesHash();

  @$internal
  @override
  $StreamProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<String>> create(Ref ref) {
    return recentExercises(ref);
  }
}

String _$recentExercisesHash() => r'87e3d3d59e5877acec250743938406091c898e14';

@ProviderFor(exerciseLog)
final exerciseLogProvider = ExerciseLogFamily._();

final class ExerciseLogProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ExerciseLogEntry>>,
          List<ExerciseLogEntry>,
          FutureOr<List<ExerciseLogEntry>>
        >
    with
        $FutureModifier<List<ExerciseLogEntry>>,
        $FutureProvider<List<ExerciseLogEntry>> {
  ExerciseLogProvider._({
    required ExerciseLogFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'exerciseLogProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$exerciseLogHash();

  @override
  String toString() {
    return r'exerciseLogProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ExerciseLogEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ExerciseLogEntry>> create(Ref ref) {
    final argument = this.argument as String;
    return exerciseLog(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExerciseLogProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$exerciseLogHash() => r'cab80a75bd49c42cdfe0177ce63076b941e30668';

final class ExerciseLogFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ExerciseLogEntry>>, String> {
  ExerciseLogFamily._()
    : super(
        retry: null,
        name: r'exerciseLogProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ExerciseLogProvider call(String exerciseId) =>
      ExerciseLogProvider._(argument: exerciseId, from: this);

  @override
  String toString() => r'exerciseLogProvider';
}

@ProviderFor(exerciseBestE1rm)
final exerciseBestE1rmProvider = ExerciseBestE1rmFamily._();

final class ExerciseBestE1rmProvider
    extends $FunctionalProvider<AsyncValue<double?>, double?, FutureOr<double?>>
    with $FutureModifier<double?>, $FutureProvider<double?> {
  ExerciseBestE1rmProvider._({
    required ExerciseBestE1rmFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'exerciseBestE1rmProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$exerciseBestE1rmHash();

  @override
  String toString() {
    return r'exerciseBestE1rmProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<double?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<double?> create(Ref ref) {
    final argument = this.argument as String;
    return exerciseBestE1rm(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExerciseBestE1rmProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$exerciseBestE1rmHash() => r'00f3962554be128547562fe23f5fb532b0cd8107';

final class ExerciseBestE1rmFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<double?>, String> {
  ExerciseBestE1rmFamily._()
    : super(
        retry: null,
        name: r'exerciseBestE1rmProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ExerciseBestE1rmProvider call(String exerciseId) =>
      ExerciseBestE1rmProvider._(argument: exerciseId, from: this);

  @override
  String toString() => r'exerciseBestE1rmProvider';
}
