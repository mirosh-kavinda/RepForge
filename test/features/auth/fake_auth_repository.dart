import 'dart:async';

import 'package:repforge/features/auth/domain/auth_failure.dart';
import 'package:repforge/features/auth/domain/auth_repository.dart';
import 'package:repforge/features/auth/domain/auth_user.dart';

class FakePending implements PendingCredential {
  const FakePending(this.provider, [this.email]);

  @override
  final SignInProvider provider;

  @override
  final String? email;
}

// Records every call; `results` sets what an action returns (null = success).
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AuthUser? user}) : _user = user;

  final calls = <String>[];
  var refreshes = 0;
  final results = <String, AuthFailure?>{};
  final _users = StreamController<AuthUser?>.broadcast();
  AuthUser? _user;

  // Holds the next action open until completed, to observe busy states.
  Completer<void>? gate;

  // Mirrors the real repository storing (or clearing) the sign-in choice.
  void Function(bool made)? onChoice;

  void emit(AuthUser? user) {
    _user = user;
    _users.add(user);
  }

  Future<AuthFailure?> _record(String call, [AuthUser? onSuccess]) async {
    calls.add(call);
    await gate?.future;
    final failure = results[call.split(':').first];
    if (failure == null && onSuccess != null) {
      emit(onSuccess);
      onChoice?.call(true);
    }
    return failure;
  }

  static const _account = AuthUser(
    uid: 'u1',
    kind: AuthKind.account,
    providers: {SignInProvider.google},
  );

  @override
  AuthUser? get currentUser => _user;

  @override
  Stream<AuthUser?> userChanges() async* {
    yield _user;
    yield* _users.stream;
  }

  @override
  Future<AuthFailure?> continueAsGuest() =>
      _record('guest', const AuthUser(uid: 'anon', kind: AuthKind.anonymous));

  @override
  Future<AuthFailure?> signInWithGoogle() => _record('google', _account);

  @override
  Future<AuthFailure?> signInWithApple() => _record('apple', _account);

  @override
  Future<AuthFailure?> signUpWithEmail(String email, String password) =>
      signInWithEmail(email, password);

  @override
  Future<AuthFailure?> signInWithEmail(String email, String password) =>
      _record(
        'email:$email',
        AuthUser(
          uid: 'e1',
          kind: AuthKind.account,
          email: email,
          providers: const {SignInProvider.password},
        ),
      );

  @override
  Future<AuthFailure?> sendPasswordReset(String email) =>
      _record('reset:$email');

  @override
  Future<AuthFailure?> resendVerification() => _record('resend');

  @override
  Future<void> refresh() async => refreshes++;

  @override
  Future<AuthFailure?> completeExistingAccount(
    PendingCredential pending, {
    required bool keepGuestData,
  }) => _record(keepGuestData ? 'keep' : 'discard', _account);

  @override
  Future<void> signOut() async {
    calls.add('signOut');
    emit(null);
    onChoice?.call(false);
  }
}
