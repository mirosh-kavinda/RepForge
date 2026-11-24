import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/router.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_button.dart';
import '../data/providers.dart';
import '../domain/account_preferences.dart';
import 'auth_messages.dart';
import 'restore_card.dart';
import 'user_avatar.dart';

// Screen 09b (AC13), with the SYN-02 restore card.
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  AccountPreferences _prefs = const AccountPreferences();
  var _saving = false;
  var _failed = false;
  // A late load must not undo switches the user already flipped.
  var _touched = false;

  @override
  void initState() {
    super.initState();
    ref.read(accountPreferencesStoreProvider).load().then((p) {
      if (mounted && !_touched) setState(() => _prefs = p);
    });
  }

  Future<void> _continue() async {
    setState(() {
      _saving = true;
      _failed = false;
    });
    try {
      await ref.read(accountPreferencesStoreProvider).save(_prefs);
    } on Object {
      if (mounted) {
        setState(() {
          _saving = false;
          _failed = true;
        });
      }
      return;
    }
    // Home redirects to onboarding when it isn't done yet.
    if (mounted) context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final user = ref.watch(currentUserProvider).value;

    Widget section(String title, List<Widget> rows) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: RfSpace.s16),
        Semantics(
          header: true,
          child: Text(
            title.toUpperCase(),
            style: t.overline.copyWith(color: c.textSecondary),
          ),
        ),
        const SizedBox(height: RfSpace.s8),
        Material(
          color: c.surface,
          borderRadius: BorderRadius.circular(RfRadius.lg),
          clipBehavior: Clip.antiAlias,
          child: Column(children: rows),
        ),
      ],
    );

    Widget toggle(
      String title,
      String hint,
      bool value,
      AccountPreferences Function(bool on) change,
    ) => SwitchListTile(
      title: Text(title, style: t.body),
      subtitle: Text(hint, style: t.label.copyWith(color: c.textSecondary)),
      value: value,
      onChanged: (on) => setState(() {
        _touched = true;
        _prefs = change(on);
      }),
    );

    final verified = user?.canBackUp ?? false;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: RfSpace.s20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(RfSpace.s16),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(RfRadius.lg),
                    ),
                    child: Row(
                      children: [
                        UserAvatar(user: user, showPhoto: true),
                        const SizedBox(width: RfSpace.s12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (user?.displayName case final name?)
                                Text(name, style: t.labelStrong),
                              if (user?.email case final email?)
                                Text(
                                  email,
                                  style: t.label.copyWith(
                                    color: c.textSecondary,
                                  ),
                                ),
                              const SizedBox(height: RfSpace.s8),
                              // Under the name so it wraps at narrow widths
                              // and 200 % text.
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: RfSpace.s8,
                                  vertical: RfSpace.s4,
                                ),
                                decoration: BoxDecoration(
                                  color: verified ? c.successTint : c.restTint,
                                  borderRadius: BorderRadius.circular(
                                    RfRadius.pill,
                                  ),
                                ),
                                child: Text(
                                  verified
                                      ? l10n.accountBackupOn
                                      : l10n.accountBackupAfterVerify,
                                  style: t.label.copyWith(
                                    color: verified
                                        ? c.successOnTint
                                        : c.restOnTint,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // SYN-02: only when this account has a backup to offer.
                  RestoreCard(onDone: _continue),
                  section(l10n.accountSectionBackUp, [
                    ListTile(
                      title: Text(l10n.accountWorkouts, style: t.body),
                      subtitle: Text(
                        l10n.accountWorkoutsHint,
                        style: t.label.copyWith(color: c.textSecondary),
                      ),
                      trailing: Text(
                        l10n.accountAlwaysOn,
                        style: t.label.copyWith(color: c.textSecondary),
                      ),
                    ),
                    toggle(
                      l10n.accountBodyMetrics,
                      l10n.accountBodyMetricsHint,
                      _prefs.backUpBodyMetrics,
                      (on) => _prefs.copyWith(backUpBodyMetrics: on),
                    ),
                    toggle(
                      l10n.accountPhotos,
                      l10n.accountPhotosHint,
                      _prefs.backUpPhotos,
                      (on) => _prefs.copyWith(backUpPhotos: on),
                    ),
                  ]),
                  section(l10n.accountSectionPersonalise, [
                    toggle(
                      l10n.accountUseProfile,
                      l10n.accountUseProfileHint,
                      _prefs.useProviderProfile,
                      (on) => _prefs.copyWith(useProviderProfile: on),
                    ),
                    toggle(
                      l10n.accountSyncSettings,
                      l10n.accountSyncSettingsHint,
                      _prefs.syncSettings,
                      (on) => _prefs.copyWith(syncSettings: on),
                    ),
                    toggle(
                      l10n.accountReminders,
                      l10n.accountRemindersHint,
                      _prefs.remindersEverywhere,
                      (on) => _prefs.copyWith(remindersEverywhere: on),
                    ),
                  ]),
                  if (_failed) AuthMessage(l10n.accountSaveFailed),
                  const SizedBox(height: RfSpace.s16),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                RfSpace.s20,
                0,
                RfSpace.s20,
                RfSpace.s24,
              ),
              child: SizedBox(
                width: double.infinity,
                child: RfButton(
                  label: l10n.onbContinue,
                  loading: _saving,
                  onPressed: _saving ? null : _continue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
