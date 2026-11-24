import 'package:intl/intl.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../core/metrics/projection.dart';
import '../../../core/metrics/units.dart';
import '../../progress/presentation/progress_charts.dart';
import '../domain/goal.dart';
import '../domain/goal_rules.dart';

// Wording shared by the Goals list, the form and the Home card.

// AC11: one decimal, in the display unit.
String goalValue(AppLocalizations l10n, double kg, UnitSystem u) =>
    massText(l10n, kg, u, decimals: 1);

String goalName(AppLocalizations l10n, Goal g, String? liftName) =>
    switch (g.type) {
      GoalType.strength => l10n.goalStrengthName(liftName ?? ''),
      GoalType.bodyWeight => l10n.goalBodyWeight,
    };

String goalDate(String locale, DateTime d) =>
    DateFormat.yMMMd(locale).format(d);

// AC3, AC4.
String projectionText(AppLocalizations l10n, String locale, Projection p) =>
    switch (p) {
      OnTrack(:final date) => l10n.goalProjected(goalDate(locale, date)),
      NotEnoughData() => l10n.goalNotEnoughData,
      NotOnTrack() => l10n.goalNotOnTrack,
    };

// AC5: in words.
String paceText(AppLocalizations l10n, Pace p) => switch (p) {
  Pace.onPace => l10n.goalOnPace,
  Pace.behind => l10n.goalBehind,
  Pace.deadlinePassed => l10n.goalDeadlinePassed,
};

// AC4: "90.0 kg → 99.0 kg → 100.0 kg"; "—" before any data.
String goalPath(AppLocalizations l10n, Goal g, double? current, UnitSystem u) =>
    l10n.goalPath(
      goalValue(l10n, g.startValue, u),
      current == null ? '—' : goalValue(l10n, current, u),
      goalValue(l10n, g.target, u),
    );

String percentText(AppLocalizations l10n, double pct) =>
    l10n.goalPercent(pct.round().toString());

String? targetProblemText(AppLocalizations l10n, TargetProblem? p) =>
    switch (p) {
      null => null,
      TargetProblem.invalid => l10n.goalTargetInvalid,
      TargetProblem.already => l10n.goalTargetAlready,
      TargetProblem.mustBeAbove => l10n.goalTargetAbove,
      TargetProblem.mustBeBelow => l10n.goalTargetBelow,
    };
