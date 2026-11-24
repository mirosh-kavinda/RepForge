import '../../../core/metrics/body.dart';
import '../../../core/metrics/energy.dart';
import '../../../core/metrics/estimate.dart';
import 'body_snapshot.dart';

const defaultActivity = ActivityLevel.moderate;

NotEstimable<double> _missing(Measure m) =>
    NotEstimable(EstimateReason.missing, m);

// AC4: a scale value wins; else the tape estimate; else the first missing
// tape measure.
Estimate<double> _bodyFat(BodyInput i, BodyProfile p) {
  if (i.scaleBodyFatPct case final pct?) {
    return checkRange<double>(Measure.bodyFatPct, pct) ?? Estimated(pct);
  }
  // Tape first: asking for height is no help until there is something to use it.
  final waist = i.waistCm;
  if (waist == null) return _missing(Measure.waistCm);
  final neck = i.neckCm;
  if (neck == null) return _missing(Measure.neckCm);
  if (p.sex != Sex.male && i.hipCm == null) return _missing(Measure.hipCm);
  final height = p.heightCm;
  if (height == null) return _missing(Measure.heightCm);
  return bodyFatNavy(
    sex: p.sex,
    heightCm: height,
    waistCm: waist,
    neckCm: neck,
    hipCm: i.hipCm,
  );
}

// AC3–AC5: every result at once, from lib/core/metrics only.
BodyResults computeBodyResults(BodyInput i, BodyProfile p, DateTime today) {
  final w = i.weightKg;
  final height = p.heightCm;
  final fat = _bodyFat(i, p);

  final Estimate<double> bmiE = height == null
      ? _missing(Measure.heightCm)
      : bmi(weightKg: w, heightCm: height);
  final lbm = leanMass(weightKg: w, bodyFat: fat);
  final Estimate<double> ffmiE = height == null
      ? _missing(Measure.heightCm)
      : ffmi(weightKg: w, heightCm: height, bodyFat: fat);

  final Estimate<Bmr> bmrE;
  if (fat is Estimated<double>) {
    // Katch–McArdle uses lean mass only; height and age are not read.
    bmrE = bmr(
      weightKg: w,
      heightCm: height ?? 0,
      age: 0,
      sex: p.sex,
      bodyFat: fat,
    );
  } else if (height == null) {
    bmrE = const NotEstimable(EstimateReason.missing, Measure.heightCm);
  } else if (p.birthYear == null) {
    bmrE = const NotEstimable(EstimateReason.missing, Measure.age);
  } else {
    bmrE = bmr(
      weightKg: w,
      heightCm: height,
      age: ageFromBirthYear(p.birthYear!, today),
      sex: p.sex,
    );
  }
  final tdeeE = tdee(bmrE, i.activity);
  final targets = calorieTargets(tdeeE);
  final protein = proteinRange(weightKg: w);

  return {
    BodyMetric.bmi: bmiE,
    BodyMetric.bodyFat: fat,
    BodyMetric.leanMass: lbm,
    BodyMetric.ffmi: ffmiE,
    BodyMetric.bmr: bmrE.map((b) => b.kcal),
    BodyMetric.tdee: tdeeE,
    BodyMetric.cut: targets.map((t) => t.cut),
    BodyMetric.maintain: targets.map((t) => t.maintain),
    BodyMetric.gain: targets.map((t) => t.leanBulk),
    BodyMetric.proteinMin: protein.map((r) => r.minGrams),
    BodyMetric.proteinMax: protein.map((r) => r.maxGrams),
  };
}

// Edge: the form refuses a weight the metrics would reject.
bool weightAccepted(double kg) => Measure.weightKg.accepts(kg);
