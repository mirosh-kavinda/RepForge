import 'package:flutter/material.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../core/metrics/units.dart';
import '../domain/plates.dart';

// "2.5", "1.25", "45": no trailing zeros.
String plateNumber(double v) => v
    .toStringAsFixed(2)
    .replaceFirst(RegExp(r'0+$'), '')
    .replaceFirst(RegExp(r'\.$'), '');

String _inUnit(AppLocalizations l10n, String n, UnitSystem u) =>
    u == UnitSystem.metric ? l10n.loggerKg(n) : l10n.loggerLb(n);

String plateWeight(AppLocalizations l10n, double v, UnitSystem u) =>
    _inUnit(l10n, plateNumber(v), u);

// SET-01 AC6, AC7: "Each side: 25, 5, 2.5 kg" and what is missing.
List<String> plateLines(AppLocalizations l10n, PlateLoad load, UnitSystem u) =>
    switch (load) {
      BelowBar() => [l10n.platesBelowBar],
      Loaded(:final perSide, :final shortBy) => [
        if (perSide.isEmpty)
          l10n.platesJustBar
        else
          l10n.platesEachSide(
            _inUnit(l10n, perSide.map(plateNumber).join(', '), u),
          ),
        if (shortBy > 0) l10n.platesShort(plateWeight(l10n, shortBy, u)),
      ],
    };

String reminderTime(BuildContext context, int minutes) =>
    TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60).format(context);
