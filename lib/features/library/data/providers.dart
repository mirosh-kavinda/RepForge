import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/local/database_provider.dart';
import '../domain/custom_exercise_repository.dart';
import '../domain/exercise.dart';
import '../domain/exercise_catalog_repository.dart';
import 'catalog_importer.dart';
import 'combined_catalog.dart';
import 'drift_custom_exercise_repository.dart';
import 'drift_exercise_catalog_repository.dart';

part 'providers.g.dart';

const seedAsset = 'assets/exercises/seed.json';

@Riverpod(keepAlive: true)
Future<String> Function() seedLoader(Ref ref) =>
    () => rootBundle.loadString(seedAsset, cache: false);

// No in-session retry: a corrupt bundled seed fails the same way every time, and
// Riverpod's default retry would leave the catalog loading forever instead of
// reporting the error. The next launch retries.
Duration? _noRetry(int retryCount, Object error) => null;

@Riverpod(keepAlive: true, retry: _noRetry)
Future<ImportResult> catalogImport(Ref ref) => CatalogImporter(
  ref.watch(appDatabaseProvider),
  loadSeed: ref.watch(seedLoaderProvider),
).run();

@Riverpod(keepAlive: true)
Future<ExerciseCatalogRepository> exerciseCatalog(Ref ref) async {
  await ref.watch(catalogImportProvider.future);
  return CombinedCatalog(
    DriftExerciseCatalogRepository(ref.watch(appDatabaseProvider)),
    ref.watch(customExerciseRepositoryProvider),
  );
}

// EXL-03.
@Riverpod(keepAlive: true)
CustomExerciseRepository customExerciseRepository(Ref ref) =>
    DriftCustomExerciseRepository(ref.watch(appDatabaseProvider));

// EXL-03: my active exercises; screens rerun their search when it changes.
@riverpod
Stream<List<Exercise>> customExercises(Ref ref) =>
    ref.watch(customExerciseRepositoryProvider).watchAll();

void startCatalogImport(ProviderContainer container) =>
    container.read(catalogImportProvider);

// EXL-02 AC5: one catalog exercise; null when not in the catalog.
@riverpod
Future<Exercise?> exerciseById(Ref ref, String id) async {
  // Refresh after an edit of a custom exercise (EXL-03 AC6).
  ref.watch(customExercisesProvider);
  return (await ref.watch(exerciseCatalogProvider.future)).byId(id);
}
