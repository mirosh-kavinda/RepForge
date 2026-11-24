import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/ids.dart';
import '../../../data/local/local_data_wiper.dart';
import '../domain/auth_failure.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';
import '../domain/email_rules.dart';
import 'auth_local_store.dart';
import 'provider_credentials.dart';

class FirebaseAuthRepository implements AuthRepository {
  // `auth` resolves to null when this build has no Firebase config; the app
  // then behaves as permanently offline and guests stay local.
  FirebaseAuthRepository({
    required Future<FirebaseAuth?> auth,
    required ProviderCredentials providers,
    required AuthLocalStore store,
    required LocalDataWiper wiper,
    required Future<bool> Function() isOnline,
  }) : _auth = auth,
       _providers = providers,
       _store = store,
       _wiper = wiper,
       _isOnline = isOnline;

  final Future<FirebaseAuth?> _auth;
  final ProviderCredentials _providers;
  final AuthLocalStore _store;
  final LocalDataWiper _wiper;
  final Future<bool> Function() _isOnline;

  final _users = StreamController<AuthUser?>.broadcast();
  StreamSubscription<User?>? _sub;
  AuthUser? _current;

  @override
  AuthUser? get currentUser => _current;

  @override
  Stream<AuthUser?> userChanges() async* {
    yield _current;
    yield* _users.stream;
  }

  Future<void> start() async {
    final localId = await _store.localGuestId();
    if (localId != null) _emit(AuthUser.localGuest(id: localId));
    final auth = await _auth;
    if (auth == null) return;
    _sub = auth.userChanges().listen((user) async {
      if (user != null) return _emit(_map(user));
      final id = await _store.localGuestId();
      _emit(id == null ? null : AuthUser.localGuest(id: id));
    });
    await upgradeLocalGuest();
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _users.close();
  }

  // AC6: an offline guest becomes anonymous the first time the app is online.
  Future<void> upgradeLocalGuest() async {
    final auth = await _auth;
    if (auth == null || auth.currentUser != null) return;
    if (await _store.localGuestId() == null || !await _isOnline()) return;
    try {
      await auth.signInAnonymously();
      await _store.clearLocalGuestId();
    } on FirebaseAuthException {
      // Still a local guest; the next online moment tries again.
    }
  }

  // A local guest must be anonymous before signing in, so linking (AC7) or
  // the keep/discard choice (AC8) applies. If that fails, stop rather than
  // sign in past the guest's data.
  Future<AuthFailure?> _upgradeBeforeSignIn() async {
    if (await _store.localGuestId() == null) return null;
    await upgradeLocalGuest();
    return await _store.localGuestId() == null
        ? null
        : const AuthFailure.offline();
  }

  @override
  Future<bool> isOnline() async => await _onlineAuth() != null;

  @override
  Future<AuthFailure?> continueAsGuest() async {
    final auth = await _isOnline() ? await _auth : null;
    if (auth != null) {
      try {
        await auth.signInAnonymously();
        await _store.setChoiceMade();
        return null;
      } on FirebaseAuthException catch (e) {
        if (_mapError(e) is! AuthOffline) return _mapError(e);
      }
    }
    final id = newId();
    await _store.setLocalGuestId(id);
    _emit(AuthUser.localGuest(id: id));
    await _store.setChoiceMade();
    return null;
  }

  @override
  Future<AuthFailure?> signInWithGoogle() =>
      _withProvider(SignInProvider.google, _providers.google);

  @override
  Future<AuthFailure?> signInWithApple() =>
      _withProvider(SignInProvider.apple, _providers.apple);

  Future<AuthFailure?> _withProvider(
    SignInProvider provider,
    Future<AuthCredential?> Function() sheet,
  ) async {
    final auth = await _onlineAuth();
    if (auth == null) return const AuthFailure.offline();
    final AuthCredential? credential;
    try {
      credential = await sheet();
    } on Object catch (e) {
      return e is FirebaseAuthException
          ? _mapError(e, provider)
          : AuthFailure.unknown('$e');
    }
    if (credential == null) return const AuthFailure.cancelled();
    return _signIn(auth, credential, provider);
  }

  @override
  Future<AuthFailure?> signUpWithEmail(String email, String password) =>
      signInWithEmail(email, password);

