import 'dart:math' as math;

import '../../../core/metrics/units.dart';
import '../../library/domain/exercise.dart';
import '../../workout/domain/workout_template.dart';
import 'workout_session.dart';

typedef SetValues = ({double kg, int? reps, int? seconds});

SetValues _of(LoggedSet s) => (kg: s.kg, reps: s.reps, seconds: s.seconds);

// LOG-01 AC2, AC4, LOG-02 AC5: the suggested target from last time, else the
// last set logged in this row now, else the template's target.
SetValues prefill(
  SessionExercise row,
  int setNo, {
  required List<LoggedSet> loggedInRow,
  required Map<int, SetValues> targets,
}) {
  if (targets[setNo] case final t?) return t;
  final earlier = [
    for (final s in loggedInRow)
      if (s.setNo < setNo) s,
  ]..sort((a, b) => a.setNo.compareTo(b.setNo));
  if (earlier.isNotEmpty) return _of(earlier.last);
  final timed = row.kind == TargetKind.time;
  return (
    kg: row.targetKg ?? 0,
    reps: timed ? null : row.repMin,
    seconds: timed ? row.seconds : null,
  );
}

// AC6: a row shows its planned sets, or more if more were logged.
int setCount(SessionExercise row, List<LoggedSet> loggedInRow) =>
    loggedInRow.fold(row.plannedSets, (n, s) => math.max(n, s.setNo));

const _kgStep = 2.5;
const _lbStep = 5.0;

// What the user sees: kg to 0.01, lb to 0.1, so a lb value entered or
// stepped to comes back unchanged (edge).
double displayWeight(double kg, UnitSystem units) => switch (units) {
  UnitSystem.metric => (kg * 100).round() / 100,
  UnitSystem.imperial => (kgToLb(kg) * 10).round() / 10,
};

// AC3: the weight step in the user's unit; reps and seconds step 1.
double weightStep(UnitSystem units) =>
    units == UnitSystem.metric ? _kgStep : _lbStep;

const countStep = 1.0;

List<SessionExercise> addSet(List<SessionExercise> rows, String rowId) => [
  for (final r in rows)
    r.id == rowId ? r.copyWith(plannedSets: r.plannedSets + 1) : r,
];

SessionExercise _row(String id, Exercise e, {int sets = 3}) => SessionExercise(
  id: id,
  exerciseId: e.id,
  name: e.name,
  plannedSets: sets,
  bodyweight: e.equipment == Equipment.bodyOnly,
);

// AC7: at the end, 3 sets, template defaults.
List<SessionExercise> addExercise(
  List<SessionExercise> rows,
  Exercise e,
  String id,
) => [...rows, _row(id, e)];

// AC7: sets not logged yet move to [e]. With [logged] sets on the row, the
// row keeps them under its old exercise and a new row takes the rest.
List<SessionExercise> swapExercise(
  List<SessionExercise> rows,
  String rowId,
  Exercise e, {
  required int logged,
  required String newId,
}) => [
  for (final r in rows)
    if (r.id != rowId)
      r
    else if (logged == 0)
      _row(r.id, e, sets: r.plannedSets)
    else ...[
      r.copyWith(plannedSets: logged),
      _row(newId, e, sets: math.max(1, r.plannedSets - logged)),
    ],
];

// WKT-02 AC1: a copy of the template's rows with exercise names, so later
// template or library changes don't touch the workout (edge).
WorkoutSession sessionFromTemplate({
  required String id,
  required WorkoutTemplate template,
  required Map<String, Exercise> exercises,
  required DateTime date,
  required DateTime startedAt,
  String? cycleId,
  String? dayId,
  int? dayIndex,
}) => WorkoutSession(
  id: id,
  name: template.name,
  templateId: template.id,
  date: date,
  startedAt: startedAt,
  cycleId: cycleId,
  dayId: dayId,
  dayIndex: dayIndex,
  exercises: [
    for (final t in template.exercises)
      SessionExercise(
        id: t.id,
        exerciseId: t.exerciseId,
        name:
            exercises[t.exerciseId]?.name ?? t.exerciseId.replaceAll('_', ' '),
        plannedSets: t.sets,
        kind: t.kind,
        repMin: t.repMin,
        repMax: t.repMax,
        seconds: t.seconds,
        targetKg: t.targetKg,
        bodyweight: exercises[t.exerciseId]?.equipment == Equipment.bodyOnly,
      ),
  ],
);
