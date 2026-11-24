import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_stepper.dart';
import '../../../core/metrics/units.dart';
import '../data/providers.dart';
import '../domain/settings.dart';
import 'plates_text.dart';

// SET-01 AC5: the bar and the plates I own, for the display unit.
class PlatesScreen extends ConsumerWidget {
  const PlatesScreen({super.key});

  static ValueKey<String> plateKey(double v) => ValueKey('plates.$v');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final s = ref.watch(trainingSettingsProvider).value;
    if (s == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.settingsPlates)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final u = s.units;
    final metric = u == UnitSystem.metric;
    final bar = inUnit(s.barKg(u), u);
    final owned = {for (final p in s.platesKg(u)) inUnit(p, u)};
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(settingsRepositoryProvider);

    Future<void> save(double barValue, Set<double> plates) async {
      try {
        await repo.setPlates(u, toKg(barValue, u), [
          for (final p in plateChoices(u))
            if (plates.contains(p)) toKg(p, u),
        ]);
      } on Object {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.settingsSaveFailed)),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsPlates)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(RfSpace.s16),
          children: [
            RfStepper(
              label: l10n.platesBar,
              value: bar,
              step: metric ? 2.5 : 5,
              min: 0,
              max: metric ? 50 : 100,
              unit: metric ? l10n.unitKg : l10n.unitLb,
              onChanged: (v) => save(v, owned),
            ),
            const SizedBox(height: RfSpace.s16),
            Semantics(
              header: true,
              child: Text(
                l10n.platesOwned,
                style: t.heading.copyWith(color: c.textPrimary),
              ),
            ),
            const SizedBox(height: RfSpace.s8),
            for (final p in plateChoices(u))
              SwitchListTile(
                key: plateKey(p),
                contentPadding: EdgeInsets.zero,
                title: Text(
                  l10n.platesPlate(plateWeight(l10n, p, u)),
                  style: t.body.copyWith(color: c.textPrimary),
                ),
                value: owned.contains(p),
                onChanged: (on) {
                  if (!on && owned.length == 1 && owned.contains(p)) {
                    messenger.showSnackBar(
                      SnackBar(content: Text(l10n.platesKeepOne)),
                    );
                    return;
                  }
                  save(bar, on ? {...owned, p} : ({...owned}..remove(p)));
                },
              ),
          ],
        ),
      ),
    );
  }
}
