import 'package:repforge/features/progress/data/providers.dart';

class FakeProgressPrefs implements ProgressPrefs {
  String? saved;

  @override
  Future<String?> exercise() async => saved;

  @override
  Future<void> setExercise(String id) async => saved = id;
}
