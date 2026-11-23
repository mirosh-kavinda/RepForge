import '../../../app/l10n/generated/app_localizations.dart';
import '../domain/exercise.dart';
import '../domain/exercise_catalog_repository.dart';
import '../domain/exercise_query.dart';
import 'muscle_groups.dart';
import 'search_terms.dart';

// The picker's and the Library's search (WKT-01 AC3, EXL-01 AC2–AC3): words
// naming a muscle or equipment narrow the filters instead of matching names.
Future<List<Exercise>> runSearch(
  ExerciseCatalogRepository repo,
  AppLocalizations l10n, {
  required String text,
  MuscleGroup? group,
  Equipment? equipment,
}) async {
  final terms = parseSearchTerms(text, l10n);
  final muscles = narrow(group?.muscles ?? const <Muscle>{}, terms.muscles);
  final kit = narrow(<Equipment>{?equipment}, terms.equipment);
  if (muscles == null || kit == null) return const [];
  return repo.search(
    ExerciseQuery(text: terms.text, muscles: muscles, equipment: kit),
  );
}
