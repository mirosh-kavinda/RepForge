import 'package:intl/intl.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../core/metrics/units.dart';
import '../domain/summary.dart';

const _minus = '−';

String _two(int n) => n.toString().padLeft(2, '0');

// AC2, edge: "42:10 min" under an hour, else "1:02 h" (no cap: "26:05 h").
String durationText(AppLocalizations l10n, Duration d) {
  final s = d.isNegative ? Duration.zero : d;
  if (s.inHours < 1) {
    return l10n.summaryMinSec('${s.inMinutes}:${_two(s.inSeconds % 60)}');
  }
  return l10n.summaryHourMin('${s.inHours}:${_two(s.inMinutes % 60)}');
}

String _whole(num v) => NumberFormat.decimalPattern().format(v.round());

double _inUnit(double kg, UnitSystem units) =>
    units == UnitSystem.metric ? kg : kgToLb(kg);

// AC2: "1,250 kg" / "2,756 lb", whole numbers.
String volumeText(AppLocalizations l10n, double kg, UnitSystem units) {
  final v = _whole(_inUnit(kg, units));
  return units == UnitSystem.metric ? l10n.loggerKg(v) : l10n.loggerLb(v);
}

// One change from last time: what is shown, and what is read out (NFR-06).
typedef ChangeText = ({String text, String label});

ChangeText _change(
  AppLocalizations l10n,
  num delta,
  String Function(String) unit,
) {
  final size = _whole(delta.abs());
  if (size == '0') return (text: l10n.summarySame, label: l10n.summarySame);
  final amount = unit(size);
  return delta > 0
      ? (text: '+$amount', label: l10n.summaryUp(amount))
      : (text: '$_minus$amount', label: l10n.summaryDown(amount));
}

// AC5: "+1,250 kg", "−3 min", "same".
ChangeText weightChange(
  AppLocalizations l10n,
  double deltaKg,
  UnitSystem units,
) => _change(
  l10n,
  _inUnit(deltaKg, units),
  units == UnitSystem.metric ? l10n.loggerKg : l10n.loggerLb,
);

ChangeText minutesChange(AppLocalizations l10n, Duration delta) =>
    _change(l10n, delta.inSeconds / 60, l10n.summaryMinutes);

ChangeText setsChange(AppLocalizations l10n, int delta) =>
    _change(l10n, delta, (_) => l10n.summarySetsN(delta.abs()));

// AC5: a previous workout exists but one side has no weighted sets.
ChangeText noCompare(AppLocalizations l10n) =>
    (text: l10n.summaryNone, label: l10n.summaryNoCompare);

// AC3: an exercise's total by its measure.
String amountText(
  AppLocalizations l10n,
  Measure m,
  num amount,
  UnitSystem units,
) => switch (m) {
  Measure.volume => volumeText(l10n, amount.toDouble(), units),
  Measure.reps => l10n.summaryReps(_whole(amount)),
  Measure.time => durationText(l10n, Duration(seconds: amount.round())),
};

ChangeText amountChange(
  AppLocalizations l10n,
  Measure m,
  num delta,
  UnitSystem units,
) => switch (m) {
  Measure.volume => weightChange(l10n, delta.toDouble(), units),
  Measure.reps => _change(l10n, delta, l10n.summaryReps),
  Measure.time => _change(l10n, delta, l10n.summarySeconds),
};
