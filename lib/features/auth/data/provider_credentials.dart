import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// Provider sheets, kept behind an interface so the repository can be tested
// without platform channels. Null means the user cancelled.
abstract interface class ProviderCredentials {
  Future<AuthCredential?> google();

  Future<AuthCredential?> apple();

  Future<void> signOut();
}

class PlatformProviderCredentials implements ProviderCredentials {
  PlatformProviderCredentials({required String serverClientId})
    : _serverClientId = serverClientId;

  final String _serverClientId;
  Future<void>? _googleReady;

  @override
  Future<AuthCredential?> google() async {
    _googleReady ??= GoogleSignIn.instance.initialize(
      serverClientId: _serverClientId.isEmpty ? null : _serverClientId,
    );
    await _googleReady;
    try {
      final account = await GoogleSignIn.instance.authenticate();
      return GoogleAuthProvider.credential(
        idToken: account.authentication.idToken,
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  @override
  Future<AuthCredential?> apple() async {
    final rawNonce = _nonce();
    try {
      final apple = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email],
        nonce: sha256.convert(utf8.encode(rawNonce)).toString(),
      );
      return OAuthProvider('apple.com').credential(
        idToken: apple.identityToken,
        rawNonce: rawNonce,
        accessToken: apple.authorizationCode,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return null;
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    if (_googleReady != null) await GoogleSignIn.instance.signOut();
  }

  static String _nonce() {
    final random = Random.secure();
    return base64Url.encode(List.generate(32, (_) => random.nextInt(256)));
  }
}
