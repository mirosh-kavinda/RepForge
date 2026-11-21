import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/app.dart';
import 'package:repforge/features/auth/data/providers.dart';
import 'package:repforge/features/auth/presentation/sign_in_screen.dart';
import 'package:repforge/features/onboarding/data/providers.dart';
import 'package:repforge/features/onboarding/presentation/welcome_screen.dart';

import '../../auth/fake_auth_repository.dart';
import '../fake_onboarding_repository.dart';

void main() {
  group('ONB-01 welcome', () {
    Future<void> pump(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authChoiceMadeProvider.overrideWith((ref) => Stream.value(false)),
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
            onboardingRepositoryProvider.overrideWithValue(
              FakeOnboardingRepository(),
            ),
          ],
          child: const RepForgeApp(),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('AC1 shows tagline, features and both entry buttons', (
      tester,
    ) async {
      await pump(tester);
      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.text('Beat your last set.'), findsOneWidget);
      expect(find.textContaining('Rolling cycles'), findsOneWidget);
      expect(find.textContaining('Ghost Sets'), findsOneWidget);
      expect(find.textContaining('Body Snapshot'), findsOneWidget);
      expect(find.text('Get started'), findsOneWidget);
      expect(find.text('I already have an account'), findsOneWidget);
    });

    for (final button in ['Get started', 'I already have an account']) {
      testWidgets('AC1 "$button" opens Sign in', (tester) async {
        await pump(tester);
        await tester.tap(find.text(button));
        await tester.pumpAndSettle();
        expect(find.byType(SignInScreen), findsOneWidget);
      });
    }
  });
}
