import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/metrics/body.dart';
import '../../../core/metrics/energy.dart';
import '../../../core/metrics/units.dart';

part 'onboarding_answers.freezed.dart';

enum TrainingGoal { buildMuscle, getStronger, loseFat, stayConsistent }

enum TrainingLevel { beginner, intermediate, advanced }

// Metric values only; the form converts Imperial input before building this.
@freezed
abstract class OnboardingAnswers with _$OnboardingAnswers {
  const factory OnboardingAnswers({
    required UnitSystem units,
    TrainingGoal? goal,
    TrainingLevel? level,
    Sex? sex,
    int? birthYear,
    double? heightCm,
    double? weightKg,
    double? waistCm,
    ActivityLevel? activity,
  }) = _OnboardingAnswers;
}
