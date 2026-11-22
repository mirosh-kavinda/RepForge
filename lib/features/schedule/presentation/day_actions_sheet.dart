import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_tappable.dart';
import '../domain/cycle.dart';
import '../domain/day_actions.dart';
import 'weekday_labels.dart';

// Screen 17 (SCH-04 AC1): each option says what it will do.
Future<DayAction?> pickDayAction(
  BuildContext context,
  List<DayAction> actions,
  CycleMode mode,
) {
  final l10n = AppLocalizations.of(context);
  final rolling = mode == CycleMode.rolling;
  (String, String) text(DayAction a) => switch (a) {
    DayAction.swap => (l10n.dayActionSwap, l10n.dayActionSwapHint),
    DayAction.trainToday => (
      l10n.dayActionTrainToday,
      l10n.dayActionTrainTodayHint,
    ),
    DayAction.skip => (
      l10n.dayActionSkip,
      rolling ? l10n.dayActionSkipHintRolling : l10n.dayActionSkipHintWeekdays,
    ),
    DayAction.unplannedRest => (
      l10n.dayActionRest,
      rolling ? l10n.dayActionRestHintRolling : l10n.dayActionRestHintWeekdays,
    ),
    DayAction.move => (l10n.dayActionMove, l10n.dayActionMoveHint),
  };
  return _sheet<DayAction>(context, l10n.dayActionsTitle, [
    for (final a in actions) (value: a, title: text(a).$1, hint: text(a).$2),
  ]);
}

// AC7: the later dates this week, by weekday.
Future<DateTime?> pickMoveTarget(
  BuildContext context,
  String workout,
  List<DateTime> targets,
) {
  final l10n = AppLocalizations.of(context);
  final week = WeekdayLabels.of(context);
  final locale = Localizations.localeOf(context).toString();
  return _sheet<DateTime>(context, l10n.dayMoveTitle(workout), [
    for (final d in targets)
      (
        value: d,
        title: week.full(d.weekday - 1),
        hint: DateFormat.MMMd(locale).format(d),
      ),
  ]);
}

Future<T?> _sheet<T>(
  BuildContext context,
  String title,
  List<({T value, String title, String hint})> options,
) => showModalBottomSheet<T>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (context) {
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: RfSpace.s20),
            child: Semantics(
              header: true,
              child: Text(title, style: t.heading),
            ),
          ),
          const SizedBox(height: RfSpace.s8),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(
                RfSpace.s20,
                0,
                RfSpace.s20,
                RfSpace.s16,
              ),
              children: [
                for (final o in options)
                  Padding(
                    padding: const EdgeInsets.only(bottom: RfSpace.s8),
                    child: Semantics(
                      container: true,
                      button: true,
                      label: '${o.title}, ${o.hint}',
                      onTap: () => Navigator.of(context).pop(o.value),
                      excludeSemantics: true,
                      child: RfTappable(
                        radius: RfRadius.lg,
                        onTap: () => Navigator.of(context).pop(o.value),
                        child: Container(
                          constraints: const BoxConstraints(
                            minHeight: RfSize.minTarget,
                          ),
                          padding: const EdgeInsets.all(RfSpace.s12),
                          decoration: BoxDecoration(
                            color: c.surface,
                            borderRadius: BorderRadius.circular(RfRadius.lg),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(o.title, style: t.labelStrong),
                              const SizedBox(height: RfSpace.s4),
                              Text(
                                o.hint,
                                style: t.label.copyWith(color: c.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  },
);
