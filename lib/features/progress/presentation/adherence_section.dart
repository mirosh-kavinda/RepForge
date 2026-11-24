import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../workout/data/providers.dart';
import '../../workout/domain/workout_template.dart';
import '../data/providers.dart';
import '../domain/progress_rules.dart';
import 'progress_charts.dart';

// PRG-02 AC3–AC8: adherence for the range, streaks, weekly bars, missed days.
class AdherenceSection extends ConsumerStatefulWidget {
  const AdherenceSection({super.key});

  static const showAllKey = ValueKey('progress.adherence.showAll');
  static const shownMissed = 5;

  @override
  ConsumerState<AdherenceSection> createState() => _AdherenceSectionState();
}

class _AdherenceSectionState extends ConsumerState<AdherenceSection> {
  var _showAll = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final locale = Localizations.localeOf(context).toString();
    final range = ref.watch(selectedRangeProvider);
    final async = ref.watch(adherenceProvider);
    final s = async.value;
    final names = {
      for (final w
          in ref.watch(templatesProvider).value ?? const <WorkoutTemplate>[])
        w.id: w.name,
    };
    String pct(double v) => l10n.bodyPct(v.round().toString());

    if (s == null) {
      if (!async.hasError) return const SizedBox.shrink();
      return ProgressSection(
        title: l10n.adherenceTitle,
        children: [ProgressNote(l10n.adherenceNoData)],
      );
    }

    final percent = s.percent.valueOrNull;
    final count = l10n.adherenceOf(s.done, s.planned);
    final streak = l10n.adherenceStreak(s.streak);
    final best = l10n.adherenceBest(s.bestStreak);
    final missed = _showAll
        ? s.missed
        : s.missed.take(AdherenceSection.shownMissed).toList();
    final thisWeek = s.weeks.lastOrNull?.percent;

    return ProgressSection(
      title: l10n.adherenceTitle,
      children: [
        Semantics(
          container: true,
          excludeSemantics: true,
          label: l10n.adherenceSummary(
            l10n.adherenceTitle,
            rangeName(l10n, range),
            percent == null ? l10n.adherenceNoData : pct(percent),
            count,
            streak,
            best,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (percent == null)
                ProgressNote(l10n.adherenceNoData)
              else ...[
                Text(
                  pct(percent),
                  style: t.statXl.copyWith(color: c.textPrimary),
                ),
                Text(count, style: t.body.copyWith(color: c.textSecondary)),
              ],
              const SizedBox(height: RfSpace.s8),
              Text(streak, style: t.labelStrong.copyWith(color: c.textPrimary)),
              Text(best, style: t.label.copyWith(color: c.textSecondary)),
            ],
          ),
        ),
        if (s.weeks.isNotEmpty) ...[
          const SizedBox(height: RfSpace.s16),
          Text(
            l10n.adherenceWeekly,
            style: t.label.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: RfSpace.s8),
          ProgressBarChart(
            points: [
              for (final w in s.weeks) ChartPoint(w.week, w.percent ?? 0),
            ],
            noData: {
              for (final w in s.weeks)
                if (w.percent == null) w.week,
            },
            noDataText: l10n.adherenceNoTraining,
            maxY: 100,
            format: pct,
            summary: l10n.adherenceWeeksSummary(
              l10n.adherenceWeekly,
              rangeName(l10n, range),
              s.weeks.length,
              s.weeks.where((w) => w.percent == null).length,
              thisWeek == null ? l10n.adherenceNoTraining : pct(thisWeek),
            ),
          ),
        ],
        const SizedBox(height: RfSpace.s16),
        Semantics(
          header: true,
          child: Text(
            l10n.adherenceMissedTitle,
            style: t.labelStrong.copyWith(color: c.textPrimary),
          ),
        ),
        const SizedBox(height: RfSpace.s4),
        if (s.missed.isEmpty)
          ProgressNote(l10n.adherenceNoMissed)
        else ...[
          for (final m in missed)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: RfSpace.s4),
              child: Text(
                l10n.adherenceMissedRow(
                  DateFormat.MMMEd(locale).format(m.date),
                  names[m.workoutId] ?? l10n.adherenceWorkout,
                  m.skipped ? l10n.adherenceSkipped : l10n.adherenceMissed,
                ),
                style: t.body.copyWith(color: c.textPrimary),
              ),
            ),
          if (!_showAll && s.missed.length > AdherenceSection.shownMissed)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                key: AdherenceSection.showAllKey,
                style: TextButton.styleFrom(
                  minimumSize: const Size(RfSize.minTarget, RfSize.minTarget),
                ),
                onPressed: () => setState(() => _showAll = true),
                child: Text(l10n.adherenceShowAll),
              ),
            ),
        ],
      ],
    );
  }
}
