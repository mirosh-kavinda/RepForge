import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:repforge/app/app.dart';
import 'package:repforge/app/router.dart';
import 'package:repforge/app/widgets/rf_button.dart';
import 'package:repforge/core/clock.dart';
import 'package:repforge/data/sync/providers.dart';
import 'package:repforge/data/sync/remote_store.dart';
import 'package:repforge/data/sync/restore.dart';
import 'package:repforge/features/auth/data/providers.dart';
import 'package:repforge/features/auth/presentation/restore_card.dart';
import 'package:repforge/features/home/presentation/home_screen.dart';
import 'package:repforge/features/library/data/providers.dart';

import '../../../helpers/app_overrides.dart';
import '../../../helpers/static_today.dart';
import '../../library/library_fakes.dart';
import '../fake_account_preferences_store.dart';

class FakeRestore implements RestoreActions {
  var restored = 0;
  var fresh = 0;
  Object? failWith;

  @override
  Future<bool> restore() async {
    if (failWith case final e?) throw e;
    restored++;
    return true;
  }

  @override
  Future<void> startFresh() async => fresh++;
}

late FakeRestore actions;

Future<void> openAccount(
  WidgetTester tester, {
  bool hasBackup = true,
  bool online = true,
  RestoreProgress? restoring,
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);
  actions = FakeRestore();
  final container = ProviderContainer(
    overrides: [
      ...signedInOverrides(
        restoring: restoring,
        backup: hasBackup
            ? (newest: DateTime.utc(2026, 11, 20, 12), workouts: 12)
            : null,
      ),
      accountPreferencesStoreProvider.overrideWithValue(
        FakeAccountPreferencesStore(),
      ),
      onlineProvider.overrideWith((ref) => Stream.value(online)),
      restoreControllerProvider.overrideWithValue(actions),
      exerciseCatalogProvider.overrideWith((ref) async => LibraryCatalog()),
      clockProvider.overrideWithValue(() => DateTime(2026, 11, 24, 8)),
      staticToday,
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const RepForgeApp()),
  );
  await tester.pumpAndSettle();
  container.read(routerProvider).go(Routes.account);
  await tester.pumpAndSettle();
}

Future<void> tapCard(WidgetTester tester, Key key) async {
  await tester.scrollUntilVisible(
    find.byKey(key),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(find.byKey(key));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(key));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => initializeDateFormatting('en'));

  group('SYN-02 restore card', () {
    testWidgets('AC1 the backup is described', (tester) async {
      await openAccount(tester);
      expect(find.text('Backup from Nov 20, 2026'), findsOneWidget);
      expect(find.text('12 workouts'), findsOneWidget);
    });

    testWidgets('AC2 AC5 Restore brings the essentials, then Home', (
      tester,
    ) async {
      await openAccount(tester);
      await tapCard(tester, RestoreCard.restoreKey);
      expect(actions.restored, 1);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('AC6 Start fresh downloads nothing and goes on', (
      tester,
    ) async {
      await openAccount(tester);
      await tapCard(tester, RestoreCard.freshKey);
      expect((actions.fresh, actions.restored), (1, 0));
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('AC10 offline: Restore waits; Start fresh still works', (
      tester,
    ) async {
      await openAccount(tester, online: false);
      expect(find.text('Restore needs a connection.'), findsOneWidget);
      expect(
        tester.widget<RfButton>(find.byKey(RestoreCard.restoreKey)).onPressed,
        isNull,
      );
      expect(
        tester.widget<RfButton>(find.byKey(RestoreCard.freshKey)).onPressed,
        isNotNull,
      );
    });

    testWidgets('a failed restore says so and can be tried again', (
      tester,
    ) async {
      await openAccount(tester);
      actions.failWith = const SyncFailure(SyncErrorKind.server);
      await tapCard(tester, RestoreCard.restoreKey);
      expect(find.text("Couldn't reach your backup."), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('edge no backup: no card', (tester) async {
      await openAccount(tester, hasBackup: false);
      expect(find.byType(RestoreCard), findsOneWidget);
      expect(find.text('Restore'), findsNothing);
    });

    testWidgets('AC3 Home says history is still coming', (tester) async {
      await openAccount(tester, restoring: (done: 40, total: 120));
      await tapCard(tester, RestoreCard.freshKey);
      expect(find.text('Restoring your history…'), findsOneWidget);
    });
  });
}
