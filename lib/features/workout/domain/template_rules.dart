import '../../../core/ids.dart';
import '../../../core/metrics/units.dart';
import '../../library/domain/exercise.dart';
import 'workout_template.dart';

abstract final class TemplateLimits {
  static const nameMax = 40;
  static const maxExercises = 30;
  static const setsMin = 1;
  static const setsMax = 10;
  static const repsMin = 1;
  static const repsMax = 100;
  static const secondsMin = 5;
  static const secondsMax = 600;
  static const secondsStep = 5;
  static const restMax = 600;
  static const restStep = 15;
  static const weightMaxKg = 500.0;
  static const workSeconds = 40;
}

const _letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

String? cleanName(String raw) {
  final name = raw.trim();
  return name.isEmpty || name.length > TemplateLimits.nameMax ? null : name;
}

bool canSave(String name, List<TemplateExercise> exercises) =>
    cleanName(name) != null &&
    exercises.isNotEmpty &&
    exercises.length <= TemplateLimits.maxExercises;

int remainingSlots(List<TemplateExercise> exercises) =>
    TemplateLimits.maxExercises - exercises.length;

TemplateExercise newEntry(String exerciseId) =>
    TemplateExercise(id: newId(), exerciseId: exerciseId);

List<TemplateExercise> append(
  List<TemplateExercise> list,
  List<String> exerciseIds,
) => [...list, ...exerciseIds.take(remainingSlots(list)).map(newEntry)];

// Any group that is no longer one contiguous run of 2+ rows is dissolved.
List<TemplateExercise> normalizeSupersets(List<TemplateExercise> list) {
  final runs = <String, int>{};
  final counts = <String, int>{};
  String? previous;
  for (final e in list) {
    final s = e.superset;
    if (s != null) {
      counts[s] = (counts[s] ?? 0) + 1;
      if (s != previous) runs[s] = (runs[s] ?? 0) + 1;
    }
    previous = s;
  }
  final broken = {
    for (final s in counts.keys)
      if (counts[s]! < 2 || runs[s]! > 1) s,
  };
  if (broken.isEmpty) return list;
  return [
    for (final e in list)
      broken.contains(e.superset) ? e.copyWith(superset: null) : e,
  ];
}

bool isContiguous(Set<int> indices) {
  if (indices.isEmpty) return false;
  final sorted = indices.toList()..sort();
  return sorted.last - sorted.first == sorted.length - 1;
}

bool canLink(List<TemplateExercise> list, Set<int> indices) =>
    indices.length >= 2 &&
    isContiguous(indices) &&
    indices.every((i) => i >= 0 && i < list.length);

List<TemplateExercise> link(List<TemplateExercise> list, Set<int> indices) {
  if (!canLink(list, indices)) return list;
  final usedElsewhere = {
    for (final (i, e) in list.indexed)
      if (!indices.contains(i) && e.superset != null) e.superset!,
  };
  final letter = _letters
      .split('')
      .firstWhere((l) => !usedElsewhere.contains(l));
  return normalizeSupersets([
    for (final (i, e) in list.indexed)
      indices.contains(i) ? e.copyWith(superset: letter) : e,
  ]);
}

List<TemplateExercise> unlink(List<TemplateExercise> list, int index) {
  final group = list[index].superset;
  if (group == null) return list;
  return [
    for (final e in list) e.superset == group ? e.copyWith(superset: null) : e,
  ];
}

// `to` is the row's final index.
List<TemplateExercise> move(List<TemplateExercise> list, int from, int to) {
  if (from == to || to < 0 || to >= list.length) return list;
  final next = [...list];
  final row = next.removeAt(from);
  next.insert(to, row);
  return normalizeSupersets(next);
}

List<TemplateExercise> removeAt(List<TemplateExercise> list, int index) =>
    normalizeSupersets([...list]..removeAt(index));

List<TemplateExercise> replaceAt(
  List<TemplateExercise> list,
  int index,
  TemplateExercise entry,
) => [...list]..[index] = entry;

// AC7: members other than the last rest 0; the stored rest is kept for unlinking.
bool restsInsideSuperset(List<TemplateExercise> list, int index) {
  final s = list[index].superset;
  return s != null && index + 1 < list.length && list[index + 1].superset == s;
}

int effectiveRest(List<TemplateExercise> list, int index) =>
    restsInsideSuperset(list, index) ? 0 : list[index].restSec;

int totalSets(List<TemplateExercise> list) =>
    list.fold(0, (sum, e) => sum + e.sets);

int estimateMinutes(List<TemplateExercise> list) {
  var seconds = 0;
  for (final (i, e) in list.indexed) {
    final work = e.kind == TargetKind.time
        ? e.seconds
        : TemplateLimits.workSeconds;
    seconds += e.sets * (work + effectiveRest(list, i));
  }
  final minutes = ((seconds / 60) / 5).round() * 5;
  return minutes < 5 ? 5 : minutes;
}

List<Muscle> primaryMuscles(
  List<TemplateExercise> list,
  Map<String, Exercise> catalog,
) => {for (final e in list) ...?catalog[e.exerciseId]?.primaryMuscles}.toList();

String copyName(String name) {
  const suffix = ' (copy)';
  const room = TemplateLimits.nameMax - suffix.length;
  final base = name.length > room ? name.substring(0, room).trimRight() : name;
  return '$base$suffix';
}

TemplateExercise withOrderedRange(TemplateExercise e) =>
    e.repMin > e.repMax ? e.copyWith(repMin: e.repMax, repMax: e.repMin) : e;

WorkoutTemplate forSave({
  required String id,
  required String name,
  required List<TemplateExercise> exercises,
}) => WorkoutTemplate(
  id: id,
  name: name.trim(),
  exercises: normalizeSupersets(exercises.map(withOrderedRange).toList()),
);

enum WeightError { unreadable, outOfRange }

// Blank means no target; lb converts to kg rounded to 0.01.
({double? kg, WeightError? error}) parseWeight(String text, MassUnit unit) {
  final t = text.trim().replaceAll(',', '.');
  if (t.isEmpty) return (kg: null, error: null);
  final value = double.tryParse(t);
  if (value == null) return (kg: null, error: WeightError.unreadable);
  final kg = unit == MassUnit.kg ? value : (lbToKg(value) * 100).round() / 100;
  if (kg < 0 || kg > TemplateLimits.weightMaxKg) {
    return (kg: null, error: WeightError.outOfRange);
  }
  return (kg: kg, error: null);
}
