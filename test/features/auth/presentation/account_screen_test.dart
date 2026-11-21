import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/router.dart';
import 'package:repforge/features/auth/domain/account_preferences.dart';
import 'package:repforge/features/auth/domain/auth_user.dart';
import 'package:repforge/features/home/presentation/home_screen.dart';

import '../fake_auth_repository.dart';
import 'auth_app.dart';

void main() {
  const ada = AuthUser(
    uid: 'u1',
    kind: AuthKind.account,
    email: 'ada@example.com',
    displayName: 'Ada Lovelace',
    providers: {SignInProvider.google},
  );

  Future<AuthApp> open(WidgetTester tester, {AuthUser user = ada}) {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(390, 1400);
    addTearDown(tester.view.reset);
    return AuthApp.pump(
      tester,
      repo: FakeAuthRepository(user: user),
      choiceMade: true,
      location: Routes.account,
    );
  }

  group('AUTH-01 account (09b)', () {
    testWidgets('AC13 shows who I am, initials and backup on', (tester) async {
      await open(tester);
      expect(find.text('Ada Lovelace'), findsOneWidget);
      expect(find.text('ada@example.com'), findsOneWidget);
      expect(find.text('AL'), findsOneWidget);
      expect(find.text('Backup on'), findsOneWidget);
      expect(find.text('Always on'), findsOneWidget);
    });

    testWidgets('AC13 unverified email says backup waits', (tester) async {
      await open(
        tester,
        user: const AuthUser(
          uid: 'e1',
          kind: AuthKind.account,
          email: 'new@b.co',
          providers: {SignInProvider.password},
        ),
      );
      expect(find.text('Backup after you verify'), findsOneWidget);
      expect(find.text('N'), findsOneWidget);
    });

    testWidgets('AC13 switches default on; Continue saves and goes on', (
      tester,
    ) async {
      final app = await open(tester);
      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(5));
      for (final s in tester.widgetList<Switch>(switches)) {
        expect(s.value, isTrue);
      }
      await tester.tap(find.text('Progress photos'));
      await tester.pump();
      await tester.tap(find.text('Reminders on all my devices'));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(
        app.preferences.stored,
        const AccountPreferences(
          backUpPhotos: false,
          remindersEverywhere: false,
        ),
      );
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('AC13 previously saved choices are shown', (tester) async {
      final app = await open(tester);
      app.preferences.stored = const AccountPreferences(syncSettings: false);
      app.container.read(routerProvider).go(Routes.home);
      await tester.pumpAndSettle();
      app.container.read(routerProvider).go(Routes.account);
      await tester.pumpAndSettle();
      final sync = tester.widget<SwitchListTile>(
        find.ancestor(
          of: find.text('Sync settings across devices'),
          matching: find.byType(SwitchListTile),
        ),
      );
      expect(sync.value, isFalse);
    });

    testWidgets('NFR-06 fits at 200 % text, switches labelled', (tester) async {
      final handle = tester.ensureSemantics();
      await AuthApp.pump(
        tester,
        repo: FakeAuthRepository(user: ada),
        choiceMade: true,
        location: Routes.account,
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel(RegExp('^Body metrics')), findsOneWidget);
      handle.dispose();
    });
  });

  group('AUTH-01 AuthUser initials', () {
    test('from name, else email, else empty', () {
      expect(ada.initials, 'AL');
      expect(
        const AuthUser(
          uid: 'x',
          kind: AuthKind.account,
          email: 'j.doe@x.io',
        ).initials,
        'JD',
      );
      expect(const AuthUser(uid: 'x', kind: AuthKind.anonymous).initials, '');
    });
  });
}
