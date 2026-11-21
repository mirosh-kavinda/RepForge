import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../data/providers.dart';
import '../domain/auth_failure.dart';
import '../domain/auth_repository.dart';
import 'existing_account_dialog.dart';
import 'sign_in_controller.dart';

// Shared by the Sign in and Email screens: runs an action, asks keep/discard
// when the account already exists (AC8), and goes Home on success.
Future<void> runSignIn(
  BuildContext context,
  WidgetRef ref,
  SignInAction action,
  Future<AuthFailure?> Function(AuthRepository repo) call,
) async {
  final controller = ref.read(signInControllerProvider.notifier);
  final failure = await controller.run(action, call);
  if (!context.mounted) return;
  if (failure is AuthAccountExists) {
    final keep = await showExistingAccountDialog(context);
    if (keep == null || !context.mounted) return;
    final done = await controller.run(
      SignInAction.complete,
      (repo) =>
          repo.completeExistingAccount(failure.pending, keepGuestData: keep),
    );
    if (done == null && context.mounted) await _goHome(context, ref);
    return;
  }
  if (failure == null) await _goHome(context, ref);
}

// The stored choice reaches the router through a stream; going Home before it
// arrives would be redirected straight back to Sign in.
Future<void> _goHome(BuildContext context, WidgetRef ref) async {
  if (!(ref.read(authChoiceMadeProvider).value ?? false)) {
    final made = Completer<void>();
    final sub = ref.listenManual(authChoiceMadeProvider, (_, next) {
      if ((next.value ?? false) && !made.isCompleted) made.complete();
    });
    await made.future.timeout(const Duration(seconds: 2), onTimeout: () {});
    sub.close();
  }
  if (context.mounted) context.go(Routes.home);
}
