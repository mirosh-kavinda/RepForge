import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/router.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/theme/theme_mode.dart';
import '../../../app/widgets/rf_button.dart';
import '../../../app/widgets/rf_segmented.dart';
import '../../../app/widgets/rf_stepper.dart';
import '../../../core/metrics/units.dart';
import '../../auth/presentation/account_section.dart';
import '../../workout/presentation/template_format.dart';
import '../data/providers.dart';
import '../domain/settings.dart';
import 'plates_text.dart';

// Screen 23: the AUTH-01 account section, then Settings (SET-01 AC1).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const restKey = ValueKey('settings.rest');
  static const platesKey = ValueKey('settings.plates');
  static const reminderKey = ValueKey('settings.reminder');

  Future<void> _write(
    BuildContext context,
    Future<void> Function() write,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await write();
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.settingsSaveFailed)));
    }
  }

  Future<void> _editRest(
    BuildContext context,
    WidgetRef ref,
    int current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(settingsRepositoryProvider);
    var value = current;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        final t = RfTextStyles.of(context);
        final c = RfColors.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              RfSpace.s20,
              0,
              RfSpace.s20,
              RfSpace.s20,
            ),
            child: StatefulBuilder(
              builder: (context, setState) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.settingsRest, style: t.heading),
                  const SizedBox(height: RfSpace.s12),
                  RfStepper(
                    label: l10n.settingsRest,
                    value: value.toDouble(),
                    step: restStepSec.toDouble(),
                    min: 0,
                    max: maxRestSec.toDouble(),
                    format: (v) => restText(v.round()),
                    onChanged: (v) => setState(() => value = v.round()),
                  ),
                  const SizedBox(height: RfSpace.s8),
                  Text(
                    l10n.settingsRestHint,
                    style: t.label.copyWith(color: c.textSecondary),
                  ),
                  const SizedBox(height: RfSpace.s16),
                  RfButton(
                    label: l10n.settingsDone,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (value != current && context.mounted) {
      await _write(context, () => repo.setDefaultRest(value));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final settings =
        ref.watch(trainingSettingsProvider).value ?? const TrainingSettings();
    final reminder = ref.watch(reminderPrefProvider).value;
    final theme = ref.watch(appThemeModeProvider);
    final repo = ref.read(settingsRepositoryProvider);
    final u = settings.units;

    Widget row(Key key, String title, String value, VoidCallback onTap) =>
        ListTile(
          key: key,
          minTileHeight: RfSize.minTarget,
          contentPadding: EdgeInsets.zero,
          title: Text(title, style: t.body.copyWith(color: c.textPrimary)),
          subtitle: Text(
            value,
            style: t.label.copyWith(color: c.textSecondary),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabProfile)),
      body: ListView(
        children: [
          const AccountSection(),
          Padding(
            padding: const EdgeInsets.all(RfSpace.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(l10n.settingsTitle, style: t.heading),
                ),
                const SizedBox(height: RfSpace.s12),
                RfSegmented<UnitSystem>(
                  label: l10n.settingsUnits,
                  allowNone: false,
                  options: {
                    UnitSystem.metric: l10n.settingsUnitsMetric,
                    UnitSystem.imperial: l10n.settingsUnitsImperial,
                  },
                  selected: u,
                  onChanged: (v) {
                    if (v != null && v != u) {
                      _write(context, () => repo.setUnits(v));
                    }
                  },
                ),
                const SizedBox(height: RfSpace.s16),
                RfSegmented<ThemeMode>(
                  label: l10n.settingsTheme,
                  allowNone: false,
                  options: {
                    ThemeMode.system: l10n.settingsThemeSystem,
                    ThemeMode.light: l10n.settingsThemeLight,
                    ThemeMode.dark: l10n.settingsThemeDark,
                  },
                  selected: theme,
                  onChanged: (v) {
                    if (v != null) {
                      _write(
                        context,
                        () => ref.read(appThemeModeProvider.notifier).set(v),
                      );
                    }
                  },
                ),
                const SizedBox(height: RfSpace.s8),
                row(
                  restKey,
                  l10n.settingsRest,
                  restText(settings.restSec),
                  () => _editRest(context, ref, settings.restSec),
                ),
                row(
                  platesKey,
                  l10n.settingsPlates,
                  l10n.settingsPlatesSummary(
                    plateWeight(l10n, inUnit(settings.barKg(u), u), u),
                    settings.platesKg(u).length,
                  ),
                  () => context.push(Routes.plates),
                ),
                row(
                  reminderKey,
                  l10n.settingsReminder,
                  reminder == null || !reminder.on
                      ? l10n.settingsReminderOff
                      : l10n.settingsReminderOn(
                          reminderTime(context, reminder.minutes),
                        ),
                  () => context.push(Routes.reminder),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
