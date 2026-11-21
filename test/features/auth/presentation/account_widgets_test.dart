import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/router.dart';
import 'package:repforge/features/auth/domain/auth_user.dart';
import 'package:repforge/features/auth/presentation/sign_in_screen.dart';
import 'package:repforge/features/auth/presentation/verify_email_banner.dart';
import 'package:repforge/features/onboarding/presentation/welcome_screen.dart';

import '../fake_auth_repository.dart';
import 'auth_app.dart';

void main() {
  const unverified = AuthUser(
    uid: 'e1',
    kind: AuthKind.account,
    email: 'a@b.co',
    providers: {SignInProvider.password},
  );

  group('AUTH-01 verify email notice', () {
    testWidgets('AC5 unverified email users see the notice and can resend', (
      tester,
    ) async {
      final repo = FakeAuthRepository(user: unverified);
      await AuthApp.pump(tester, repo: repo, choiceMade: true);
      expect(find.text('Verify your email'), findsOneWidget);
      expect(find.textContaining('a@b.co'), findsOneWidget);
      expect(repo.refreshes, greaterThan(0));

      await tester.tap(find.text('Resend'));
      await tester.pumpAndSettle();
      expect(repo.calls, contains('resend'));
      expect(find.text('Verification email sent.'), findsOneWidget);
    });

    testWidgets('AC5 the notice goes once verified', (tester) async {
      final repo = FakeAuthRepository(user: unverified);
      await AuthApp.pump(tester, repo: repo, choiceMade: true);
      repo.emit(unverified.copyWith(emailVerified: true));
      await tester.pumpAndSettle();
      expect(find.byType(VerifyEmailBanner), findsOneWidget);
      expect(find.text('Verify your email'), findsNothing);
    });

    testWidgets('AC5 resume re-checks verification', (tester) async {
      final repo = FakeAuthRepository(user: unverified);
      await AuthApp.pump(tester, repo: repo, choiceMade: true);
      final before = repo.refreshes;
      for (final state in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      await tester.pump();
      expect(repo.refreshes, greaterThan(before));
    });

    testWidgets('Google users never see it', (tester) async {
      await AuthApp.pump(
        tester,
        repo: FakeAuthRepository(user: AuthApp.googleUser),
        choiceMade: true,
      );
      expect(find.text('Verify your email'), findsNothing);
    });
  });

  group('AUTH-01 account section', () {
    testWidgets(
      'AC10 sign out warns, then clears and returns to the start (Welcome)',
      (tester) async {
        final repo = FakeAuthRepository(user: AuthApp.googleUser);
        await AuthApp.pump(
          tester,
          repo: repo,
          choiceMade: true,
          location: Routes.profile,
        );
        await tester.tap(find.text('Sign out'));
        await tester.pumpAndSettle();
        expect(
          find.text('Data not yet backed up will be removed from this phone.'),
          findsOneWidget,
        );
        await tester.tap(find.text('Sign out and remove'));
        await tester.pumpAndSettle();
        expect(repo.calls, ['signOut']);
        expect(find.byType(WelcomeScreen), findsOneWidget);
      },
    );

    testWidgets('AC10 cancelling sign out changes nothing', (tester) async {
      final repo = FakeAuthRepository(user: AuthApp.googleUser);
      await AuthApp.pump(
        tester,
        repo: repo,
        choiceMade: true,
        location: Routes.profile,
      );
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(repo.calls, isEmpty);
      expect(find.text('Sign out'), findsOneWidget);
    });

    testWidgets('NFR-06 the sign-out dialog fits at 200 % text', (
      tester,
    ) async {
      await AuthApp.pump(
        tester,
        repo: FakeAuthRepository(user: AuthApp.googleUser),
        choiceMade: true,
        location: Routes.profile,
        textScale: 2,
      );
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Sign out and remove'), findsOneWidget);
    });

    testWidgets('nothing is offered until the user is known', (tester) async {
      await AuthApp.pump(tester, choiceMade: true, location: Routes.profile);
      expect(find.text('Sign out'), findsNothing);
      expect(find.text('Sign in to back up'), findsNothing);
    });

    testWidgets('edge: guests get Sign in to back up, not Sign out', (
      tester,
    ) async {
      final repo = FakeAuthRepository(
        user: const AuthUser(uid: 'anon', kind: AuthKind.anonymous),
      );
      await AuthApp.pump(
        tester,
        repo: repo,
        choiceMade: true,
        location: Routes.profile,
      );
      expect(find.text('Sign out'), findsNothing);
      await tester.tap(find.text('Sign in to back up'));
      await tester.pumpAndSettle();
      expect(find.byType(SignInScreen), findsOneWidget);
    });
  });
}
