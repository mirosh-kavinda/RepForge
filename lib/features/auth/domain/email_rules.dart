import 'auth_failure.dart';

const minPasswordLength = 8;

final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

String normaliseEmail(String email) => email.trim().toLowerCase();

AuthFailure? validateResetEmail(String email) =>
    _email.hasMatch(normaliseEmail(email))
    ? null
    : const AuthFailure.invalidEmail();

AuthFailure? validateEmailForm({
  required String email,
  required String password,
}) =>
    validateResetEmail(email) ??
    (password.length < minPasswordLength
        ? const AuthFailure.weakPassword()
        : null);
