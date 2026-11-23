import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/features/library/data/exercise_images.dart';

import '../../../../tool/seed/seed_builder.dart';

void main() {
  test('EXL-02 AC6 picture URLs point at the pinned catalog source', () {
    final url = exerciseImageUrl('3_4_Sit-Up/0.jpg');
    expect(
      url.toString(),
      'https://raw.githubusercontent.com/yuhonas/free-exercise-db/'
      '$seedSourceCommit/exercises/3_4_Sit-Up/0.jpg',
    );
  });
}
