import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/features/library/domain/custom_rules.dart';
import 'package:repforge/features/library/domain/exercise.dart';
import 'package:repforge/features/library/domain/exercise_query.dart';

const hack = Exercise(
  id: 'c1',
  name: 'Hack-Squat (Gym 2)',
  primaryMuscles: [Muscle.quadriceps],
  secondaryMuscles: [Muscle.glutes],
  equipment: Equipment.machine,
  category: ExerciseCategory.strength,
  level: ExerciseLevel.beginner,
  instructions: [],
  images: [],
  custom: true,
);

void main() {
  group('EXL-03 custom rules', () {
    test('AC2 names are trimmed, spaces collapsed, 1–40 characters', () {
      expect(cleanExerciseName('  Hack   Squat '), 'Hack Squat');
      expect(cleanExerciseName('   '), isNull);
      expect(cleanExerciseName('x' * 40), hasLength(40));
      expect(cleanExerciseName('x' * 41), isNull);
    });

    test('AC2 clash keys ignore case and spacing', () {
      expect(nameKey(' Hack  SQUAT'), nameKey('hack squat'));
      expect(nameKey('Hack Squat'), isNot(nameKey('Hack Squats 2')));
    });

    test('AC2 save needs a name and a main muscle', () {
      expect(canSaveCustom('Hack', {Muscle.quadriceps}), isTrue);
      expect(canSaveCustom('Hack', {}), isFalse);
      expect(canSaveCustom(' ', {Muscle.quadriceps}), isFalse);
    });

    test('AC3 word prefixes, any order, punctuation ignored', () {
      expect(matchesQuery(hack, const ExerciseQuery(text: 'squ hac')), isTrue);
      expect(matchesQuery(hack, const ExerciseQuery(text: 'gym 2')), isTrue);
      expect(matchesQuery(hack, const ExerciseQuery(text: 'quat')), isFalse);
      expect(matchesQuery(hack, const ExerciseQuery()), isTrue);
    });

    test('AC3 muscles match main or other; equipment exact', () {
      expect(
        matchesQuery(hack, const ExerciseQuery(muscles: {Muscle.glutes})),
        isTrue,
      );
      expect(
        matchesQuery(hack, const ExerciseQuery(muscles: {Muscle.chest})),
        isFalse,
      );
      expect(
        matchesQuery(hack, const ExerciseQuery(equipment: {Equipment.barbell})),
        isFalse,
      );
    });
  });
}
