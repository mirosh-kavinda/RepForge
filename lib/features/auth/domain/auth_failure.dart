import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth_user.dart';

part 'auth_failure.freezed.dart';

// The credential of an account that already exists, held while the guest
// chooses to keep or discard their data. Opaque outside the data layer.
abstract interface class PendingCredential {
  SignInProvider get provider;
  String? get email;
}

@freezed
sealed class AuthFailure with _$AuthFailure {
  const factory AuthFailure.cancelled() = AuthCancelled;
  const factory AuthFailure.offline() = AuthOffline;
  const factory AuthFailure.wrongPassword() = AuthWrongPassword;
  const factory AuthFailure.weakPassword() = AuthWeakPassword;
  const factory AuthFailure.invalidEmail() = AuthInvalidEmail;
  const factory AuthFailure.accountExists(PendingCredential pending) =
      AuthAccountExists;
  const factory AuthFailure.useProvider(SignInProvider provider) =
      AuthUseProvider;
  const factory AuthFailure.unknown(String code) = AuthUnknown;
}
