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
import 'user_avatar.dart';

// AC10: temporary home for Sign out until SET-01 builds Settings.
class AccountSection extends ConsumerWidget {
  const AccountSection({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.signOutTitle),
        content: Text(l10n.signOutBody),
        // Stacked full width so both labels fit at 200 % text (NFR-06).
        actions: [
          SizedBox(
            width: double.infinity,
            child: RfButton(
              label: l10n.signOutConfirm,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ),
          const SizedBox(height: RfSpace.s8),
          SizedBox(
            width: double.infinity,
            child: RfButton(
              label: l10n.cancel,
              variant: RfButtonVariant.ghost,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await ref.read(authRepositoryProvider).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider).value;
    // Unknown until Firebase restores the session; show nothing rather than guess.
    if (user == null) return const SizedBox.shrink();
    // Signing a guest out would erase everything, so guests are offered
    // sign-in instead (edge case).
    final guest = user.isGuest;
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    // AC13 edge: with "Use my name and photo" off, initials only, no name.
    final useProfile = ref.watch(useProviderProfileProvider).value ?? true;
    final button = SizedBox(
      width: double.infinity,
      child: guest
          ? RfButton(
              label: l10n.accountBackUp,
              variant: RfButtonVariant.secondary,
              onPressed: () => context.push(Routes.signIn),
            )
          : RfButton(
              label: l10n.accountSignOut,
              variant: RfButtonVariant.secondary,
              onPressed: () => _signOut(context, ref),
            ),
    );
    return Padding(
      padding: const EdgeInsets.all(RfSpace.s16),
      child: Column(
        children: [
          if (!guest) ...[
            Row(
              children: [
                UserAvatar(user: user, showPhoto: useProfile),
                const SizedBox(width: RfSpace.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (useProfile && user.displayName != null)
                        Text(user.displayName!, style: t.labelStrong),
                      if (user.email case final email?)
                        Text(
                          email,
                          style: t.label.copyWith(color: c.textSecondary),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: RfSpace.s16),
          ],
          button,
        ],
      ),
    );
  }
}
