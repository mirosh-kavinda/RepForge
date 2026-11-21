enum EstimateReason { outOfRange, inconsistent, missing, notEnoughData }

// Plausible input ranges (FND-04 spec, Data touched).
enum Measure {
  weightKg(25, 350),
  heightCm(100, 250),
  age(13, 100),
  waistCm(40, 250),
  neckCm(20, 80),
  hipCm(50, 250),
  bodyFatPct(3, 60);

  const Measure(this.min, this.max);

  final double min;
  final double max;

  bool accepts(double value) => value.isFinite && value >= min && value <= max;
}

// A metric result: a value, or "can't estimate" with the reason (AC5).
sealed class Estimate<T> {
  const Estimate();

  T? get valueOrNull => switch (this) {
    Estimated<T>(:final value) => value,
    NotEstimable<T>() => null,
  };

  Estimate<R> map<R>(R Function(T value) f) => switch (this) {
    Estimated<T>(:final value, :final approximate) => Estimated(
      f(value),
      approximate: approximate,
    ),
    NotEstimable<T>(:final reason, :final field) => NotEstimable(reason, field),
  };
}

final class Estimated<T> extends Estimate<T> {
  const Estimated(this.value, {this.approximate = false});

  final T value;

  // True when an input had to be assumed, e.g. sex not set (AC4).
  final bool approximate;

  @override
  bool operator ==(Object other) =>
      other is Estimated<T> &&
      other.value == value &&
      other.approximate == approximate;

  @override
  int get hashCode => Object.hash(value, approximate);

  @override
  String toString() => 'Estimated($value${approximate ? ', approximate' : ''})';
}

final class NotEstimable<T> extends Estimate<T> {
  const NotEstimable(this.reason, [this.field]);

  final EstimateReason reason;
  final Measure? field;

  @override
  bool operator ==(Object other) =>
      other is NotEstimable<T> &&
      other.reason == reason &&
      other.field == field;

  @override
  int get hashCode => Object.hash(reason, field);

  @override
  String toString() => 'NotEstimable(${reason.name}, ${field?.name})';
}

NotEstimable<T>? checkRange<T>(Measure measure, double? value) {
  if (value == null) return NotEstimable(EstimateReason.missing, measure);
  return measure.accepts(value)
      ? null
      : NotEstimable(EstimateReason.outOfRange, measure);
}
