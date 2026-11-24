import 'package:freezed_annotation/freezed_annotation.dart';

import '../../workout/domain/workout_template.dart';

part 'workout_session.freezed.dart';

// One exercise row of a workout, copied from the template at start so later
// template or library changes don't touch it (WKT-02 edge).
@freezed
abstract class SessionExercise with _$SessionExercise {
  const factory SessionExercise({
    required String id,
    required String exerciseId,
    required String name,
    @Default(3) int plannedSets,
    @Default(TargetKind.reps) TargetKind kind,
    @Default(8) int repMin,
    @Default(12) int repMax,
    @Default(45) int seconds,
    double? targetKg,
    // "Body only" equipment: 0 kg reads Bodyweight (edge).
    @Default(false) bool bodyweight,
    // LOG-03: rest after its sets, and the superset group it belongs to.
    @Default(120) int restSec,
    String? superset,
  }) = _SessionExercise;
}

@freezed
abstract class LoggedSet with _$LoggedSet {
  const factory LoggedSet({
    required String id,
    // The SessionExercise row it belongs to.
    required String rowId,
    required String exerciseId,
    // 1-based within its row.
    required int setNo,
    required double kg,
    int? reps,
    int? seconds,
    // LOG-02: stored at Finish; worked out on screen while in progress.
    @Default(false) bool isPr,
  }) = _LoggedSet;
}

@freezed
abstract class WorkoutSession with _$WorkoutSession {
  const WorkoutSession._();

  const factory WorkoutSession({
    required String id,
    required String name,
    required List<SessionExercise> exercises,
    required DateTime date,
    required DateTime startedAt,
    @Default(<LoggedSet>[]) List<LoggedSet> sets,
    String? templateId,
    // The cycle day it was started for; Finish marks it done (AC9).
    String? cycleId,
    String? dayId,
    int? dayIndex,
    DateTime? endedAt,
    // LOG-03: the rest in progress, if any (rules in rest_timer.dart).
    Rest? rest,
  }) = _WorkoutSession;

  List<LoggedSet> setsOf(String rowId) => [
    for (final s in sets)
      if (s.rowId == rowId) s,
  ]..sort((a, b) => a.setNo.compareTo(b.setNo));
}

// LOG-03. A running rest has [endsAt]; a paused one has [pausedLeftMs]. Time
// left is always worked out from the clock, so leaving the app changes
// nothing (AC6).
@freezed
abstract class Rest with _$Rest {
  const factory Rest({
    DateTime? endsAt,
    int? pausedLeftMs,
    String? nextRowId,
    int? nextSetNo,
  }) = _Rest;
}
