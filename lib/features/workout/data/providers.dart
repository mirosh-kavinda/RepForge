import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/local/database_provider.dart';
import '../../library/data/providers.dart';
import '../../library/domain/exercise.dart';
import '../domain/template_repository.dart';
import '../domain/template_rules.dart';
import '../domain/workout_template.dart';
import 'drift_template_repository.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
TemplateRepository templateRepository(Ref ref) =>
    DriftTemplateRepository(ref.watch(appDatabaseProvider));

// Seeds the starters on first read (AC12), then follows changes.
@riverpod
Stream<List<WorkoutTemplate>> templates(Ref ref) async* {
  final repo = ref.watch(templateRepositoryProvider);
  await repo.ensureStarters();
  yield* repo.watchAll();
}

// Primary muscles of one workout, for cycle day rows (SCH-01 AC1).
@riverpod
Future<List<Muscle>> workoutMuscles(Ref ref, String workoutId) async {
  final all = await ref.watch(templatesProvider.future);
  final w = all.where((t) => t.id == workoutId).firstOrNull;
  if (w == null) return const [];
  final catalog = await ref.watch(exerciseCatalogProvider.future);
  final found = <String, Exercise>{};
  for (final id in {for (final e in w.exercises) e.exerciseId}) {
    if (await catalog.byId(id) case final e?) found[id] = e;
  }
  return primaryMuscles(w.exercises, found);
}
