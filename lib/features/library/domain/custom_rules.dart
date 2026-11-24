import 'exercise.dart';
import 'exercise_query.dart';

abstract final class CustomLimits {
  static const nameMax = 40;
  static const notesMax = 1000;
}

// AC2: trimmed with inner spaces collapsed; null when empty or too long.
String? cleanExerciseName(String raw) {
  final s = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
  return s.isEmpty || s.length > CustomLimits.nameMax ? null : s;
}

// AC2: two names clash when their keys are equal.
String nameKey(String name) =>
    name.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

bool canSaveCustom(String name, Set<Muscle> primary) =>
    cleanExerciseName(name) != null && primary.isNotEmpty;

List<String> _words(String text) => text
    .toLowerCase()
    .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
    .where((w) => w.isNotEmpty)
    .toList();

// AC3: the catalog's FTS rule (every query word is a prefix of a name word),
// muscles matching main or other muscles, equipment exact.
bool matchesQuery(Exercise e, ExerciseQuery q) {
  final names = _words(e.name);
  for (final w in _words(q.text)) {
    if (!names.any((n) => n.startsWith(w))) return false;
  }
  if (q.muscles.isNotEmpty &&
      ![...e.primaryMuscles, ...e.secondaryMuscles].any(q.muscles.contains)) {
    return false;
  }
  if (q.equipment.isNotEmpty && !q.equipment.contains(e.equipment)) {
    return false;
  }
  if (q.levels.isNotEmpty || q.categories.isNotEmpty) return false;
  return true;
}
