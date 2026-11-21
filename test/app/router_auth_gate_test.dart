import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/app.dart';
import 'package:repforge/app/router.dart';
import 'package:repforge/features/auth/data/providers.dart';
import 'package:repforge/features/auth/presentation/sign_in_screen.dart';
import 'package:repforge/features/home/presentation/home_screen.dart';

import '../features/auth/fake_auth_repository.dart';

void main() {
  group('AUTH-01 auth gate', () {
    test('AC1 redirect rules', () {
      const loading = AsyncLoading<bool>();
      expect(authRedirect(loading, Routes.start), isNull);
      expect(authRedirect(const AsyncData(false), Routes.start), Routes.signIn);
      expect(authRedirect(const AsyncData(false), Routes.home), Routes.signIn);
      expect(authRedirect(const AsyncData(false), Routes.signIn), isNull);
      expect(authRedirect(const AsyncData(false), Routes.signInEmail), isNull);
      expect(authRedirect(const AsyncData(true), Routes.start), Routes.home);
      expect(authRedirect(const AsyncData(true), Routes.home), isNull);
      // A guest may still open Sign in to back up.
      expect(authRedirect(const AsyncData(true), Routes.signIn), isNull);
    });

    Future<StreamController<bool>> pumpGate(WidgetTester tester) async {
      final choice = StreamController<bool>();
      addTearDown(choice.close);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authChoiceMadeProvider.overrideWith((ref) => choice.stream),
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          ],
          child: const RepForgeApp(),
        ),
      );
      return choice;
    }

    testWidgets('AC1 a fresh install opens on Sign in', (tester) async {
      final choice = await pumpGate(tester);
      choice.add(false);
      await tester.pumpAndSettle();
      expect(find.byType(SignInScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });

    testWidgets('AC1 after a choice, launches go straight to Home', (
      tester,
    ) async {
      final choice = await pumpGate(tester);
      choice.add(true);
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('AC10 clearing the choice returns to Sign in', (tester) async {
      final choice = await pumpGate(tester);
      choice.add(true);
      await tester.pumpAndSettle();
      choice.add(false);
      await tester.pumpAndSettle();
      expect(find.byType(SignInScreen), findsOneWidget);
    });
  });
}
