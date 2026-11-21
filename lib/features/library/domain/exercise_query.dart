import 'package:freezed_annotation/freezed_annotation.dart';

import 'exercise.dart';

part 'exercise_query.freezed.dart';

@freezed
abstract class ExerciseQuery with _$ExerciseQuery {
  const factory ExerciseQuery({
    @Default('') String text,
    @Default(<Muscle>{}) Set<Muscle> muscles,
    @Default(<Equipment>{}) Set<Equipment> equipment,
    @Default(<ExerciseLevel>{}) Set<ExerciseLevel> levels,
    @Default(<ExerciseCategory>{}) Set<ExerciseCategory> categories,
  }) = _ExerciseQuery;

  const ExerciseQuery._();

  bool get isEmpty =>
      text.trim().isEmpty &&
      muscles.isEmpty &&
      equipment.isEmpty &&
      levels.isEmpty &&
      categories.isEmpty;
}
