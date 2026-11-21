import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/theme/rf_scales.dart';
import 'package:repforge/features/auth/domain/auth_failure.dart';
import 'package:repforge/features/auth/domain/auth_user.dart';
import 'package:repforge/features/auth/presentation/email_sign_in_screen.dart';
import 'package:repforge/features/auth/presentation/existing_account_dialog.dart';
import 'package:repforge/features/auth/presentation/sign_in_screen.dart';
import 'package:repforge/features/home/presentation/home_screen.dart';

import '../fake_auth_repository.dart';
import 'auth_app.dart';

void main() {
  group('AUTH-01 sign in screen', () {
    testWidgets('AC2 Google signs in and lands on Home', (tester) async {
      final app = await AuthApp.pump(tester);
      expect(find.byType(SignInScreen), findsOneWidget);
      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();
      expect(app.repo.calls, ['google']);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('AC2 Apple is not offered on Android', (tester) async {
      await AuthApp.pump(tester);
      expect(find.text('Continue with Apple'), findsNothing);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with email'), findsOneWidget);
    });

    testWidgets('AC2 Apple is offered on iPhone', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final app = await AuthApp.pump(tester);
      await tester.tap(find.text('Continue with Apple'));
      await tester.pumpAndSettle();
      expect(app.repo.calls, ['apple']);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('AC6 Continue as guest enters Home', (tester) async {
      final app = await AuthApp.pump(tester);
      await tester.tap(find.text('Continue as guest'));
      await tester.pumpAndSettle();
      expect(app.repo.calls, ['guest']);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('AC9 offline shows a clear message; guest stays available', (
      tester,
    ) async {
      final repo = FakeAuthRepository()
        ..results['google'] = const AuthFailure.offline();
      await AuthApp.pump(tester, repo: repo);
      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();
      expect(find.textContaining("You're offline"), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byType(SignInScreen), findsOneWidget);

      await tester.tap(find.text('Continue as guest'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('edge: cancelling the provider sheet shows nothing', (
      tester,
    ) async {
      final repo = FakeAuthRepository()
        ..results['google'] = const AuthFailure.cancelled();
      await AuthApp.pump(tester, repo: repo);
      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.error_outline), findsNothing);
      expect(find.byType(SignInScreen), findsOneWidget);
    });

    testWidgets('buttons are busy and disabled while a sign-in runs', (
      tester,
    ) async {
      final repo = FakeAuthRepository()..gate = Completer<void>();
      await AuthApp.pump(tester, repo: repo);
      await tester.tap(find.text('Continue with Google'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.text('Continue as guest'));
      await tester.pump();
      expect(repo.calls, ['google']);
      repo.gate!.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('Email opens the email form', (tester) async {
      await AuthApp.pump(tester);
      await tester.tap(find.text('Continue with email'));
      await tester.pumpAndSettle();
      expect(find.byType(EmailSignInScreen), findsOneWidget);
    });

    group('AC8 existing account', () {
      Future<FakeAuthRepository> clash(WidgetTester tester) async {
        final repo =
            FakeAuthRepository(
                user: const AuthUser(uid: 'anon', kind: AuthKind.anonymous),
              )
              ..results['google'] = const AuthFailure.accountExists(
                FakePending(SignInProvider.google),
              );
        await AuthApp.pump(tester, repo: repo);
        await tester.tap(find.text('Continue with Google'));
        await tester.pumpAndSettle();
        expect(find.byType(ExistingAccountDialog), findsOneWidget);
        return repo;
      }

      testWidgets('keep signs in and keeps guest data', (tester) async {
        final repo = await clash(tester);
        await tester.tap(find.text('Keep my guest data'));
        await tester.pumpAndSettle();
        expect(repo.calls, ['google', 'keep']);
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('discard signs in and discards guest data', (tester) async {
        final repo = await clash(tester);
        await tester.tap(find.text('Discard guest data'));
        await tester.pumpAndSettle();
        expect(repo.calls, ['google', 'discard']);
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('cancel leaves them a guest on Sign in', (tester) async {
        final repo = await clash(tester);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(repo.calls, ['google']);
        expect(find.byType(SignInScreen), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsNothing);
      });
    });

    testWidgets('NFR-06 every action is a labelled button ≥ 48 dp at 200 %', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await AuthApp.pump(tester, textScale: 2);
      for (final label in [
        'Continue with Google',
        'Continue with email',
        'Continue as guest',
      ]) {
        final node = find.bySemanticsLabel(label);
        expect(node, findsOneWidget, reason: label);
        final size = tester.getSize(node);
        expect(size.height, greaterThanOrEqualTo(RfSize.minTarget));
      }
      expect(tester.takeException(), isNull);
      handle.dispose();
    });
  });
}
