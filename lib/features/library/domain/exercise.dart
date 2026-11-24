import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise.freezed.dart';

T _fromKey<T extends Enum>(List<T> values, String Function(T) key, String k) =>
    values.firstWhere(
      (v) => key(v) == k,
      orElse: () => throw ArgumentError.value(k, 'key'),
    );

enum Muscle {
  chest('chest'),
  shoulders('shoulders'),
  triceps('triceps'),
  biceps('biceps'),
  forearms('forearms'),
  lats('lats'),
  middleBack('middle back'),
  lowerBack('lower back'),
  traps('traps'),
  abdominals('abdominals'),
  quadriceps('quadriceps'),
  hamstrings('hamstrings'),
  glutes('glutes'),
  calves('calves'),
  adductors('adductors'),
  abductors('abductors'),
  neck('neck');

  const Muscle(this.key);
  final String key;
  static Muscle fromKey(String k) => _fromKey(values, (v) => v.key, k);
}

enum Equipment {
  barbell('barbell'),
  dumbbell('dumbbell'),
  cable('cable'),
  machine('machine'),
  kettlebell('kettlebell'),
  bands('bands'),
  bodyOnly('body only'),
  ezBar('EZ bar'),
  smithMachine('smith machine'),
  other('other');

  const Equipment(this.key);
  final String key;
  static Equipment fromKey(String k) => _fromKey(values, (v) => v.key, k);
}

enum ExerciseCategory {
  strength('strength'),
  powerlifting('powerlifting'),
  olympicWeightlifting('olympic weightlifting'),
  strongman('strongman'),
  plyometrics('plyometrics'),
  stretching('stretching'),
  cardio('cardio');

  const ExerciseCategory(this.key);
  final String key;
  static ExerciseCategory fromKey(String k) =>
      _fromKey(values, (v) => v.key, k);
}

enum ExerciseLevel {
  beginner('beginner'),
  intermediate('intermediate'),
  expert('expert');

  const ExerciseLevel(this.key);
  final String key;
  static ExerciseLevel fromKey(String k) => _fromKey(values, (v) => v.key, k);
}

enum Mechanic {
  compound('compound'),
  isolation('isolation');

  const Mechanic(this.key);
  final String key;
  static Mechanic fromKey(String k) => _fromKey(values, (v) => v.key, k);
}

enum Force {
  push('push'),
  pull('pull'),
  static('static');

  const Force(this.key);
  final String key;
  static Force fromKey(String k) => _fromKey(values, (v) => v.key, k);
}

@freezed
abstract class Exercise with _$Exercise {
  const factory Exercise({
    required String id,
    required String name,
    required List<Muscle> primaryMuscles,
    required List<Muscle> secondaryMuscles,
    required Equipment equipment,
    required ExerciseCategory category,
    required ExerciseLevel level,
    required List<String> instructions,
    required List<String> images,
    Mechanic? mechanic,
    Force? force,
    // EXL-03: made by the user; [notes] stands in for instructions.
    @Default(false) bool custom,
    String? notes,
  }) = _Exercise;
}
