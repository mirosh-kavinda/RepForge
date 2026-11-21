import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/core/metrics/units.dart';
import 'package:repforge/features/onboarding/domain/answer_validation.dart';
import 'package:repforge/features/onboarding/domain/onboarding_answers.dart';

void main() {
  final today = DateTime(2026, 11, 21);
  const base = OnboardingAnswers(units: UnitSystem.metric);

  group('ONB-01 answer validation', () {
    test('AC3 AC4 everything but units may be left empty', () {
      expect(invalidAnswers(base, today: today), isEmpty);
    });

    test('AC5 plausible values pass, range edges included', () {
      final a = base.copyWith(birthYear: 2013, heightCm: 100, weightKg: 350);
      expect(invalidAnswers(a, today: today), isEmpty);
      final b = base.copyWith(birthYear: 1926, heightCm: 250, weightKg: 25);
      expect(invalidAnswers(b, today: today), isEmpty);
    });

    test('AC5 each out-of-range field is named', () {
      final a = base.copyWith(birthYear: 2020, heightCm: 99, weightKg: 351);
      expect(invalidAnswers(a, today: today), {
        AnswerField.birthYear,
        AnswerField.height,
        AnswerField.weight,
      });
      expect(invalidAnswers(base.copyWith(birthYear: 1900), today: today), {
        AnswerField.birthYear,
      });
    });
  });
}
