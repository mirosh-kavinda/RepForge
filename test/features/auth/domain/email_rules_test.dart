import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/features/auth/domain/auth_failure.dart';
import 'package:repforge/features/auth/domain/email_rules.dart';

void main() {
  group('AUTH-01 email rules', () {
    test('edge: malformed email is rejected before any network call', () {
      for (final bad in ['', 'a', 'a@', '@b.co', 'a@b', 'a b@c.co']) {
        expect(
          validateEmailForm(email: bad, password: 'longenough'),
          const AuthFailure.invalidEmail(),
          reason: bad,
        );
      }
    });

    test('edge: passwords under 8 characters are rejected', () {
      expect(
        validateEmailForm(email: 'a@b.co', password: '1234567'),
        const AuthFailure.weakPassword(),
      );
    });

    test('a valid email and password pass; surrounding spaces are trimmed', () {
      expect(
        validateEmailForm(email: ' a@b.co ', password: '12345678'),
        isNull,
      );
      expect(normaliseEmail(' A@B.co '), 'a@b.co');
    });

    test('AC4 reset needs only a valid email', () {
      expect(validateResetEmail('a@b.co'), isNull);
      expect(validateResetEmail('nope'), const AuthFailure.invalidEmail());
    });
  });
}
