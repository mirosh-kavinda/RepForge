// Exact definitions; the app stores kg and cm and converts only for display.
const kgPerLb = 0.45359237;
const cmPerInch = 2.54;
const inchesPerFoot = 12;

enum MassUnit { kg, lb }

double kgToLb(double kg) => kg / kgPerLb;

double lbToKg(double lb) => lb * kgPerLb;

double cmToIn(double cm) => cm / cmPerInch;

double inToCm(double inches) => inches * cmPerInch;

({int feet, double inches}) cmToFeetInches(double cm) {
  final total = cmToIn(cm);
  var feet = total ~/ inchesPerFoot;
  var inches = total - feet * inchesPerFoot;
  // 182.88 cm is exactly 6 ft but arrives as 5 ft 11.99999 in.
  if (inchesPerFoot - inches < 1e-6) {
    feet++;
    inches = 0;
  }
  return (feet: feet, inches: inches);
}

double feetInchesToCm(int feet, double inches) =>
    inToCm(feet * inchesPerFoot + inches);

enum UnitSystem {
  metric,
  imperial;

  MassUnit get mass => this == metric ? MassUnit.kg : MassUnit.lb;
}

const _imperialRegions = {'US', 'LR', 'MM'};

// ONB-01 AC4: the default before the user chooses.
UnitSystem defaultUnitSystem(String? countryCode) =>
    _imperialRegions.contains(countryCode?.toUpperCase())
    ? UnitSystem.imperial
    : UnitSystem.metric;
