import 'exercise.dart';
import 'exercise_query.dart';

abstract interface class ExerciseCatalogRepository {
  Future<List<Exercise>> search(ExerciseQuery query);

  Future<Exercise?> byId(String id);
}
