import 'auth_failure.dart';
import 'auth_user.dart';

// Every action returns null on success or the failure to show; nothing throws.
abstract interface class AuthRepository {
  Stream<AuthUser?> userChanges();

  AuthUser? get currentUser;

  Future<AuthFailure?> continueAsGuest();

  Future<AuthFailure?> signInWithGoogle();

  Future<AuthFailure?> signInWithApple();

  Future<AuthFailure?> signUpWithEmail(String email, String password);

  Future<AuthFailure?> signInWithEmail(String email, String password);

  Future<AuthFailure?> sendPasswordReset(String email);

  Future<AuthFailure?> resendVerification();

  // Reloads the user so a verification done elsewhere shows up (AC5).
  Future<void> refresh();

  Future<AuthFailure?> completeExistingAccount(
    PendingCredential pending, {
    required bool keepGuestData,
  });

  Future<void> signOut();
}
