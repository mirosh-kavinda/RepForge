import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../core/metrics/units.dart';
import '../../settings/data/providers.dart';
import '../../settings/domain/plates.dart';
import '../../settings/domain/settings.dart';
import '../../settings/presentation/plates_text.dart';

// SET-01 AC6, AC7: the plates for [kg] on each side, with my bar and plates.
Future<void> showPlatesSheet(
  BuildContext context, {
  required double kg,
  required UnitSystem units,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (_) => PlatesSheet(kg: kg, units: units),
);

class PlatesSheet extends ConsumerWidget {
  const PlatesSheet({required this.kg, required this.units, super.key});

  final double kg;
  final UnitSystem units;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final s =
        ref.watch(trainingSettingsProvider).value ?? const TrainingSettings();
    // Edge: the display unit's own bar and plates.
    final load = loadPlates(
      weight: inUnit(kg, units),
      bar: inUnit(s.barKg(units), units),
      plates: [for (final p in s.platesKg(units)) inUnit(p, units)],
    );
    final lines = plateLines(l10n, load, units);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          RfSpace.s20,
          0,
          RfSpace.s20,
          RfSpace.s24,
        ),
        child: Semantics(
          container: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.platesFor(plateWeight(l10n, inUnit(kg, units), units)),
                style: t.heading.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: RfSpace.s12),
              for (final (i, line) in lines.indexed)
                Text(
                  line,
                  style: i == 0
                      ? t.body.copyWith(color: c.textPrimary)
                      : t.label.copyWith(color: c.textSecondary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
