import 'body.dart';
import 'estimate.dart';

enum BmrFormula { mifflinStJeor, katchMcArdle }

class Bmr {
  const Bmr(this.kcal, this.formula);

  final double kcal;
  final BmrFormula formula;

  @override
  bool operator ==(Object other) =>
      other is Bmr && other.kcal == kcal && other.formula == formula;

  @override
  int get hashCode => Object.hash(kcal, formula);

  @override
  String toString() => 'Bmr($kcal, ${formula.name})';
}

// Katch–McArdle when a body-fat % is known, else Mifflin–St Jeor (AC2).
Estimate<Bmr> bmr({
  required double weightKg,
  required double heightCm,
  required int age,
  required Sex? sex,
  Estimate<double>? bodyFat,
}) {
  final badWeight = checkRange<Bmr>(Measure.weightKg, weightKg);
  if (badWeight != null) return badWeight;

  if (bodyFat case Estimated(:final value, :final approximate)) {
    final badFat = checkRange<Bmr>(Measure.bodyFatPct, value);
    if (badFat != null) return badFat;
    final lbm = weightKg * (1 - value / 100);
    return Estimated(
      Bmr(370 + 21.6 * lbm, BmrFormula.katchMcArdle),
      approximate: approximate,
    );
  }

  final bad =
      checkRange<Bmr>(Measure.heightCm, heightCm) ??
      checkRange<Bmr>(Measure.age, age.toDouble());
  if (bad != null) return bad;
  // Unset sex: mean of +5 (male) and −161 (female), AC4.
  final s = switch (sex) {
    Sex.male => 5.0,
    Sex.female => -161.0,
    null => -78.0,
  };
  return Estimated(
    Bmr(
      10 * weightKg + 6.25 * heightCm - 5 * age + s,
      BmrFormula.mifflinStJeor,
    ),
    approximate: sex == null,
  );
}

enum ActivityLevel {
  sedentary(1.2),
  light(1.375),
  moderate(1.55),
  active(1.725),
  veryActive(1.9);

  const ActivityLevel(this.factor);

  final double factor;
}

Estimate<double> tdee(Estimate<Bmr> bmr, ActivityLevel level) =>
    bmr.map((b) => b.kcal * level.factor);

class CalorieTargets {
  const CalorieTargets({
    required this.cut,
    required this.maintain,
    required this.leanBulk,
  });

  final double cut;
  final double maintain;
  final double leanBulk;
}

Estimate<CalorieTargets> calorieTargets(Estimate<double> tdee) => tdee.map(
  (kcal) =>
      CalorieTargets(cut: kcal * 0.8, maintain: kcal, leanBulk: kcal * 1.1),
);

class ProteinRange {
  const ProteinRange(this.minGrams, this.maxGrams);

  final double minGrams;
  final double maxGrams;
}

Estimate<ProteinRange> proteinRange({required double weightKg}) {
  final bad = checkRange<ProteinRange>(Measure.weightKg, weightKg);
  if (bad != null) return bad;
  return Estimated(ProteinRange(weightKg * 1.6, weightKg * 2.2));
}
