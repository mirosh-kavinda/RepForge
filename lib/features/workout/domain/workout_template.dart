import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_template.freezed.dart';

enum TargetKind { reps, time }

@freezed
abstract class TemplateExercise with _$TemplateExercise {
  const factory TemplateExercise({
    // Distinct per row, so the same exercise can appear twice.
    required String id,
    required String exerciseId,
    @Default(3) int sets,
    @Default(TargetKind.reps) TargetKind kind,
    @Default(8) int repMin,
    @Default(12) int repMax,
    @Default(45) int seconds,
    double? targetKg,
    @Default(120) int restSec,
    String? superset,
  }) = _TemplateExercise;
}

@freezed
abstract class WorkoutTemplate with _$WorkoutTemplate {
  const factory WorkoutTemplate({
    required String id,
    required String name,
    required List<TemplateExercise> exercises,
  }) = _WorkoutTemplate;
}
