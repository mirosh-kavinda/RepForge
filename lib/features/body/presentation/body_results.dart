import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../core/metrics/display.dart';
import '../../../core/metrics/estimate.dart';
import '../../../core/metrics/units.dart';
import '../domain/body_snapshot.dart';

String _n(num v, {int decimals = 0}) =>
    NumberFormat.decimalPatternDigits(decimalDigits: decimals).format(v);

// Inputs: one decimal in the user's unit (AC2).
String weightText(AppLocalizations l10n, double kg, UnitSystem u) =>
    u == UnitSystem.metric
    ? l10n.loggerKg(_n(kg, decimals: 1))
    : l10n.loggerLb(_n(kgToLb(kg), decimals: 1));

String lengthText(AppLocalizations l10n, double cm, UnitSystem u) =>
    u == UnitSystem.metric
    ? l10n.bodyCm(_n(cm, decimals: 1))
    : l10n.bodyIn(_n(cmToIn(cm), decimals: 1));

// NFR-06: the same values with units in words, for screen readers.
String spokenWeight(AppLocalizations l10n, double kg, UnitSystem u) =>
    u == UnitSystem.metric
    ? l10n.spokenKg(_n(kg, decimals: 1))
    : l10n.spokenLb(_n(kgToLb(kg), decimals: 1));

String spokenLength(AppLocalizations l10n, double cm, UnitSystem u) =>
    u == UnitSystem.metric
    ? l10n.spokenCm(_n(cm, decimals: 1))
    : l10n.spokenIn(_n(cmToIn(cm), decimals: 1));

String spokenPct(AppLocalizations l10n, double pct) =>
    l10n.spokenPct(_n(displayOneDecimal(pct), decimals: 1));

String pctText(AppLocalizations l10n, double pct) =>
    l10n.bodyPct(_n(displayOneDecimal(pct), decimals: 1));

String metricLabel(AppLocalizations l10n, BodyMetric m) => switch (m) {
  BodyMetric.bmi => l10n.bodyBmi,
  BodyMetric.bodyFat => l10n.bodyFat,
  BodyMetric.leanMass => l10n.bodyLeanMass,
  BodyMetric.ffmi => l10n.bodyFfmi,
  BodyMetric.bmr => l10n.bodyBmr,
  BodyMetric.tdee => l10n.bodyTdee,
  BodyMetric.cut => l10n.bodyCut,
  BodyMetric.maintain => l10n.bodyMaintain,
  BodyMetric.gain => l10n.bodyGain,
  BodyMetric.proteinMin || BodyMetric.proteinMax => l10n.bodyProtein,
};

String _value(
  AppLocalizations l10n,
  BodyMetric m,
  double v,
  UnitSystem u,
) => switch (m) {
  BodyMetric.bmi || BodyMetric.ffmi => _n(displayOneDecimal(v), decimals: 1),
  BodyMetric.bodyFat => pctText(l10n, v),
  BodyMetric.leanMass =>
    u == UnitSystem.metric
        ? l10n.loggerKg(_n(displayMass(v, MassUnit.kg), decimals: 1))
        : l10n.loggerLb(_n(displayMass(v, MassUnit.lb))),
  BodyMetric.bmr ||
  BodyMetric.tdee ||
  BodyMetric.cut ||
  BodyMetric.maintain ||
  BodyMetric.gain => l10n.bodyKcal(_n(displayKcal(v))),
  BodyMetric.proteinMin || BodyMetric.proteinMax => _n(displayProteinGrams(v)),
};

// AC5: why a result is missing, in words.
String reasonText(AppLocalizations l10n, NotEstimable<double> e) =>
    switch ((e.reason, e.field)) {
      (EstimateReason.missing, Measure.heightCm) => l10n.bodyNeedHeight,
      (EstimateReason.missing, Measure.age) => l10n.bodyNeedAge,
      (EstimateReason.missing, Measure.hipCm) => l10n.bodyNeedHip,
      (EstimateReason.missing, Measure.waistCm || Measure.neckCm) =>
        l10n.bodyNeedTape,
      (EstimateReason.inconsistent, _) => l10n.bodyInconsistent,
      (EstimateReason.outOfRange, _) => l10n.bodyOutOfRange,
      _ => l10n.bodyNeedBodyFat,
    };

// AC3–AC5: every saved result; "—" with the reason when not estimable.
class BodyResultsList extends StatelessWidget {
  const BodyResultsList({
    required this.results,
    required this.units,
    required this.fatFromScale,
    super.key,
  });

  final BodyResults results;
  final UnitSystem units;
  final bool fatFromScale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);

    Widget row(String label, String value, {String? note, String? spoken}) =>
        Semantics(
          container: true,
          excludeSemantics: true,
          label: [label, spoken ?? value, ?note].join(', '),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: RfSpace.s8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: t.body.copyWith(color: c.textSecondary),
                  ),
                ),
                const SizedBox(width: RfSpace.s12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        value,
                        textAlign: TextAlign.end,
                        style: t.labelStrong.copyWith(color: c.textPrimary),
                      ),
                      if (note != null)
                        Text(
                          note,
                          textAlign: TextAlign.end,
                          style: t.label.copyWith(color: c.textMuted),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

    Widget metric(BodyMetric m) {
      final label = metricLabel(l10n, m);
      return switch (results[m]) {
        Estimated(:final value, :final approximate) => row(
          label,
          _value(l10n, m, value, units),
          spoken: switch (m) {
            BodyMetric.bodyFat => spokenPct(l10n, value),
            BodyMetric.leanMass => spokenWeight(
              l10n,
              units == UnitSystem.metric
                  ? displayMass(value, MassUnit.kg)
                  : lbToKg(displayMass(value, MassUnit.lb)),
              units,
            ),
            _ => null,
          },
          note: [
            if (m == BodyMetric.bodyFat && fatFromScale) l10n.bodyFromScale,
            if (approximate) l10n.bodyApprox,
          ].join(' · ').emptyToNull,
        ),
        final NotEstimable<double> e => row(
          label,
          '—',
          spoken: l10n.bodyNotAvailable,
          note: reasonText(l10n, e),
        ),
        null => const SizedBox.shrink(),
      };
    }

    final pMin = results[BodyMetric.proteinMin]?.valueOrNull;
    final pMax = results[BodyMetric.proteinMax]?.valueOrNull;
    final protein = results[BodyMetric.proteinMin];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final m in [
          BodyMetric.bmi,
          BodyMetric.bodyFat,
          BodyMetric.leanMass,
          BodyMetric.ffmi,
          BodyMetric.bmr,
          BodyMetric.tdee,
          BodyMetric.cut,
          BodyMetric.maintain,
          BodyMetric.gain,
        ])
          metric(m),
        if (pMin != null && pMax != null)
          row(
            l10n.bodyProtein,
            l10n.bodyGrams(
              _n(displayProteinGrams(pMin)),
              _n(displayProteinGrams(pMax)),
            ),
          )
        else if (protein is NotEstimable<double>)
          row(
            l10n.bodyProtein,
            '—',
            spoken: l10n.bodyNotAvailable,
            note: reasonText(l10n, protein),
          ),
      ],
    );
  }
}

extension on String {
  String? get emptyToNull => isEmpty ? null : this;
}
