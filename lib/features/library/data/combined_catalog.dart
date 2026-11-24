import '../domain/custom_exercise_repository.dart';
import '../domain/custom_rules.dart';
import '../domain/exercise.dart';
import '../domain/exercise_catalog_repository.dart';
import '../domain/exercise_query.dart';

// EXL-03 AC3: the one catalog every screen sees, built-in plus my own.
class CombinedCatalog implements ExerciseCatalogRepository {
  CombinedCatalog(this._catalog, this._custom);

  final ExerciseCatalogRepository _catalog;
  final CustomExerciseRepository _custom;

  @override
  Future<List<Exercise>> search(ExerciseQuery q) async {
    final built = await _catalog.search(q);
    final mine = [
      for (final e in await _custom.watchAll().first)
        if (matchesQuery(e, q)) e,
    ];
    if (mine.isEmpty) return built;
    // Browsing: one A–Z list. Searching: my matches first, then the ranked
    // catalog hits.
    if (q.text.trim().isEmpty && q.muscles.isEmpty) {
      return [...built, ...mine]
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
    return [...mine, ...built];
  }

  // Deleted custom ones too, so old workouts keep working (AC7).
  @override
  Future<Exercise?> byId(String id) async =>
      await _catalog.byId(id) ?? await _custom.byId(id);
}
