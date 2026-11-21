import '../../../app/l10n/generated/app_localizations.dart';
import '../../../core/metrics/display.dart';
import '../../../core/metrics/units.dart';
import '../domain/template_rules.dart';
import '../domain/workout_template.dart';

String restText(int seconds) =>
    '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

String unitLabel(AppLocalizations l10n, MassUnit unit) =>
    unit == MassUnit.kg ? l10n.unitKg : l10n.unitLb;

String _number(double v) =>
    v == v.roundToDouble() ? '${v.round()}' : v.toStringAsFixed(1);

// Display only: 0.5 kg or whole lb steps (FND-04 displayMass).
String weightNumber(double kg, MassUnit unit) => _number(displayMass(kg, unit));

// The stored value for editing, not plate-rounded, so an untouched field
// never changes what is saved.
String weightInput(double kg, MassUnit unit) {
  final v = unit == MassUnit.kg ? kg : kgToLb(kg);
  return v
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

String weightText(AppLocalizations l10n, double kg, MassUnit unit) =>
    '${weightNumber(kg, unit)} ${unitLabel(l10n, unit)}';

String targetText(AppLocalizations l10n, TemplateExercise e) =>
    switch (e.kind) {
      TargetKind.time => l10n.fmtSeconds(e.seconds),
      TargetKind.reps when e.repMin == e.repMax => '${e.repMin}',
      TargetKind.reps =>
        e.repMin < e.repMax
            ? '${e.repMin}–${e.repMax}'
            : '${e.repMax}–${e.repMin}',
    };

// "4 × 5–8 · 102.5 kg · rest 3:00" (AC4, AC7).
String rowLine(
  AppLocalizations l10n,
  List<TemplateExercise> list,
  int index,
  MassUnit unit,
) {
  final e = list[index];
  return [
    '${e.sets} × ${targetText(l10n, e)}',
    if (e.targetKg case final kg?) weightText(l10n, kg, unit),
    restsInsideSuperset(list, index)
        ? l10n.fmtNoRest
        : l10n.fmtRest(restText(e.restSec)),
  ].join(' · ');
}
