import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/generated/app_localizations.dart';
import '../../../app/theme/rf_scales.dart';
import '../../../app/theme/rf_tokens.dart';
import '../../../app/theme/rf_typography.dart';
import '../../../app/widgets/rf_button.dart';
import '../domain/auth_failure.dart';
import '../domain/auth_user.dart';
import 'auth_messages.dart';
import 'sign_in_controller.dart';
import 'sign_in_flow.dart';

// AC3, AC4: one form signs in or creates the account; reset from the same email.
class EmailSignInScreen extends ConsumerStatefulWidget {
  const EmailSignInScreen({super.key});

  static const emailKey = ValueKey('email.email');
  static const passwordKey = ValueKey('email.password');

  @override
  ConsumerState<EmailSignInScreen> createState() => _EmailSignInScreenState();
}

class _EmailSignInScreenState extends ConsumerState<EmailSignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _resetSentTo;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() {
    setState(() => _resetSentTo = null);
    return runSignIn(
      context,
      ref,
      SignInAction.email,
      (r) => r.signInWithEmail(_email.text, _password.text),
    );
  }

  Future<void> _reset() async {
    setState(() => _resetSentTo = null);
    final email = _email.text.trim();
    final failure = await ref
        .read(signInControllerProvider.notifier)
        .run(SignInAction.reset, (r) => r.sendPasswordReset(email));
    if (failure == null && mounted) setState(() => _resetSentTo = email);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = RfColors.of(context);
    final t = RfTextStyles.of(context);
    final state = ref.watch(signInControllerProvider);
    final busy = state.busy != null;
    final message = authMessage(l10n, state.failure);
    final offerGoogle = switch (state.failure) {
      AuthWrongPassword() => true,
      AuthUseProvider(provider: SignInProvider.google) => true,
      _ => false,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.emailTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(RfSpace.s24),
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  key: EmailSignInScreen.emailKey,
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: l10n.emailField),
                ),
                const SizedBox(height: RfSpace.s16),
                TextField(
                  key: EmailSignInScreen.passwordKey,
                  controller: _password,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  onSubmitted: busy ? null : (_) => _submit(),
                  decoration: InputDecoration(labelText: l10n.passwordField),
                ),
                const SizedBox(height: RfSpace.s8),
                Text(
                  l10n.emailNewHint,
                  style: t.label.copyWith(color: c.textSecondary),
                ),
                if (message != null) AuthMessage(message),
                // Edge: the email may belong to a Google account; offer it.
                if (offerGoogle)
                  SizedBox(
                    width: double.infinity,
                    child: RfButton(
                      label: l10n.signInGoogle,
                      variant: RfButtonVariant.secondary,
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
                if (_resetSentTo != null)
                  AuthMessage(
                    l10n.resetSent(_resetSentTo!),
                    icon: Icons.mark_email_read_outlined,
                  ),
                const SizedBox(height: RfSpace.s24),
                SizedBox(
                  width: double.infinity,
                  child: RfButton(
                    label: l10n.emailSubmit,
                    loading:
                        state.busy == SignInAction.email ||
                        state.busy == SignInAction.complete,
                    onPressed: busy ? null : _submit,
                  ),
                ),
                const SizedBox(height: RfSpace.s12),
                SizedBox(
                  width: double.infinity,
                  child: RfButton(
                    label: l10n.forgotPassword,
                    variant: RfButtonVariant.ghost,
                    loading: state.busy == SignInAction.reset,
                    onPressed: busy ? null : _reset,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
