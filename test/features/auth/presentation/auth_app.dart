import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/app.dart';
import 'package:repforge/app/router.dart';
import 'package:repforge/features/auth/data/providers.dart';
import 'package:repforge/features/auth/domain/auth_user.dart';

import '../fake_auth_repository.dart';

// Pumps the real app and router with a fake repository. `choiceMade` mirrors
// the stored choice: successes in the fake flip it, as the real repo does.
class AuthApp {
  AuthApp(this.repo, this.choice, this.container);

  final FakeAuthRepository repo;
  final StreamController<bool> choice;
  final ProviderContainer container;

  static Future<AuthApp> pump(
    WidgetTester tester, {
    FakeAuthRepository? repo,
    bool choiceMade = false,
    String? location,
    double textScale = 1,
  }) async {
    final auth = repo ?? FakeAuthRepository();
    final choice = StreamController<bool>.broadcast();
    addTearDown(choice.close);
    auth.onChoice = choice.add;
    var current = choiceMade;
    final container = ProviderContainer(
      overrides: [
        authChoiceMadeProvider.overrideWith((ref) async* {
          yield current;
          yield* choice.stream.map((v) => current = v);
        }),
        authRepositoryProvider.overrideWithValue(auth),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MediaQuery.withClampedTextScaling(
          minScaleFactor: textScale,
          maxScaleFactor: textScale,
          child: const RepForgeApp(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (location != null) {
      container.read(routerProvider).go(location);
      await tester.pumpAndSettle();
    }
    return AuthApp(auth, choice, container);
  }

  static const googleUser = AuthUser(
    uid: 'u1',
    kind: AuthKind.account,
    providers: {SignInProvider.google},
  );
}
