import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/app.dart';
import 'package:repforge/app/router.dart';
import 'package:repforge/features/auth/data/providers.dart';
import 'package:repforge/features/auth/presentation/sign_in_screen.dart';
import 'package:repforge/features/home/presentation/home_screen.dart';
import 'package:repforge/features/onboarding/data/providers.dart';
import 'package:repforge/features/onboarding/presentation/goal_level_screen.dart';
import 'package:repforge/features/onboarding/presentation/welcome_screen.dart';

import '../features/auth/fake_auth_repository.dart';
import '../features/onboarding/fake_onboarding_repository.dart';

void main() {
  group('AUTH-01 / ONB-01 app gate', () {
    const no = AsyncData(false);
    const yes = AsyncData(true);
    const loading = AsyncLoading<bool>();

    test('AUTH-01 AC1 ONB-01 AC1 no choice yet: Welcome or Sign in only', () {
      expect(appRedirect(loading, loading, Routes.start), isNull);
      expect(appRedirect(no, loading, Routes.start), Routes.welcome);
      expect(appRedirect(no, no, Routes.home), Routes.welcome);
      expect(appRedirect(no, no, Routes.onboarding), Routes.welcome);
      expect(appRedirect(no, no, Routes.welcome), isNull);
      expect(appRedirect(no, no, Routes.signIn), isNull);
      expect(appRedirect(no, no, Routes.signInEmail), isNull);
    });

    test('ONB-01 AC2 chosen but not onboarded: onboarding only', () {
      expect(appRedirect(yes, loading, Routes.start), isNull);
      expect(appRedirect(yes, no, Routes.start), Routes.onboarding);
      expect(appRedirect(yes, no, Routes.home), Routes.onboarding);
      expect(appRedirect(yes, no, Routes.onboarding), isNull);
      expect(appRedirect(yes, no, Routes.onboardingAbout), isNull);
      // Account (09b) and a just-finished Sign in stay put until they move on.
      expect(appRedirect(yes, no, Routes.account), isNull);
      expect(appRedirect(yes, no, Routes.signIn), isNull);
      expect(appRedirect(yes, yes, Routes.account), isNull);
    });

    test('ONB-01 AC2 onboarded: Home, never onboarding again', () {
      expect(appRedirect(yes, yes, Routes.start), Routes.home);
      expect(appRedirect(yes, yes, Routes.welcome), Routes.home);
      expect(appRedirect(yes, yes, Routes.onboarding), Routes.home);
      expect(appRedirect(yes, yes, Routes.onboardingAbout), Routes.home);
      expect(appRedirect(yes, yes, Routes.home), isNull);
      // A guest may still open Sign in to back up.
      expect(appRedirect(yes, yes, Routes.signIn), isNull);
    });

    Future<StreamController<bool>> pumpGate(
      WidgetTester tester, {
      bool onboarded = true,
    }) async {
      final choice = StreamController<bool>();
      addTearDown(choice.close);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authChoiceMadeProvider.overrideWith((ref) => choice.stream),
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
            onboardingRepositoryProvider.overrideWithValue(
              FakeOnboardingRepository(done: onboarded),
            ),
          ],
          child: const RepForgeApp(),
        ),
      );
      return choice;
    }

    testWidgets('ONB-01 AC1 a fresh install opens on Welcome', (tester) async {
      final choice = await pumpGate(tester, onboarded: false);
      choice.add(false);
      await tester.pumpAndSettle();
      expect(find.byType(WelcomeScreen), findsOneWidget);
      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();
      expect(find.byType(SignInScreen), findsOneWidget);
    });

    testWidgets('ONB-01 AC2 signed in but not onboarded opens step 1', (
      tester,
    ) async {
      final choice = await pumpGate(tester, onboarded: false);
      choice.add(true);
      await tester.pumpAndSettle();
      expect(find.byType(GoalLevelScreen), findsOneWidget);
    });

    testWidgets('AUTH-01 AC1 after a choice and onboarding, Home', (
      tester,
    ) async {
      final choice = await pumpGate(tester);
      choice.add(true);
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('AUTH-01 AC10 clearing the choice returns to Welcome', (
      tester,
    ) async {
      final choice = await pumpGate(tester);
      choice.add(true);
      await tester.pumpAndSettle();
      choice.add(false);
      await tester.pumpAndSettle();
      expect(find.byType(WelcomeScreen), findsOneWidget);
    });
  });
}
