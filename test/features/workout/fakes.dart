import 'dart:async';

import 'package:repforge/features/library/domain/exercise.dart';
import 'package:repforge/features/library/domain/exercise_catalog_repository.dart';
import 'package:repforge/features/library/domain/exercise_query.dart';
import 'package:repforge/features/workout/domain/template_repository.dart';
import 'package:repforge/features/workout/domain/workout_template.dart';

class FakeTemplateRepository implements TemplateRepository {
  FakeTemplateRepository([List<WorkoutTemplate> initial = const []]) {
    for (final t in initial) {
      _all[t.id] = t;
    }
  }

  final _all = <String, WorkoutTemplate>{};
  final _deleted = <String>{};
  final _changes = StreamController<void>.broadcast();
  final saved = <WorkoutTemplate>[];
  var startersCalls = 0;
  Object? failSaveWith;

  List<WorkoutTemplate> get active {
    final list = [
      for (final t in _all.values)
        if (!_deleted.contains(t.id)) t,
    ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  @override
  Stream<List<WorkoutTemplate>> watchAll() async* {
    yield active;
    await for (final _ in _changes.stream) {
      yield active;
    }
  }

  @override
  Future<WorkoutTemplate?> byId(String id) async =>
      _deleted.contains(id) ? null : _all[id];

  @override
  Future<void> save(WorkoutTemplate t) async {
    if (failSaveWith case final e?) throw e;
    _all[t.id] = t;
    saved.add(t);
    _changes.add(null);
  }

  @override
  Future<void> delete(String id) async {
    _deleted.add(id);
    _changes.add(null);
  }

  @override
  Future<void> restore(String id) async {
    _deleted.remove(id);
    _changes.add(null);
  }

  @override
  Future<void> ensureStarters() async => startersCalls++;
}

Exercise fakeExercise(String id, String name, List<Muscle> muscles) => Exercise(
  id: id,
  name: name,
  primaryMuscles: muscles,
  secondaryMuscles: const [],
  equipment: Equipment.barbell,
  category: ExerciseCategory.strength,
  level: ExerciseLevel.beginner,
  instructions: const [],
  images: const [],
);

final fakeCatalogExercises = [
  fakeExercise('Barbell_Squat', 'Barbell Squat', [
    Muscle.quadriceps,
    Muscle.glutes,
  ]),
  fakeExercise('Leg_Press', 'Leg Press', [Muscle.quadriceps]),
  fakeExercise('Romanian_Deadlift', 'Romanian Deadlift', [Muscle.hamstrings]),
  fakeExercise('Plank', 'Plank', [Muscle.abdominals]),
];

class FakeCatalog implements ExerciseCatalogRepository {
  @override
  Future<Exercise?> byId(String id) async =>
      fakeCatalogExercises.where((e) => e.id == id).firstOrNull;

  @override
  Future<List<Exercise>> search(ExerciseQuery q) async => [
    for (final e in fakeCatalogExercises)
      if (e.name.toLowerCase().contains(q.text.toLowerCase().trim())) e,
  ];
}
