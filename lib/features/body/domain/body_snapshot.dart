import '../../../core/metrics/body.dart';
import '../../../core/metrics/energy.dart';
import '../../../core/metrics/estimate.dart';

// BOD-01: every result saved with a snapshot (AC3).
enum BodyMetric {
  bmi,
  bodyFat,
  leanMass,
  ffmi,
  bmr,
  tdee,
  cut,
  maintain,
  gain,
  proteinMin,
  proteinMax,
}

typedef BodyResults = Map<BodyMetric, Estimate<double>>;

// What the form collects; lengths in cm, mass in kg (AC2).
class BodyInput {
  const BodyInput({
    required this.weightKg,
    required this.activity,
    this.waistCm,
    this.neckCm,
    this.hipCm,
    this.scaleBodyFatPct,
  });

  final double weightKg;
  final ActivityLevel activity;
  final double? waistCm;
  final double? neckCm;
  final double? hipCm;
  final double? scaleBodyFatPct;
}

// From the profile; any may be unset.
class BodyProfile {
  const BodyProfile({this.sex, this.birthYear, this.heightCm, this.activity});

  final Sex? sex;
  final int? birthYear;
  final double? heightCm;
  final ActivityLevel? activity;
}

class BodySnapshot {
  const BodySnapshot({
    required this.id,
    required this.date,
    this.weightKg,
    this.waistCm,
    this.neckCm,
    this.hipCm,
    this.scaleBodyFatPct,
    this.activity,
    this.results,
  });

  final String id;
  // UTC midnight of the phone's calendar day.
  final DateTime date;
  final double? weightKg;
  final double? waistCm;
  final double? neckCm;
  final double? hipCm;
  final double? scaleBodyFatPct;
  final ActivityLevel? activity;
  // Null for onboarding snapshots, which saved none.
  final BodyResults? results;

  bool get fatFromScale => scaleBodyFatPct != null;
}
