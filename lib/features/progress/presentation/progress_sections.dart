import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../core/metrics/units.dart';
import '../../body/presentation/body_results.dart';
import '../../onboarding/data/providers.dart';
import '../data/providers.dart';
import '../domain/progress_rules.dart';
import 'progress_charts.dart';

String _summary(
  AppLocalizations l10n,
  String title,
  ProgressRange range,
  List<ChartPoint> points,
  String Function(double) format,
) => l10n.chartSummary(
  title,
  rangeName(l10n, range),
  format(points.first.value),
  format(points.last.value),
  l10n.changeOverRange(
    signed(l10n, points.last.value - points.first.value, format),
  ),
);

// AC2, AC5, edges.
class StrengthSection extends ConsumerWidget {
  const StrengthSection({super.key});

  static const changeKey = ValueKey('progress.changeExercise');

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final t = RfTextStyles.of(context);
    final list = await ref.read(loggedExercisesProvider.future);
    if (!context.mounted) return;
    final id = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: RfSpace.s20),
              child: Text(l10n.strengthPick, style: t.heading),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final e in list)
                    ListTile(
                      minTileHeight: RfSize.minTarget,
                      title: Text(e.name, style: t.body),
                      onTap: () => Navigator.of(context).pop(e.id),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (id != null) await ref.read(chosenExerciseProvider.notifier).choose(id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final units = ref.watch(unitSystemProvider).value ?? UnitSystem.metric;
    final range = ref.watch(selectedRangeProvider);
    final progress = ref.watch(strengthProgressProvider).value;
    final id = progress?.id;
    final series = progress?.series;
    final names = ref.watch(loggedExercisesProvider).value ?? const [];
    final name = names.where((e) => e.id == id).firstOrNull?.name;

    if (id == null) {
      return ProgressSection(
        title: l10n.strengthTitle,
        children: [ProgressNote(l10n.strengthNoData)],
      );
    }

    final (label, String Function(double) format) = switch (series?.measure) {
      StrengthMeasure.reps => (
        l10n.strengthBestReps,
        (v) => l10n.repsN(v.round().toString()),
      ),
      StrengthMeasure.seconds => (
        l10n.strengthBestTime,
        (v) => l10n.secondsN(v.round().toString()),
      ),
      _ => (l10n.strengthE1rm, (v) => massText(l10n, v, units)),
    };
    final points = series?.points ?? const <ChartPoint>[];
    final best = series?.bestSet;

    return ProgressSection(
      title: l10n.strengthTitle,
      action: TextButton(
        key: changeKey,
        style: TextButton.styleFrom(
          minimumSize: const Size(RfSize.minTarget, RfSize.minTarget),
        ),
        onPressed: () => _pick(context, ref),
        child: Text(l10n.strengthChange),
      ),
      children: [
        if (name != null)
          Text(name, style: t.labelStrong.copyWith(color: c.textPrimary)),
        Text(label, style: t.label.copyWith(color: c.textSecondary)),
        const SizedBox(height: RfSpace.s8),
        if (!enoughForLine(points))
          ProgressNote(l10n.strengthNeedTwo)
        else ...[
          ProgressLineChart(
            lines: [
              ChartLine(
                label: label,
                points: points,
                color: c.actionFill,
                format: format,
              ),
            ],
            summary: _summary(l10n, label, range, points, format),
          ),
          const SizedBox(height: RfSpace.s8),
          Text(
            l10n.strengthBest(format(series!.best!)),
            style: t.body.copyWith(color: c.textPrimary),
          ),
          Text(
            l10n.changeOverRange(signed(l10n, series.change!, format)),
            style: t.label.copyWith(color: c.textSecondary),
          ),
        ],
        if (best != null && series!.measure == StrengthMeasure.e1rm)
          Text(
            l10n.strengthBestSet(
              l10n.loggerTimes(
                massText(l10n, best.kg, units, decimals: 1),
                best.reps ?? 0,
              ),
            ),
            style: t.label.copyWith(color: c.textSecondary),
          ),
      ],
    );
  }
}

// AC3, AC5.
class VolumeSection extends ConsumerWidget {
  const VolumeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final units = ref.watch(unitSystemProvider).value ?? UnitSystem.metric;
    final range = ref.watch(selectedRangeProvider);
    final weeks = ref.watch(volumeProgressProvider).value ?? const [];
    String format(double kg) => massText(l10n, kg, units);

    if (weeks.every((w) => w.value == 0)) {
      return ProgressSection(
        title: l10n.volumeTitle,
        children: [ProgressNote(l10n.volumeNoData)],
      );
    }
    final thisWeek = format(weeks.last.value);
    return ProgressSection(
      title: l10n.volumeTitle,
      children: [
        ProgressBarChart(
          points: weeks,
          format: format,
          summary: l10n.chartSummaryBars(
            l10n.volumeTitle,
            rangeName(l10n, range),
            weeks.length,
            thisWeek,
          ),
        ),
        const SizedBox(height: RfSpace.s8),
        Text(
          l10n.volumeThisWeek(thisWeek),
          style: t.body.copyWith(color: c.textPrimary),
        ),
      ],
    );
  }
}

// AC4, AC5.
class BodyTrendsSection extends ConsumerWidget {
  const BodyTrendsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final units = ref.watch(unitSystemProvider).value ?? UnitSystem.metric;
    final range = ref.watch(selectedRangeProvider);
    final trends = ref.watch(bodyProgressProvider).value;
    String kg(double v) => massText(l10n, v, units, decimals: 1);
    String pct(double v) => pctText(l10n, v);

    List<Widget> line(
      String label,
      List<ChartPoint> p,
      Color color,
      String Function(double) f,
    ) => [
      Text(
        l10n.trendLatest(label, f(p.last.value)),
        style: t.labelStrong.copyWith(color: c.textPrimary),
      ),
      Text(
        l10n.changeOverRange(signed(l10n, p.last.value - p.first.value, f)),
        style: t.label.copyWith(color: c.textSecondary),
      ),
      const SizedBox(height: RfSpace.s4),
      ProgressLineChart(
        lines: [ChartLine(label: label, points: p, color: color, format: f)],
        summary: _summary(l10n, label, range, p, f),
      ),
      const SizedBox(height: RfSpace.s12),
    ];

    final weight = trends?.weight ?? const <ChartPoint>[];
    final fat = trends?.bodyFat ?? const <ChartPoint>[];
    return ProgressSection(
      title: l10n.bodyTrendsTitle,
      children: [
        if (!enoughForLine(weight))
          ProgressNote(l10n.bodyTrendsNoData)
        else
          ...line(l10n.bodyWeight, weight, c.actionFill, kg),
        if (enoughForLine(fat))
          ...line(l10n.bodyFat, fat, c.actionFill, pct)
        else if (enoughForLine(weight))
          ProgressNote(l10n.bodyFatNeedTwo),
      ],
    );
  }
}
