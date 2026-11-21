import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/router.dart';
import 'package:repforge/features/auth/domain/auth_failure.dart';
import 'package:repforge/features/auth/domain/auth_user.dart';
import 'package:repforge/features/auth/presentation/account_screen.dart';
import 'package:repforge/features/auth/presentation/email_sign_in_screen.dart';

import '../fake_auth_repository.dart';
import 'auth_app.dart';

void main() {
  group('AUTH-01 email screen', () {
    Future<AuthApp> open(WidgetTester tester, [FakeAuthRepository? repo]) =>
        AuthApp.pump(tester, repo: repo, location: Routes.signInEmail);

    Future<void> fill(
      WidgetTester tester,
      String email,
      String password,
    ) async {
      await tester.enterText(find.byKey(EmailSignInScreen.emailKey), email);
      await tester.enterText(
        find.byKey(EmailSignInScreen.passwordKey),
        password,
      );
    }

    testWidgets('AC3 email + password signs in or creates, then Account', (
      tester,
    ) async {
      final app = await open(tester);
      await fill(tester, 'new@b.co', 'password1');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(app.repo.calls, ['email:new@b.co']);
      expect(find.byType(AccountScreen), findsOneWidget);
    });

    testWidgets('AC3 wrong password shows inline and keeps the email', (
      tester,
    ) async {
      final repo = FakeAuthRepository()
        ..results['email'] = const AuthFailure.wrongPassword();
      await open(tester, repo);
      await fill(tester, 'a@b.co', 'password1');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Wrong password'), findsOneWidget);
      // Edge: also offers the Google route for Google-registered emails.
      expect(find.text('Continue with Google'), findsOneWidget);
      final field = tester.widget<TextField>(
        find.byKey(EmailSignInScreen.emailKey),
      );
      expect(field.controller!.text, 'a@b.co');
      expect(find.byType(EmailSignInScreen), findsOneWidget);
    });

    testWidgets('edge: a Google-registered email is offered Google', (
      tester,
    ) async {
      final repo = FakeAuthRepository()
        ..results['email'] = const AuthFailure.useProvider(
          SignInProvider.google,
        );
      await open(tester, repo);
      await fill(tester, 'g@b.co', 'password1');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.textContaining('registered with Google'), findsOneWidget);
      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();
      expect(repo.calls, ['email:g@b.co', 'google']);
      expect(find.byType(AccountScreen), findsOneWidget);
    });

    testWidgets(
      'AC3 AC8 guest + existing email + wrong password: error after the choice',
      (tester) async {
        final repo = FakeAuthRepository()
          ..results['email'] = const AuthFailure.accountExists(
            FakePending(SignInProvider.password, 'a@b.co'),
          )
          ..results['keep'] = const AuthFailure.wrongPassword();
        await open(tester, repo);
        await fill(tester, 'a@b.co', 'password1');
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Keep my guest data'));
        await tester.pumpAndSettle();
        expect(find.textContaining('Wrong password'), findsOneWidget);
        expect(find.byType(EmailSignInScreen), findsOneWidget);
      },
    );

    testWidgets('NFR-06 email form fits at 200 % text', (tester) async {
      await AuthApp.pump(tester, location: Routes.signInEmail, textScale: 2);
      expect(tester.takeException(), isNull);
      expect(find.byType(EmailSignInScreen), findsOneWidget);
    });

    testWidgets('edge: weak password and bad email show inline errors', (
      tester,
    ) async {
      final repo = FakeAuthRepository()
        ..results['email'] = const AuthFailure.weakPassword();
      await open(tester, repo);
      await fill(tester, 'a@b.co', 'short');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Use at least 8 characters.'), findsOneWidget);

      repo.results['email'] = const AuthFailure.invalidEmail();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid email address.'), findsOneWidget);
    });

    testWidgets('AC4 forgot password shows the same confirmation', (
      tester,
    ) async {
      final app = await open(tester);
      await fill(tester, 'a@b.co', '');
      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();
      expect(app.repo.calls, ['reset:a@b.co']);
      expect(
        find.text("If an account exists for a@b.co, we've sent a reset link."),
        findsOneWidget,
      );
      expect(find.byType(EmailSignInScreen), findsOneWidget);
    });

    testWidgets('AC9 offline email sign-in shows the offline message', (
      tester,
    ) async {
      final repo = FakeAuthRepository()
        ..results['email'] = const AuthFailure.offline();
      await open(tester, repo);
      await fill(tester, 'a@b.co', 'password1');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.textContaining("You're offline"), findsOneWidget);
    });
  });
}
