import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/metrics/body.dart';
import '../../../core/metrics/display.dart';
import '../../../core/metrics/energy.dart';
import '../../../core/metrics/units.dart';
import '../data/providers.dart';
import '../domain/answer_validation.dart';
import '../domain/onboarding_answers.dart';

part 'onboarding_controller.freezed.dart';
part 'onboarding_controller.g.dart';

enum SexChoice { male, female, preferNot }

// What the user has typed, in the units they chose. Converted to metric
// answers only at Finish (AC6).
@freezed
abstract class OnboardingDraft with _$OnboardingDraft {
  const OnboardingDraft._();

  const factory OnboardingDraft({
    required UnitSystem units,
    TrainingGoal? goal,
    TrainingLevel? level,
    SexChoice? sex,
    @Default('') String birthYear,
    @Default('') String height,
    @Default('') String heightInches,
    @Default('') String weight,
    @Default('') String waist,
    ActivityLevel? activity,
    // Set when a unit switch re-expresses a value; cleared when the field is
    // edited, so switching back and forth never drifts what was typed.
    double? exactHeightCm,
    double? exactWeightKg,
    double? exactWaistCm,
  }) = _OnboardingDraft;

  static double? _number(String text) {
    final t = text.trim().replaceAll(',', '.');
    return t.isEmpty ? null : double.tryParse(t);
  }

  static bool _blank(String text) => text.trim().isEmpty;

  // Whole feet and 0 <= inches < 12; blank fields are fine.
  bool get _validFeetInches {
    final feet = _number(height);
    final inches = _number(heightInches);
    if (feet != null && feet != feet.roundToDouble()) return false;
    return inches == null || (inches >= 0 && inches < 12);
  }

  double? get heightCm => exactHeightCm ?? _typedHeightCm;

  double? get _typedHeightCm {
    final main = _number(height);
    if (units == UnitSystem.metric) return main;
    final inches = _number(heightInches);
    if (main == null && inches == null) return null;
    return feetInchesToCm((main ?? 0).floor(), inches ?? 0);
  }

  double? get weightKg => exactWeightKg ?? _typedWeightKg;

  double? get _typedWeightKg {
    final w = _number(weight);
    if (w == null) return null;
    return units == UnitSystem.metric ? w : lbToKg(w);
  }

  double? get waistCm => exactWaistCm ?? _typedWaistCm;

  double? get _typedWaistCm {
    final w = _number(waist);
    if (w == null) return null;
    return units == UnitSystem.metric ? w : inToCm(w);
  }

  // Fields that were typed but are not numbers.
  Set<AnswerField> get unreadable => {
    if (!_blank(birthYear) && int.tryParse(birthYear.trim()) == null)
      AnswerField.birthYear,
    if ((!_blank(height) && _number(height) == null) ||
        (!_blank(heightInches) && _number(heightInches) == null) ||
        (units == UnitSystem.imperial && !_validFeetInches))
      AnswerField.height,
    if (!_blank(weight) && _number(weight) == null) AnswerField.weight,
    if (!_blank(waist) && _number(waist) == null) AnswerField.waist,
  };

  OnboardingAnswers toAnswers() => OnboardingAnswers(
    units: units,
    goal: goal,
    level: level,
    sex: switch (sex) {
      SexChoice.male => Sex.male,
      SexChoice.female => Sex.female,
      SexChoice.preferNot || null => null,
    },
    birthYear: int.tryParse(birthYear.trim()),
    heightCm: heightCm,
    weightKg: weightKg,
    waistCm: waistCm,
    activity: activity,
  );
}

String _fmt(double v) =>
    v == v.roundToDouble() ? '${v.round()}' : '${displayOneDecimal(v)}';

// Kept alive across steps so going back and forth keeps answers (AC8).
@Riverpod(keepAlive: true)
class OnboardingController extends _$OnboardingController {
  @override
  OnboardingDraft build() =>
      OnboardingDraft(units: defaultUnitSystem(ref.read(deviceRegionProvider)));

  void update(OnboardingDraft Function(OnboardingDraft d) change) =>
      state = change(state);

  // Re-expresses typed height and weight in the new units.
  void setUnits(UnitSystem units) {
    if (units == state.units) return;
    final cm = state.heightCm;
    final kg = state.weightKg;
    final waistCm = state.waistCm;
    var next = state.copyWith(
      units: units,
      height: '',
      heightInches: '',
      weight: '',
      waist: '',
      exactHeightCm: cm,
      exactWeightKg: kg,
      exactWaistCm: waistCm,
    );
    if (waistCm != null) {
      next = next.copyWith(
        waist: _fmt(units == UnitSystem.metric ? waistCm : cmToIn(waistCm)),
      );
    }
    if (cm != null) {
      if (units == UnitSystem.metric) {
        next = next.copyWith(height: _fmt(cm));
      } else {
        final fi = cmToFeetInches(cm);
        next = next.copyWith(
          height: '${fi.feet}',
          heightInches: _fmt(fi.inches),
        );
      }
    }
    if (kg != null) {
      next = next.copyWith(
        weight: _fmt(units == UnitSystem.metric ? kg : kgToLb(kg)),
      );
    }
    state = next;
  }

  // Step 2 Continue (AC5): the invalid fields; nothing is saved.
  Set<AnswerField> validate({DateTime? today}) => {
    ...state.unreadable,
    ...invalidAnswers(state.toAnswers(), today: today ?? DateTime.now()),
  };

  // Returns the invalid fields, or an empty set once saved (AC5, AC6).
  Future<Set<AnswerField>> finish({
    DateTime? today,
    Future<void> Function()? alsoWrite,
  }) async {
    final answers = state.toAnswers();
    final invalid = validate(today: today);
    if (invalid.isNotEmpty) return invalid;
    await ref
        .read(onboardingRepositoryProvider)
        .complete(answers, alsoWrite: alsoWrite);
    ref.invalidateSelf();
    return const {};
  }
}
