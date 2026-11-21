import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';

enum AuthKind { localGuest, anonymous, account }

enum SignInProvider { google, apple, password }

@freezed
abstract class AuthUser with _$AuthUser {
  const AuthUser._();

  const factory AuthUser({
    required String uid,
    required AuthKind kind,
    String? email,
    String? displayName,
    String? photoUrl,
    @Default(false) bool emailVerified,
    @Default(<SignInProvider>{}) Set<SignInProvider> providers,
  }) = _AuthUser;

  // Offline guest: a device-made id until the first online moment upgrades it.
  factory AuthUser.localGuest({required String id}) =>
      AuthUser(uid: id, kind: AuthKind.localGuest);

  bool get isGuest => kind != AuthKind.account;

  bool get needsEmailVerification =>
      kind == AuthKind.account &&
      !emailVerified &&
      !providers.any((p) => p != SignInProvider.password);

  bool get canBackUp => kind == AuthKind.account && !needsEmailVerification;

  // Up to two initials from the name, else the email; '' if neither (AC13).
  String get initials {
    final source = (displayName?.trim().isNotEmpty ?? false)
        ? displayName!.trim()
        : (email ?? '').split('@').first;
    final words = source
        .split(RegExp(r'[\s._-]+'))
        .where((w) => w.isNotEmpty)
        .toList();
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }
}
