import '../../../core/metrics/units.dart';

// SET-01 AC5 defaults, in each unit's own numbers.
const defaultBarKg = 20.0;
const defaultPlatesKg = [25.0, 20.0, 15.0, 10.0, 5.0, 2.5, 1.25];
const defaultBarLb = 45.0;
const defaultPlatesLb = [45.0, 35.0, 25.0, 10.0, 5.0, 2.5];
const defaultRestSec = 120;
const maxRestSec = 600;
const restStepSec = 15;

// Synced with the profile (AC11). Bar and plates are stored in kg, one set
// per unit system: switching units doesn't convert plates (edge).
class TrainingSettings {
  const TrainingSettings({
    this.units = UnitSystem.metric,
    this.restSec = defaultRestSec,
    this.barKgMetric,
    this.barKgImperial,
    this.platesKgMetric,
    this.platesKgImperial,
  });

  final UnitSystem units;
  final int restSec;
  // Null: the defaults.
  final double? barKgMetric;
  final double? barKgImperial;
  final List<double>? platesKgMetric;
  final List<double>? platesKgImperial;

  double barKg(UnitSystem u) => switch (u) {
    UnitSystem.metric => barKgMetric ?? defaultBarKg,
    UnitSystem.imperial => barKgImperial ?? lbToKg(defaultBarLb),
  };

  List<double> platesKg(UnitSystem u) => switch (u) {
    UnitSystem.metric => platesKgMetric ?? defaultPlatesKg,
    UnitSystem.imperial =>
      platesKgImperial ?? [for (final p in defaultPlatesLb) lbToKg(p)],
  };
}

// In the display unit, rounded to 0.01 so 45 lb stays 45 (AC5, AC6).
double inUnit(double kg, UnitSystem u) =>
    ((u == UnitSystem.metric ? kg : kgToLb(kg)) * 100).round() / 100;

double toKg(double v, UnitSystem u) => u == UnitSystem.metric ? v : lbToKg(v);

// Every plate size the plates screen offers for a unit (AC5).
List<double> plateChoices(UnitSystem u) =>
    u == UnitSystem.metric ? defaultPlatesKg : defaultPlatesLb;

enum ThemePref { system, light, dark }

// On the phone only (spec: Data touched).
class ReminderPref {
  const ReminderPref({this.on = false, this.minutes = 18 * 60});

  final bool on;
  // Time of day, minutes after midnight.
  final int minutes;

  ReminderPref copyWith({bool? on, int? minutes}) =>
      ReminderPref(on: on ?? this.on, minutes: minutes ?? this.minutes);

  @override
  bool operator ==(Object other) =>
      other is ReminderPref && other.on == on && other.minutes == minutes;

  @override
  int get hashCode => Object.hash(on, minutes);
}