  // One form for both (AC3): sign in if the account exists, else create it.
  // Guests link instead, so their uid and data stay the same (AC7).
  @override
  Future<AuthFailure?> signInWithEmail(String email, String password) async {
    final invalid = validateEmailForm(email: email, password: password);
    if (invalid != null) return invalid;
    final auth = await _onlineAuth();
    if (auth == null) return const AuthFailure.offline();
    final address = normaliseEmail(email);
    final credential = EmailAuthProvider.credential(
      email: address,
      password: password,
    );
    final notUpgraded = await _upgradeBeforeSignIn();
    if (notUpgraded != null) return notUpgraded;
    final guest = auth.currentUser;
    if (guest != null && guest.isAnonymous) {
      final failure = await _signIn(auth, credential, SignInProvider.password);
      if (failure == null) await _sendVerification(auth);
      return failure;
    }
    try {
      await auth.signInWithEmailAndPassword(email: address, password: password);
      await _finishSignIn();
      return null;
    } on FirebaseAuthException catch (e) {
      final failure = _mapError(e);
      if (failure is! AuthWrongPassword && e.code != 'user-not-found') {
        return failure;
      }
    }
    try {
      await auth.createUserWithEmailAndPassword(
        email: address,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      return e.code == 'email-already-in-use'
          ? const AuthFailure.wrongPassword()
          : _mapError(e);
    }
    await _sendVerification(auth);
    await _finishSignIn();
    return null;
  }

  @override
  Future<AuthFailure?> sendPasswordReset(String email) async {
    final invalid = validateResetEmail(email);
    if (invalid != null) return invalid;
    final auth = await _onlineAuth();
    if (auth == null) return const AuthFailure.offline();
    try {
      await auth.sendPasswordResetEmail(email: normaliseEmail(email));
    } on FirebaseAuthException catch (e) {
      // AC4: the same confirmation whether or not the email is registered.
      if (e.code != 'user-not-found') return _mapError(e);
    }
    return null;
  }

  @override
  Future<AuthFailure?> resendVerification() async {
    final auth = await _onlineAuth();
    if (auth == null) return const AuthFailure.offline();
    return _sendVerification(auth);
  }

  @override
  Future<void> refresh() async {
    final auth = await _auth;
    final user = auth?.currentUser;
    if (user == null) return;
    try {
      await user.reload();
      final fresh = auth!.currentUser;
      if (fresh != null) _emit(_map(fresh));
    } on FirebaseAuthException {
      // Offline or expired: keep the last known state.
    }
  }

  @override
  Future<AuthFailure?> completeExistingAccount(
    PendingCredential pending, {
    required bool keepGuestData,
  }) async {
    final auth = await _onlineAuth();
    if (auth == null) return const AuthFailure.offline();
    final guestUid = auth.currentUser?.uid ?? await _store.localGuestId();
    try {
      await auth.signInWithCredential(
        (pending as FirebasePendingCredential).credential,
      );
    } on FirebaseAuthException catch (e) {
      return _mapError(e);
    }
    // Only after the sign-in succeeded, so a wrong password never costs data.
    if (keepGuestData) {
      if (guestUid != null) await _store.setPendingMergeFrom(guestUid);
    } else {
      await _wiper.wipeUserData();
    }
    await _finishSignIn();
    return null;
  }

  @override
  Future<void> signOut() async {
    // Signed out first, so a sync run in progress stops writing; the wipe
    // then runs after any page already being written (SYN-02 edge).
    _emit(null);
    await _wiper.wipeUserData();
    try {
      await (await _auth)?.signOut();
      await _providers.signOut();
    } on Object {
      // Local state is already clean; the gate returns to Sign in regardless.
    }
  }

  Future<AuthFailure?> _signIn(
    FirebaseAuth auth,
    AuthCredential credential,
    SignInProvider provider,
  ) async {
    final notUpgraded = await _upgradeBeforeSignIn();
    if (notUpgraded != null) return notUpgraded;
    try {
      final guest = auth.currentUser;
      if (guest != null && guest.isAnonymous) {
        await guest.linkWithCredential(credential);
      } else {
        await auth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use' ||
          e.code == 'email-already-in-use') {
        return AuthFailure.accountExists(
          FirebasePendingCredential(
            e.credential ?? credential,
            provider,
            e.email,
          ),
        );
      }
      return _mapError(e, provider);
    }
    await _finishSignIn();
    return null;
  }

  Future<void> _finishSignIn() async {
    await _store.clearLocalGuestId();
    await _store.setChoiceMade();
    final user = (await _auth)?.currentUser;
    if (user != null) _emit(_map(user));
  }

  Future<AuthFailure?> _sendVerification(FirebaseAuth auth) async {
    try {
      await auth.currentUser?.sendEmailVerification();
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e);
    }
  }

  Future<FirebaseAuth?> _onlineAuth() async =>
      await _isOnline() ? await _auth : null;

  void _emit(AuthUser? user) {
    _current = user;
    if (!_users.isClosed) _users.add(user);
  }

  static AuthUser _map(User user) => AuthUser(
    uid: user.uid,
    kind: user.isAnonymous ? AuthKind.anonymous : AuthKind.account,
    email: user.email,
    displayName: user.displayName,
    photoUrl: user.photoURL,
    emailVerified: user.emailVerified,
    providers: {
      for (final info in user.providerData)
        ?switch (info.providerId) {
          'google.com' => SignInProvider.google,
          'apple.com' => SignInProvider.apple,
          'password' => SignInProvider.password,
          _ => null,
        },
    },
  );

  // `attempted` names the provider just tried, so a clash points to the other.
  static AuthFailure _mapError(
    FirebaseAuthException e, [
    SignInProvider? attempted,
  ]) => switch (e.code) {
    'network-request-failed' => const AuthFailure.offline(),
    'wrong-password' ||
    'invalid-credential' ||
    'user-not-found' => const AuthFailure.wrongPassword(),
    'weak-password' => const AuthFailure.weakPassword(),
    'invalid-email' => const AuthFailure.invalidEmail(),
    'account-exists-with-different-credential' => AuthFailure.useProvider(
      attempted == SignInProvider.google
          ? SignInProvider.apple
          : SignInProvider.google,
    ),
    'user-cancelled' ||
    'web-context-cancelled' => const AuthFailure.cancelled(),
    _ => AuthFailure.unknown(e.code),
  };
}

class FirebasePendingCredential implements PendingCredential {
  FirebasePendingCredential(this.credential, this.provider, this.email);

  final AuthCredential credential;

  @override
  final SignInProvider provider;

  @override
  final String? email;
}
