// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          SettingsRepository,
          SettingsRepository,
          SettingsRepository
        >
    with $Provider<SettingsRepository> {
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'0eda22c9c7a5e68c8661bf58b528d73264ef9a19';

@ProviderFor(trainingSettings)
final trainingSettingsProvider = TrainingSettingsProvider._();

final class TrainingSettingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<TrainingSettings>,
          TrainingSettings,
          Stream<TrainingSettings>
        >
    with $FutureModifier<TrainingSettings>, $StreamProvider<TrainingSettings> {
  TrainingSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trainingSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trainingSettingsHash();

  @$internal
  @override
  $StreamProviderElement<TrainingSettings> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<TrainingSettings> create(Ref ref) {
    return trainingSettings(ref);
  }
}

String _$trainingSettingsHash() => r'3669cd2ee3a0f2e0a001579692409beb9307a0cb';

@ProviderFor(reminderPref)
final reminderPrefProvider = ReminderPrefProvider._();

final class ReminderPrefProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReminderPref>,
          ReminderPref,
          Stream<ReminderPref>
        >
    with $FutureModifier<ReminderPref>, $StreamProvider<ReminderPref> {
  ReminderPrefProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reminderPrefProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reminderPrefHash();

  @$internal
  @override
  $StreamProviderElement<ReminderPref> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ReminderPref> create(Ref ref) {
    return reminderPref(ref);
  }
}

String _$reminderPrefHash() => r'9740199a6f686db9cfada4d11b2efd1698daaf8b';

@ProviderFor(workoutReminder)
final workoutReminderProvider = WorkoutReminderProvider._();

final class WorkoutReminderProvider
    extends
        $FunctionalProvider<WorkoutReminder, WorkoutReminder, WorkoutReminder>
    with $Provider<WorkoutReminder> {
  WorkoutReminderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutReminderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutReminderHash();

  @$internal
  @override
  $ProviderElement<WorkoutReminder> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WorkoutReminder create(Ref ref) {
    return workoutReminder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkoutReminder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkoutReminder>(value),
    );
  }
}

String _$workoutReminderHash() => r'dfe248ab107b2176d3ba810ba1b6907c9d91584d';

@ProviderFor(ResumeTick)
final resumeTickProvider = ResumeTickProvider._();

final class ResumeTickProvider extends $NotifierProvider<ResumeTick, int> {
  ResumeTickProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'resumeTickProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resumeTickHash();

  @$internal
  @override
  ResumeTick create() => ResumeTick();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$resumeTickHash() => r'2ad9dc41f6eb21dfa129314a93ee9d8cbd12a0d8';

abstract class _$ResumeTick extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(reminderScheduler)
final reminderSchedulerProvider = ReminderSchedulerProvider._();

final class ReminderSchedulerProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  ReminderSchedulerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reminderSchedulerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reminderSchedulerHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return reminderScheduler(ref);
  }
}

String _$reminderSchedulerHash() => r'6c543dea522ffab0c3209d5a80a5e1c0b1317c90';
