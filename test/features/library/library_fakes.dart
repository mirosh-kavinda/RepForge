import 'package:repforge/features/library/domain/exercise.dart';
import 'package:repforge/features/library/domain/exercise_catalog_repository.dart';
import 'package:repforge/features/library/domain/exercise_query.dart';

Exercise ex(
  String id,
  String name,
  List<Muscle> primary, {
  List<Muscle> secondary = const [],
  Equipment equipment = Equipment.barbell,
  List<String> images = const [],
  List<String> instructions = const [],
}) => Exercise(
  id: id,
  name: name,
  primaryMuscles: primary,
  secondaryMuscles: secondary,
  equipment: equipment,
  category: ExerciseCategory.strength,
  level: ExerciseLevel.intermediate,
  instructions: instructions,
  images: images,
);

final libraryExercises = [
  ex(
    'Barbell_Squat',
    'Barbell Squat',
    [Muscle.quadriceps],
    secondary: [Muscle.glutes, Muscle.hamstrings],
    images: ['Barbell_Squat/0.jpg', 'Barbell_Squat/1.jpg'],
    instructions: ['Set the bar on your back.', 'Squat down, then stand up.'],
  ),
  ex('Bench_Press', 'Bench Press', [Muscle.chest]),
  ex('Plank', 'Plank', [Muscle.abdominals], equipment: Equipment.bodyOnly),
  ex('Leg_Press', 'Leg Press', [
    Muscle.quadriceps,
  ], equipment: Equipment.machine),
];

// Reachable by id only, so the Library's lists stay as above.
final detailOnly = [
  ex(
    'Long',
    'Single-Arm Dumbbell Incline Bench Press With Rotation Hold',
    [Muscle.chest],
    equipment: Equipment.dumbbell,
  ),
];

// Honours text, muscles and equipment like the Drift catalog, A–Z.
class LibraryCatalog implements ExerciseCatalogRepository {
  @override
  Future<Exercise?> byId(String id) async =>
      [...libraryExercises, ...detailOnly].where((e) => e.id == id).firstOrNull;

  @override
  Future<List<Exercise>> search(ExerciseQuery q) async {
    final text = q.text.toLowerCase().trim();
    return [
      for (final e in libraryExercises)
        if (e.name.toLowerCase().contains(text) &&
            (q.muscles.isEmpty ||
                [
                  ...e.primaryMuscles,
                  ...e.secondaryMuscles,
                ].any(q.muscles.contains)) &&
            (q.equipment.isEmpty || q.equipment.contains(e.equipment)))
          e,
    ]..sort((a, b) => a.name.compareTo(b.name));
  }
}
