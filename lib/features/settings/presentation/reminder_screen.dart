import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../schedule/data/providers.dart';
import '../data/providers.dart';
import '../domain/settings.dart';
import 'plates_text.dart';

// SET-01 AC8, AC10, edge: on / off, the time, and why nothing would fire.
class ReminderScreen extends ConsumerStatefulWidget {
  const ReminderScreen({super.key});

  static const switchKey = ValueKey('reminder.switch');
  static const timeKey = ValueKey('reminder.time');
  static const openSettingsKey = ValueKey('reminder.openSettings');

  @override
  ConsumerState<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends ConsumerState<ReminderScreen>
    with WidgetsBindingObserver {
  bool? _allowed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Back from the phone's settings.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    final ok = await ref.read(workoutReminderProvider).allowed();
    if (mounted) setState(() => _allowed = ok);
  }

  Future<void> _save(ReminderPref pref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(settingsRepositoryProvider).setReminder(pref);
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.settingsSaveFailed)));
    }
  }

  Future<void> _toggle(ReminderPref pref, bool on) async {
    await _save(pref.copyWith(on: on));
    if (!on) return;
    final reminder = ref.read(workoutReminderProvider);
    // AC10: asks once; the switch stays on either way.
    final ok = await reminder.allowed() || await reminder.request();
    if (mounted) setState(() => _allowed = ok);
  }

  Future<void> _pickTime(ReminderPref pref) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: pref.minutes ~/ 60,
        minute: pref.minutes % 60,
      ),
    );
    if (picked != null) {
      await _save(pref.copyWith(minutes: picked.hour * 60 + picked.minute));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final pref = ref.watch(reminderPrefProvider).value;
    final cycle = ref.watch(activeCycleProvider);

    Widget note(String text) => Padding(
      padding: const EdgeInsets.only(top: RfSpace.s8),
      child: Text(text, style: t.body.copyWith(color: c.textSecondary)),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsReminder)),
      body: SafeArea(
        child: pref == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(RfSpace.s16),
                children: [
                  SwitchListTile(
                    key: ReminderScreen.switchKey,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      l10n.reminderSwitch,
                      style: t.body.copyWith(color: c.textPrimary),
                    ),
                    value: pref.on,
                    onChanged: (on) => _toggle(pref, on),
                  ),
                  ListTile(
                    key: ReminderScreen.timeKey,
                    minTileHeight: RfSize.minTarget,
                    contentPadding: EdgeInsets.zero,
                    enabled: pref.on,
                    title: Text(
                      l10n.reminderTime,
                      style: t.body.copyWith(color: c.textPrimary),
                    ),
                    subtitle: Text(
                      reminderTime(context, pref.minutes),
                      style: t.label.copyWith(color: c.textSecondary),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _pickTime(pref),
                  ),
                  if (pref.on && _allowed == false) ...[
                    note(l10n.reminderNeedsNotifications),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton(
                        key: ReminderScreen.openSettingsKey,
                        style: TextButton.styleFrom(
                          minimumSize: const Size(
                            RfSize.minTarget,
                            RfSize.minTarget,
                          ),
                        ),
                        onPressed: () =>
                            ref.read(workoutReminderProvider).openSettings(),
                        child: Text(l10n.restOpenSettings),
                      ),
                    ),
                  ],
                  if (pref.on && cycle.hasValue && cycle.value == null)
                    note(l10n.reminderNoCycle),
                ],
              ),
      ),
    );
  }
}
