import 'package:flutter_riverpod/misc.dart';
import 'package:repforge/features/auth/data/providers.dart';
import 'package:repforge/features/auth/domain/auth_user.dart';
import 'package:repforge/features/onboarding/data/providers.dart';

import '../features/auth/fake_auth_repository.dart';
import '../features/onboarding/fake_onboarding_repository.dart';

// App-level tests start past the AUTH-01 and ONB-01 gates, as a signed-in,
// onboarded Google user.
List<Override> signedInOverrides({FakeAuthRepository? auth}) => [
  authChoiceMadeProvider.overrideWith((ref) => Stream.value(true)),
  onboardingRepositoryProvider.overrideWithValue(
    FakeOnboardingRepository(done: true),
  ),
  authRepositoryProvider.overrideWithValue(
    auth ??
        FakeAuthRepository(
          user: const AuthUser(
            uid: 'u1',
            kind: AuthKind.account,
            providers: {SignInProvider.google},
          ),
        ),
  ),
];
