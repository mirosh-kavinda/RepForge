import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../core/metrics/units.dart';
import '../domain/progress_rules.dart';

const _minus = '−';

String rangeName(AppLocalizations l10n, ProgressRange r) => switch (r) {
  ProgressRange.weeks4 => l10n.range4w,
  ProgressRange.months3 => l10n.range3m,
  ProgressRange.year1 => l10n.range1y,
  ProgressRange.all => l10n.rangeAll,
};

String _n(num v, int decimals) =>
    NumberFormat.decimalPatternDigits(decimalDigits: decimals).format(v);

// A kg value in the user's unit, as text (AC6).
String massText(
  AppLocalizations l10n,
  double kg,
  UnitSystem u, {
  int decimals = 0,
}) => u == UnitSystem.metric
    ? l10n.loggerKg(_n(kg, decimals))
    : l10n.loggerLb(_n(kgToLb(kg), decimals));

// "+2.5 kg" / "−1 kg" / "same", from an already formatted magnitude.
String signed(AppLocalizations l10n, double delta, String Function(double) f) {
  final text = f(delta.abs());
  if (f(0) == text) return l10n.summarySame;
  return delta > 0 ? '+$text' : '$_minus$text';
}

// AC7: what a touched point or bar shows.
String tooltipText(
  String locale,
  DateTime date,
  double value,
  String Function(double) format,
) => '${DateFormat.MMMd(locale).format(date)}\n${format(value)}';

class ChartLine {
  const ChartLine({
    required this.label,
    required this.points,
    required this.color,
    required this.format,
  });

  final String label;
  final List<ChartPoint> points;
  final Color color;
  final String Function(double) format;
}

// AC7: touch shows date and value; the picture is hidden from screen
// readers, which get [summary] instead.
class ProgressLineChart extends StatelessWidget {
  const ProgressLineChart({
    required this.lines,
    required this.summary,
    super.key,
  });

  final List<ChartLine> lines;
  final String summary;

  @override
  Widget build(BuildContext context) {
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final locale = Localizations.localeOf(context).toString();
    final all = [for (final l in lines) ...l.points];
    final x0 = all.map((p) => p.date).reduce((a, b) => a.isBefore(b) ? a : b);
    double x(DateTime d) => d.difference(x0).inDays.toDouble();

    return Semantics(
      container: true,
      label: summary,
      excludeSemantics: true,
      child: SizedBox(
        height: RfSize.lineChartHeight,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: const FlTitlesData(show: false),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => c.surface,
                getTooltipItems: (spots) => [
                  for (final s in spots)
                    LineTooltipItem(
                      tooltipText(
                        locale,
                        x0.add(Duration(days: s.x.round())),
                        s.y,
                        lines[s.barIndex].format,
                      ),
                      t.label.copyWith(color: c.textPrimary),
                    ),
                ],
              ),
            ),
            lineBarsData: [
              for (final l in lines)
                LineChartBarData(
                  spots: [for (final p in l.points) FlSpot(x(p.date), p.value)],
                  color: l.color,
                  barWidth: RfSize.chartLineWidth,
                  dotData: const FlDotData(show: true),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProgressBarChart extends StatelessWidget {
  const ProgressBarChart({
    required this.points,
    required this.summary,
    required this.format,
    super.key,
  });

  final List<ChartPoint> points;
  final String summary;
  final String Function(double) format;

  @override
  Widget build(BuildContext context) {
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final locale = Localizations.localeOf(context).toString();
    return Semantics(
      container: true,
      label: summary,
      excludeSemantics: true,
      child: SizedBox(
        height: RfSize.barChartHeight,
        child: BarChart(
          BarChartData(
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: const FlTitlesData(show: false),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => c.surface,
                getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                  tooltipText(locale, points[group.x].date, rod.toY, format),
                  t.label.copyWith(color: c.textPrimary),
                ),
              ),
            ),
            barGroups: [
              for (final (i, p) in points.indexed)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: p.value,
                      color: c.actionFill,
                      width: RfSize.chartBarWidth,
                      borderRadius: BorderRadius.circular(RfRadius.xs),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Section frame: title, optional action, body.
class ProgressSection extends StatelessWidget {
  const ProgressSection({
    required this.title,
    required this.children,
    this.action,
    super.key,
  });

  final String title;
  final Widget? action;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: RfSpace.s16),
      padding: const EdgeInsets.all(RfSpace.s16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(RfRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Semantics(header: true, child: Text(title, style: t.heading)),
              ?action,
            ],
          ),
          const SizedBox(height: RfSpace.s8),
          ...children,
        ],
      ),
    );
  }
}

// AC5: a sentence instead of an empty chart.
class ProgressNote extends StatelessWidget {
  const ProgressNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    return Text(text, style: t.body.copyWith(color: c.textSecondary));
  }
}
