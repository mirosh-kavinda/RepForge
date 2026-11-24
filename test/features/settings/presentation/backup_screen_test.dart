import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:repforge/app/l10n/generated/app_localizations.dart';
import 'package:repforge/app/widgets/rf_button.dart';
import 'package:repforge/data/sync/providers.dart';
import 'package:repforge/data/sync/remote_store.dart';
import 'package:repforge/data/sync/restore.dart';
import 'package:repforge/data/sync/sync_engine.dart';
import 'package:repforge/data/sync/sync_scheduler.dart';
import 'package:repforge/features/auth/domain/auth_user.dart';
import 'package:repforge/features/auth/presentation/restore_card.dart';
import 'package:repforge/features/settings/presentation/backup_screen.dart';
import 'package:repforge/features/settings/presentation/profile_screen.dart';

import '../../../data/sync/fake_sync_runner.dart';
import '../../auth/fake_auth_repository.dart';
import '../settings_app.dart';

final now = DateTime(2026, 11, 24, 8);

Future<void> openBackup(
  WidgetTester tester, {
  SyncStatus status = (backedUpAt: null, waiting: 0, error: null),
  AuthUser? user,
  FakeRunner? runner,
  double textScale = 1,
  RestoreProgress? restoring,
  bool backup = false,
}) async {
  final r = runner ?? FakeRunner();
  final me =
      user ??
      const AuthUser(
        uid: 'u1',
        kind: AuthKind.account,
        providers: {SignInProvider.google},
      );
  final scheduler = SyncScheduler(
    engine: r,
    users: Stream.value((uid: me.uid, canBackUp: me.canBackUp)),
    waiting: const Stream.empty(),
    online: const Stream.empty(),
    resumes: const Stream.empty(),
    bodyBackup: () async => true,
  );
  await pumpProfile(
    tester,
    sync: status,
    restoring: restoring,
    backup: backup ? (newest: DateTime.utc(2026, 11, 20), workouts: 3) : null,
    auth: FakeAuthRepository(user: me),
    extra: [syncSchedulerProvider.overrideWithValue(scheduler)],
    textScale: textScale,
  );
  await scrollTo(tester, find.byKey(ProfileScreen.backupKey));
  await tester.ensureVisible(find.byKey(ProfileScreen.backupKey));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(ProfileScreen.backupKey));
  await tester.pumpAndSettle();
  scheduler.dispose();
}

void main() {
  setUpAll(() => initializeDateFormatting('en'));

  group('SYN-01 backup screen', () {
    testWidgets('AC9 not backed up yet; nothing waiting', (tester) async {
      await openBackup(tester);
      expect(find.text('Not backed up yet'), findsOneWidget);
      expect(find.text('Everything is backed up'), findsOneWidget);
    });

    testWidgets('AC9 last backed up and changes waiting', (tester) async {
      await openBackup(
        tester,
        status: (
          backedUpAt: now.subtract(const Duration(minutes: 5)),
          waiting: 3,
          error: null,
        ),
      );
      expect(find.text('Backed up 5 min ago'), findsOneWidget);
      expect(find.text('3 changes waiting'), findsOneWidget);
    });

    testWidgets('AC10 a failure says why, in words', (tester) async {
      await openBackup(
        tester,
        status: (backedUpAt: null, waiting: 1, error: SyncErrorKind.offline),
      );
      expect(
        find.text("Can't back up right now: will try again"),
        findsOneWidget,
      );
      expect(find.text('No connection'), findsOneWidget);
    });

    testWidgets('AC9 Back up now runs a backup', (tester) async {
      final runner = FakeRunner();
      await openBackup(tester, runner: runner);
      runner.calls.clear();
      await tester.tap(find.byKey(BackupScreen.nowKey));
      await tester.pumpAndSettle();
      expect(runner.calls, ['pull:u1', 'push:u1:body']);
    });

    testWidgets('AC6 AC8 guests and unverified accounts are told why', (
      tester,
    ) async {
      await openBackup(tester, user: AuthUser.localGuest(id: 'g'));
      expect(find.text('Sign in to back up your training'), findsOneWidget);
      expect(
        tester.widget<RfButton>(find.byKey(BackupScreen.nowKey)).onPressed,
        isNull,
      );
    });

    testWidgets('NFR-06 fits at 200 % text', (tester) async {
      await openBackup(tester, textScale: 2);
      expect(tester.takeException(), isNull);
    });
  });

  test('SYN-01 AC9 "backed up" wording by age', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    String at(Duration ago) => backedUpText(l10n, 'en', now.subtract(ago), now);
    expect(at(const Duration(seconds: 20)), 'Backed up just now');
    expect(at(const Duration(minutes: 1)), 'Backed up 1 min ago');
    expect(at(const Duration(hours: 3)), 'Backed up 3 hours ago');
    expect(at(const Duration(days: 2)), 'Backed up Nov 22, 2026');
    expect(backedUpText(l10n, 'en', null, now), 'Not backed up yet');
  });

  testWidgets('SYN-02 AC3 restore progress shows while it runs', (
    tester,
  ) async {
    await openBackup(tester, restoring: (done: 40, total: 120));
    expect(find.text('Restoring: 40 of 120'), findsOneWidget);
  });

  testWidgets('SYN-02 AC1 the restore card is here while undecided', (
    tester,
  ) async {
    await openBackup(tester, backup: true);
    expect(find.byType(RestoreCard), findsOneWidget);
    expect(find.text('Restore'), findsOneWidget);
  });
}
