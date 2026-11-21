import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/router.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_button.dart';
import '../domain/auth_failure.dart';
import 'auth_messages.dart';
import 'sign_in_controller.dart';
import 'sign_in_flow.dart';

// Screen 09 (AC2, AC6, AC9, AC14).
class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final state = ref.watch(signInControllerProvider);
    final message = authMessage(l10n, state.failure);
    final busy = state.busy != null;
    // AC2: Apple is offered on iPhone only.
    final showApple = defaultTargetPlatform == TargetPlatform.iOS;

    Future<void> email() async {
      final controller = ref.read(signInControllerProvider.notifier);
      // AC9: email needs the network too, so say so here.
      final failure = await controller.run(
        SignInAction.email,
        (r) async => await r.isOnline() ? null : const AuthFailure.offline(),
      );
      if (failure == null && context.mounted) {
        controller.clear();
        await context.push(Routes.signInEmail);
      }
    }

    Widget benefit(
      IconData icon,
      Color tint,
      Color ink,
      String title,
      String body,
    ) => Padding(
      padding: const EdgeInsets.only(bottom: RfSpace.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: RfSpace.s32 + RfSpace.s4,
            height: RfSpace.s32 + RfSpace.s4,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(RfRadius.md),
            ),
            child: Icon(icon, size: RfSpace.s20, color: ink),
          ),
          const SizedBox(width: RfSpace.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.labelStrong),
                Text(body, style: t.label.copyWith(color: c.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );

    Widget option(SignInAction action, String label, VoidCallback onTap) =>
        RfButton(
          label: label,
          size: RfButtonSize.md,
          variant: RfButtonVariant.ghost,
          loading: state.busy == action,
          onPressed: busy ? null : onTap,
        );

    return Scaffold(
      appBar: AppBar(
        leading: context.canPop()
            ? null
            : BackButton(onPressed: () => context.go(Routes.welcome)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  RfSpace.s20,
                  0,
                  RfSpace.s20,
                  RfSpace.s12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(l10n.signInHeadline, style: t.title),
                    ),
                    const SizedBox(height: RfSpace.s16),
                    benefit(
                      Icons.cloud_outlined,
                      c.successTint,
                      c.successOnTint,
                      l10n.signInBenefitBackup,
                      l10n.signInBenefitBackupBody,
                    ),
                    benefit(
                      Icons.devices_outlined,
                      c.restTint,
                      c.restOnTint,
                      l10n.signInBenefitRestore,
                      l10n.signInBenefitRestoreBody,
                    ),
                    benefit(
                      Icons.auto_awesome_outlined,
                      c.actionTint,
                      c.actionOnTint,
                      l10n.signInBenefitPersonal,
                      l10n.signInBenefitPersonalBody,
                    ),
                    if (message != null) AuthMessage(message),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                RfSpace.s20,
                0,
                RfSpace.s20,
                RfSpace.s16,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: RfButton(
                      label: l10n.signInGoogle,
                      loading: state.busy == SignInAction.google,
                      onPressed: busy
                          ? null
                          : () => runSignIn(
                              context,
                              ref,
                              SignInAction.google,
                              (r) => r.signInWithGoogle(),
                            ),
                    ),
                  ),
                  const SizedBox(height: RfSpace.s8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        l10n.signInOtherOptions,
                        style: t.label.copyWith(color: c.textSecondary),
                      ),
                      if (showApple)
                        option(
                          SignInAction.apple,
                          l10n.signInAppleShort,
                          () => runSignIn(
                            context,
                            ref,
                            SignInAction.apple,
                            (r) => r.signInWithApple(),
                          ),
                        ),
                      option(SignInAction.email, l10n.signInEmailShort, email),
                    ],
                  ),
                  // AC6, AC9: always available, whatever else failed.
                  Semantics(
                    button: true,
                    enabled: !busy,
                    label: '${l10n.signInSkip}. ${l10n.signInSkipNote}',
                    onTap: busy
                        ? null
                        : () => runSignIn(
                            context,
                            ref,
                            SignInAction.guest,
                            (r) => r.continueAsGuest(),
                          ),
                    excludeSemantics: true,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(RfRadius.md),
                      onTap: busy
                          ? null
                          : () => runSignIn(
                              context,
                              ref,
                              SignInAction.guest,
                              (r) => r.continueAsGuest(),
                            ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: RfSize.minTarget,
                          minWidth: double.infinity,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: RfSpace.s4,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(l10n.signInSkip, style: t.labelStrong),
                              Text(
                                l10n.signInSkipNote,
                                textAlign: TextAlign.center,
                                style: t.label.copyWith(color: c.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: RfSpace.s8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: RfSpace.s16,
                        color: c.textSecondary,
                      ),
                      const SizedBox(width: RfSpace.s8),
                      Flexible(
                        child: Text(
                          l10n.signInPrivacy,
                          style: t.label.copyWith(color: c.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
