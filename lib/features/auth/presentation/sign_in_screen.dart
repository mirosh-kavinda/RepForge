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

// Screen 09.
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

    Widget button(
      SignInAction action,
      String label,
      VoidCallback onPressed, {
      RfButtonVariant variant = RfButtonVariant.secondary,
    }) => Padding(
      padding: const EdgeInsets.only(bottom: RfSpace.s12),
      child: SizedBox(
        width: double.infinity,
        child: RfButton(
          label: label,
          variant: variant,
          loading: state.busy == action,
          onPressed: busy ? null : onPressed,
        ),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(RfSpace.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: RfSpace.s32),
              Semantics(
                header: true,
                child: Text(l10n.signInHeadline, style: t.title),
              ),
              const SizedBox(height: RfSpace.s12),
              Text(
                l10n.signInBody,
                style: t.body.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: RfSpace.s32),
              button(
                SignInAction.google,
                l10n.signInGoogle,
                () => runSignIn(
                  context,
                  ref,
                  SignInAction.google,
                  (r) => r.signInWithGoogle(),
                ),
              ),
              if (showApple)
                button(
                  SignInAction.apple,
                  l10n.signInApple,
                  () => runSignIn(
                    context,
                    ref,
                    SignInAction.apple,
                    (r) => r.signInWithApple(),
                  ),
                ),
              // AC9: the email option needs the network too, so say so here.
              button(SignInAction.email, l10n.signInEmail, () async {
                final controller = ref.read(signInControllerProvider.notifier);
                final failure = await controller.run(
                  SignInAction.email,
                  (r) async =>
                      await r.isOnline() ? null : const AuthFailure.offline(),
                );
                if (failure == null && context.mounted) {
                  controller.clear();
                  await context.push(Routes.signInEmail);
                }
              }),
              if (message != null) AuthMessage(message),
              const SizedBox(height: RfSpace.s12),
              // AC9: guest stays available whatever else failed.
              button(
                SignInAction.guest,
                l10n.signInGuest,
                () => runSignIn(
                  context,
                  ref,
                  SignInAction.guest,
                  (r) => r.continueAsGuest(),
                ),
                variant: RfButtonVariant.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
