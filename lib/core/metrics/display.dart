import 'units.dart';

// Display rounding only (AC10); stored values are never rounded. Dart's
// round() takes halves away from zero.
double _toStep(double value, double step) => (value / step).round() * step;

// BMI, body fat %, FFMI.
double displayOneDecimal(double value) => (value * 10).round() / 10;

// LBM and e1RM: 0.5 kg, or whole lb.
double displayMass(double kg, MassUnit unit) => switch (unit) {
  MassUnit.kg => _toStep(kg, 0.5),
  MassUnit.lb => kgToLb(kg).roundToDouble(),
};

// BMR, TDEE, calorie targets.
int displayKcal(double kcal) => _toStep(kcal, 10).round();

int displayProteinGrams(double grams) => grams.round();

// Session volume in whole units.
int displayVolume(double kg, MassUnit unit) => switch (unit) {
  MassUnit.kg => kg.round(),
  MassUnit.lb => kgToLb(kg).round(),
};
