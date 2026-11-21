import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/core/metrics/strength.dart';

void main() {
  group('FND-04 strength', () {
    test('AC6 Epley for 2–12 reps', () {
      expect(e1rm(const LoggedSet(kg: 100, reps: 5)), closeTo(116.67, 0.01));
      expect(e1rm(const LoggedSet(kg: 60, reps: 12)), closeTo(84, 0.001));
    });

    test('AC6 a single is its own 1RM', () {
      expect(e1rm(const LoggedSet(kg: 140, reps: 1)), 140);
    });

    test('AC6 warm-ups, > 12 reps and zero sets give no e1RM', () {
      expect(e1rm(const LoggedSet(kg: 60, reps: 5, warmup: true)), isNull);
      expect(e1rm(const LoggedSet(kg: 50, reps: 13)), isNull);
      expect(e1rm(const LoggedSet(kg: 0, reps: 10)), isNull);
      expect(e1rm(const LoggedSet(kg: 100, reps: 0)), isNull);
    });

    test('AC6 best e1RM picks the highest eligible set', () {
      expect(
        bestE1rm(const [
          LoggedSet(kg: 200, reps: 3, warmup: true),
          LoggedSet(kg: 100, reps: 5),
          LoggedSet(kg: 110, reps: 2),
          LoggedSet(kg: 80, reps: 20),
        ]),
        closeTo(117.33, 0.01),
      );
      expect(bestE1rm(const []), isNull);
      expect(bestE1rm(const [LoggedSet(kg: 50, reps: 15)]), isNull);
    });

    test('AC7 volume sums working sets only', () {
      expect(
        volume(const [
          LoggedSet(kg: 60, reps: 10, warmup: true),
          LoggedSet(kg: 100, reps: 5),
          LoggedSet(kg: 100, reps: 5),
          LoggedSet(kg: 80, reps: 20),
          LoggedSet(kg: 0, reps: 10),
        ]),
        2600,
      );
      expect(volume(const []), 0);
    });
  });
}
