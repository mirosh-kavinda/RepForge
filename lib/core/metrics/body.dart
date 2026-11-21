import 'dart:math' as math;

import 'estimate.dart';

enum Sex { male, female }

int ageFromBirthYear(int birthYear, DateTime today) => today.year - birthYear;

double _log10(double x) => math.log(x) / math.ln10;

Estimate<double> bmi({required double weightKg, required double heightCm}) {
  final bad =
      checkRange<double>(Measure.weightKg, weightKg) ??
      checkRange<double>(Measure.heightCm, heightCm);
  if (bad != null) return bad;
  final m = heightCm / 100;
  return Estimated(weightKg / (m * m));
}

// US Navy method, all lengths in cm (AC1). Unset sex: mean of both (AC4).
Estimate<double> bodyFatNavy({
  required Sex? sex,
  required double heightCm,
  required double waistCm,
  required double neckCm,
  double? hipCm,
}) {
  final bad =
      checkRange<double>(Measure.heightCm, heightCm) ??
      checkRange<double>(Measure.waistCm, waistCm) ??
      checkRange<double>(Measure.neckCm, neckCm) ??
      (sex == Sex.male ? null : checkRange<double>(Measure.hipCm, hipCm));
  if (bad != null) return bad;

  double? male() {
    final girth = waistCm - neckCm;
    if (girth <= 0) return null;
    return 495 /
            (1.0324 - 0.19077 * _log10(girth) + 0.15456 * _log10(heightCm)) -
        450;
  }

  double? female() {
    final girth = waistCm + hipCm! - neckCm;
    if (girth <= 0) return null;
    return 495 /
            (1.29579 - 0.35004 * _log10(girth) + 0.22100 * _log10(heightCm)) -
        450;
  }

  final values = switch (sex) {
    Sex.male => [male()],
    Sex.female => [female()],
    null => [male(), female()],
  };
  if (values.any((v) => v == null || !Measure.bodyFatPct.accepts(v))) {
    return const NotEstimable(EstimateReason.inconsistent);
  }
  final mean = values.fold(0.0, (sum, v) => sum + v!) / values.length;
  return Estimated(mean, approximate: sex == null);
}

Estimate<double> leanMass({
  required double weightKg,
  required Estimate<double> bodyFat,
}) {
  final bad = checkRange<double>(Measure.weightKg, weightKg);
  if (bad != null) return bad;
  if (bodyFat case Estimated(:final value)) {
    final badFat = checkRange<double>(Measure.bodyFatPct, value);
    if (badFat != null) return badFat;
  }
  return bodyFat.map((bf) => weightKg * (1 - bf / 100));
}

Estimate<double> ffmi({
  required double weightKg,
  required double heightCm,
  required Estimate<double> bodyFat,
}) {
  final bad = checkRange<double>(Measure.heightCm, heightCm);
  if (bad != null) return bad;
  final m = heightCm / 100;
  return leanMass(
    weightKg: weightKg,
    bodyFat: bodyFat,
  ).map((lbm) => lbm / (m * m));
}
