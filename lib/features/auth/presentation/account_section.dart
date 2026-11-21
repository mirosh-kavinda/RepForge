import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/router.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/widgets/rf_button.dart';
import '../data/providers.dart';

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
        actions: [
          RfButton(
            label: l10n.cancel,
            variant: RfButtonVariant.ghost,
            size: RfButtonSize.md,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          RfButton(
            label: l10n.signOutConfirm,
            size: RfButtonSize.md,
            onPressed: () => Navigator.of(context).pop(true),
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
    // Signing a guest out would erase everything, so guests are offered
    // sign-in instead (edge case).
    final guest = user == null || user.isGuest;
    return Padding(
      padding: const EdgeInsets.all(RfSpace.s16),
      child: SizedBox(
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
      ),
    );
  }
}
