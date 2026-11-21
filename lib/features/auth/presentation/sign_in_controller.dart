import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/providers.dart';
import '../domain/auth_failure.dart';
import '../domain/auth_repository.dart';

part 'sign_in_controller.g.dart';

enum SignInAction { google, apple, email, guest, reset, complete }

class SignInState {
  const SignInState({this.busy, this.failure});

  final SignInAction? busy;
  final AuthFailure? failure;
}

@riverpod
class SignInController extends _$SignInController {
  @override
  SignInState build() => const SignInState();

  // Returns the raw failure so the screen can react to accountExists;
  // a cancelled sheet is never shown as an error (edge case).
  Future<AuthFailure?> run(
    SignInAction action,
    Future<AuthFailure?> Function(AuthRepository repo) call,
  ) async {
    if (state.busy != null) return const AuthFailure.cancelled();
    state = SignInState(busy: action);
    final failure = await call(ref.read(authRepositoryProvider));
    if (!ref.mounted) return failure;
    state = SignInState(
      failure: failure is AuthCancelled || failure is AuthAccountExists
          ? null
          : failure,
    );
    return failure;
  }

  void clear() => state = const SignInState();
}
