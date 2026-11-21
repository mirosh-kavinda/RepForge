import '../../../core/metrics/body.dart';
import '../../../core/metrics/estimate.dart';
import 'onboarding_answers.dart';

enum AnswerField { birthYear, height, weight, waist }

// AC5: optional fields are only checked when given, against FND-04's ranges.
Set<AnswerField> invalidAnswers(
  OnboardingAnswers a, {
  required DateTime today,
}) {
  final birthYear = a.birthYear;
  final heightCm = a.heightCm;
  final weightKg = a.weightKg;
  final waistCm = a.waistCm;
  return {
    if (birthYear != null &&
        !Measure.age.accepts(ageFromBirthYear(birthYear, today).toDouble()))
      AnswerField.birthYear,
    if (heightCm != null && !Measure.heightCm.accepts(heightCm))
      AnswerField.height,
    if (weightKg != null && !Measure.weightKg.accepts(weightKg))
      AnswerField.weight,
    if (waistCm != null && !Measure.waistCm.accepts(waistCm)) AnswerField.waist,
  };
}
