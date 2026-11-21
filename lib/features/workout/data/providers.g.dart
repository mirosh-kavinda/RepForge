// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(templateRepository)
final templateRepositoryProvider = TemplateRepositoryProvider._();

final class TemplateRepositoryProvider
    extends
        $FunctionalProvider<
          TemplateRepository,
          TemplateRepository,
          TemplateRepository
        >
    with $Provider<TemplateRepository> {
  TemplateRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'templateRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$templateRepositoryHash();

  @$internal
  @override
  $ProviderElement<TemplateRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TemplateRepository create(Ref ref) {
    return templateRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TemplateRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TemplateRepository>(value),
    );
  }
}

String _$templateRepositoryHash() =>
    r'08b0654e55bb39a15246aba1242023fcc4645fb8';

@ProviderFor(templates)
final templatesProvider = TemplatesProvider._();

final class TemplatesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkoutTemplate>>,
          List<WorkoutTemplate>,
          Stream<List<WorkoutTemplate>>
        >
    with
        $FutureModifier<List<WorkoutTemplate>>,
        $StreamProvider<List<WorkoutTemplate>> {
  TemplatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'templatesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$templatesHash();

  @$internal
  @override
  $StreamProviderElement<List<WorkoutTemplate>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<WorkoutTemplate>> create(Ref ref) {
    return templates(ref);
  }
}

String _$templatesHash() => r'79034fa2ecde4c848f647a0474d355bf8c209bd8';

@ProviderFor(workoutMuscles)
final workoutMusclesProvider = WorkoutMusclesFamily._();

final class WorkoutMusclesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Muscle>>,
          List<Muscle>,
          FutureOr<List<Muscle>>
        >
    with $FutureModifier<List<Muscle>>, $FutureProvider<List<Muscle>> {
  WorkoutMusclesProvider._({
    required WorkoutMusclesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'workoutMusclesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$workoutMusclesHash();

  @override
  String toString() {
    return r'workoutMusclesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Muscle>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Muscle>> create(Ref ref) {
    final argument = this.argument as String;
    return workoutMuscles(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkoutMusclesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$workoutMusclesHash() => r'1ffd651529bcaf4b09637e41ce15b608ae52abf3';

final class WorkoutMusclesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Muscle>>, String> {
  WorkoutMusclesFamily._()
    : super(
        retry: null,
        name: r'workoutMusclesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WorkoutMusclesProvider call(String workoutId) =>
      WorkoutMusclesProvider._(argument: workoutId, from: this);

  @override
  String toString() => r'workoutMusclesProvider';
}
