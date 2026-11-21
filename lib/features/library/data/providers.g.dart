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

String _$exerciseCatalogHash() => r'f8c32e14449a203b113ebd2c42f8574fe75517af';
