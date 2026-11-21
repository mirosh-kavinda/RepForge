import '../domain/workout_template.dart';

typedef _Row = (String exerciseId, int sets, int repMin, int repMax, int rest);

WorkoutTemplate _starter(String name, List<_Row> rows) => WorkoutTemplate(
  id: '',
  name: name,
  exercises: [
    for (final (exerciseId, sets, repMin, repMax, rest) in rows)
      TemplateExercise(
        id: '',
        exerciseId: exerciseId,
        sets: sets,
        repMin: repMin,
        repMax: repMax,
        restSec: rest,
      ),
  ],
);

// AC12. Ids are catalog ids from assets/exercises/seed.json; row and workout
// ids are made when seeded. starter_templates_test checks every id exists.
final starterTemplates = [
  _starter('Push', [
    ('Barbell_Bench_Press_-_Medium_Grip', 4, 5, 8, 180),
    ('Incline_Dumbbell_Press', 3, 8, 10, 120),
    ('Seated_Dumbbell_Press', 3, 8, 10, 120),
    ('Side_Lateral_Raise', 3, 12, 15, 60),
    ('Triceps_Pushdown', 3, 10, 12, 60),
    ('Dips_-_Triceps_Version', 2, 8, 12, 90),
  ]),
  _starter('Pull', [
    ('Barbell_Deadlift', 3, 3, 5, 180),
    ('Pullups', 3, 6, 10, 120),
    ('Bent_Over_Barbell_Row', 3, 8, 10, 120),
    ('Face_Pull', 3, 12, 15, 60),
    ('Dumbbell_Bicep_Curl', 3, 10, 12, 60),
    ('Hammer_Curls', 2, 10, 12, 60),
  ]),
  _starter('Legs', [
    ('Barbell_Squat', 4, 5, 8, 180),
    ('Romanian_Deadlift', 3, 8, 10, 150),
    ('Leg_Press', 3, 10, 12, 120),
    ('Lying_Leg_Curls', 3, 10, 12, 90),
    ('Standing_Calf_Raises', 4, 10, 15, 60),
  ]),
  _starter('Upper', [
    ('Barbell_Bench_Press_-_Medium_Grip', 4, 6, 8, 180),
    ('Bent_Over_Barbell_Row', 4, 6, 8, 150),
    ('Seated_Dumbbell_Press', 3, 8, 10, 120),
    ('Wide-Grip_Lat_Pulldown', 3, 8, 12, 90),
    ('Dumbbell_Bicep_Curl', 2, 10, 12, 60),
    ('Triceps_Pushdown', 2, 10, 12, 60),
  ]),
  _starter('Lower', [
    ('Barbell_Squat', 4, 6, 8, 180),
    ('Romanian_Deadlift', 3, 8, 10, 150),
    ('Dumbbell_Lunges', 3, 10, 12, 90),
    ('Leg_Extensions', 3, 12, 15, 60),
    ('Lying_Leg_Curls', 3, 10, 12, 60),
    ('Standing_Calf_Raises', 3, 12, 15, 60),
  ]),
  _starter('Full Body', [
    ('Barbell_Squat', 3, 6, 8, 150),
    ('Barbell_Bench_Press_-_Medium_Grip', 3, 6, 8, 150),
    ('Bent_Over_Barbell_Row', 3, 8, 10, 120),
    ('Seated_Dumbbell_Press', 3, 8, 10, 90),
    ('Romanian_Deadlift', 3, 8, 10, 120),
  ]),
];
