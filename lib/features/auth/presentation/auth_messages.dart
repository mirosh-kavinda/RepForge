import 'package:flutter/material.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../domain/auth_failure.dart';
import '../domain/auth_user.dart';

String? authMessage(AppLocalizations l10n, AuthFailure? failure) =>
    switch (failure) {
      null || AuthCancelled() || AuthAccountExists() => null,
      AuthOffline() => l10n.authOffline,
      AuthWrongPassword() => l10n.authWrongPassword,
      AuthWeakPassword() => l10n.authWeakPassword,
      AuthInvalidEmail() => l10n.authInvalidEmail,
      AuthUseProvider(provider: SignInProvider.apple) => l10n.authUseApple,
      AuthUseProvider() => l10n.authUseGoogle,
      AuthUnknown() => l10n.authUnknown,
    };

// Icon + text, so the error never relies on colour alone (NFR-06).
class AuthMessage extends StatelessWidget {
  const AuthMessage(this.text, {this.icon = Icons.error_outline, super.key});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: RfSpace.s8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: c.missedInk, size: RfSpace.s20),
            const SizedBox(width: RfSpace.s8),
            Expanded(
              child: Text(text, style: t.body.copyWith(color: c.textPrimary)),
            ),
          ],
        ),
      ),
    );
  }
}
