// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(seedLoader)
final seedLoaderProvider = SeedLoaderProvider._();

final class SeedLoaderProvider
    extends
        $FunctionalProvider<
          Future<String> Function(),
          Future<String> Function(),
          Future<String> Function()
        >
    with $Provider<Future<String> Function()> {
  SeedLoaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'seedLoaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$seedLoaderHash();

  @$internal
  @override
  $ProviderElement<Future<String> Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Future<String> Function() create(Ref ref) {
    return seedLoader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Future<String> Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Future<String> Function()>(value),
    );
  }
}

String _$seedLoaderHash() => r'0b57eec5ec32b0d89b2455aa8d1d6cf87ffcbd05';

@ProviderFor(catalogImport)
final catalogImportProvider = CatalogImportProvider._();

final class CatalogImportProvider
    extends
        $FunctionalProvider<
          AsyncValue<ImportResult>,
          ImportResult,
          FutureOr<ImportResult>
        >
    with $FutureModifier<ImportResult>, $FutureProvider<ImportResult> {
  CatalogImportProvider._()
    : super(
        from: null,
        argument: null,
        retry: _noRetry,
        name: r'catalogImportProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogImportHash();

  @$internal
  @override
  $FutureProviderElement<ImportResult> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ImportResult> create(Ref ref) {
    return catalogImport(ref);
  }
}

String _$catalogImportHash() => r'a5e5980ecce693d46aca9dfaa3a3dedd860212a8';

@ProviderFor(exerciseCatalog)
final exerciseCatalogProvider = ExerciseCatalogProvider._();

final class ExerciseCatalogProvider
    extends
        $FunctionalProvider<
          AsyncValue<ExerciseCatalogRepository>,
          ExerciseCatalogRepository,
          FutureOr<ExerciseCatalogRepository>
        >
    with
        $FutureModifier<ExerciseCatalogRepository>,
        $FutureProvider<ExerciseCatalogRepository> {
  ExerciseCatalogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exerciseCatalogProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exerciseCatalogHash();

  @$internal
  @override
  $FutureProviderElement<ExerciseCatalogRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ExerciseCatalogRepository> create(Ref ref) {
    return exerciseCatalog(ref);
  }
}

String _$exerciseCatalogHash() => r'ebf94dda6da67133c70801ce5c65e247dd8e700c';

@ProviderFor(customExerciseRepository)
final customExerciseRepositoryProvider = CustomExerciseRepositoryProvider._();

final class CustomExerciseRepositoryProvider
    extends
        $FunctionalProvider<
          CustomExerciseRepository,
          CustomExerciseRepository,
          CustomExerciseRepository
        >
    with $Provider<CustomExerciseRepository> {
  CustomExerciseRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customExerciseRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customExerciseRepositoryHash();

  @$internal
  @override
  $ProviderElement<CustomExerciseRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CustomExerciseRepository create(Ref ref) {
    return customExerciseRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CustomExerciseRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CustomExerciseRepository>(value),
    );
  }
}

String _$customExerciseRepositoryHash() =>
    r'1ca8ebf85c0dc03d9f75118b7ffbc8c48994ef28';

@ProviderFor(customExercises)
final customExercisesProvider = CustomExercisesProvider._();

final class CustomExercisesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Exercise>>,
          List<Exercise>,
          Stream<List<Exercise>>
        >
    with $FutureModifier<List<Exercise>>, $StreamProvider<List<Exercise>> {
  CustomExercisesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customExercisesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customExercisesHash();

  @$internal
  @override
  $StreamProviderElement<List<Exercise>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Exercise>> create(Ref ref) {
    return customExercises(ref);
  }
}

String _$customExercisesHash() => r'223d804c9bc1bb403c85552bcb2e62b4e70c8ede';

@ProviderFor(exerciseById)
final exerciseByIdProvider = ExerciseByIdFamily._();

final class ExerciseByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<Exercise?>,
          Exercise?,
          FutureOr<Exercise?>
        >
    with $FutureModifier<Exercise?>, $FutureProvider<Exercise?> {
  ExerciseByIdProvider._({
    required ExerciseByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'exerciseByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$exerciseByIdHash();

  @override
  String toString() {
    return r'exerciseByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Exercise?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Exercise?> create(Ref ref) {
    final argument = this.argument as String;
    return exerciseById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExerciseByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$exerciseByIdHash() => r'0744b1a73bba252a8a983ebd621a97a3489b89fe';

final class ExerciseByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Exercise?>, String> {
  ExerciseByIdFamily._()
    : super(
        retry: null,
        name: r'exerciseByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ExerciseByIdProvider call(String id) =>
      ExerciseByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'exerciseByIdProvider';
}
