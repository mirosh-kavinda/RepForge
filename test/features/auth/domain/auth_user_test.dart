import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/features/auth/domain/auth_user.dart';

void main() {
  group('AUTH-01 AuthUser', () {
    test('AC6 guests can never back up', () {
      expect(AuthUser.localGuest(id: 'l').canBackUp, isFalse);
      expect(
        const AuthUser(uid: 'a', kind: AuthKind.anonymous).canBackUp,
        isFalse,
      );
    });

    test('AC5 unverified email accounts cannot back up until verified', () {
      const unverified = AuthUser(
        uid: 'u',
        kind: AuthKind.account,
        email: 'a@b.co',
        providers: {SignInProvider.password},
      );
      expect(unverified.canBackUp, isFalse);
      expect(unverified.needsEmailVerification, isTrue);
      final verified = unverified.copyWith(emailVerified: true);
      expect(verified.canBackUp, isTrue);
      expect(verified.needsEmailVerification, isFalse);
    });

    test('AC2 Google and Apple accounts can back up without verification', () {
      for (final p in [SignInProvider.google, SignInProvider.apple]) {
        final user = AuthUser(uid: 'u', kind: AuthKind.account, providers: {p});
        expect(user.canBackUp, isTrue, reason: p.name);
        expect(user.needsEmailVerification, isFalse);
      }
    });

    test('AC7 a linked account with a verified provider can back up', () {
      const user = AuthUser(
        uid: 'u',
        kind: AuthKind.account,
        providers: {SignInProvider.password, SignInProvider.google},
      );
      expect(user.canBackUp, isTrue);
    });

    test('isGuest covers anonymous and local guests', () {
      expect(AuthUser.localGuest(id: 'l').isGuest, isTrue);
      expect(
        const AuthUser(uid: 'a', kind: AuthKind.anonymous).isGuest,
        isTrue,
      );
      expect(const AuthUser(uid: 'a', kind: AuthKind.account).isGuest, isFalse);
    });
  });
}
