import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/data/sync/remote_store.dart';
import 'package:repforge/data/sync/sync_scheduler.dart';

import 'fake_sync_runner.dart';

void main() {
  late FakeRunner runner;
  late StreamController<SyncUser?> users;
  late StreamController<int> waiting;
  late StreamController<bool> online;
  late StreamController<void> resumes;
  late SyncScheduler scheduler;
  var body = true;

  Future<void> start(WidgetTester tester) async {
    runner = FakeRunner();
    users = StreamController();
    waiting = StreamController();
    online = StreamController();
    resumes = StreamController();
    body = true;
    scheduler = SyncScheduler(
      engine: runner,
      users: users.stream,
      waiting: waiting.stream,
      online: online.stream,
      resumes: resumes.stream,
      bodyBackup: () async => body,
    );
    await tester.pump();
  }

  const me = (uid: 'u1', canBackUp: true);

  group('SYN-01 scheduler', () {
    testWidgets('AC4 signing in pulls, then pushes', (tester) async {
      await start(tester);
      users.add(me);
      await tester.pump();
      expect(runner.calls, ['pull:u1', 'push:u1:body']);
      scheduler.dispose();
    });

    testWidgets('AC1 a change is pushed a few seconds later, once', (
      tester,
    ) async {
      await start(tester);
      users.add(me);
      await tester.pump();
      runner.calls.clear();
      waiting
        ..add(1)
        ..add(2)
        ..add(3);
      await tester.pump(const Duration(seconds: 4));
      expect(runner.calls, isEmpty);
      await tester.pump(const Duration(seconds: 2));
      expect(runner.calls, ['push:u1:body']);
      scheduler.dispose();
    });

    testWidgets('AC4 resume and every 6 hours pull', (tester) async {
      await start(tester);
      users.add(me);
      await tester.pump();
      runner.calls.clear();
      resumes.add(null);
      await tester.pump();
      expect(runner.calls, ['pull:u1', 'push:u1:body']);
      runner.calls.clear();
      await tester.pump(const Duration(hours: 6));
      expect(runner.calls.first, 'pull:u1');
      scheduler.dispose();
    });

    testWidgets('AC6 AC8 guests and unverified accounts never sync', (
      tester,
    ) async {
      await start(tester);
      users.add((uid: 'g', canBackUp: false));
      await tester.pump();
      waiting.add(3);
      await tester.pump(const Duration(minutes: 1));
      expect(runner.calls, isEmpty);
      // AC6: signing in sends what was queued.
      users.add(me);
      await tester.pump();
      expect(runner.calls, contains('push:u1:body'));
      scheduler.dispose();
    });

    testWidgets('AC10 a failure retries after 30 s, pulling too', (
      tester,
    ) async {
      await start(tester);
      runner.failWith = const SyncFailure(SyncErrorKind.server);
      users.add(me);
      await tester.pump();
      expect(runner.error, SyncErrorKind.server);
      runner.failWith = null;
      await tester.pump(const Duration(seconds: 29));
      expect(runner.calls, isEmpty);
      await tester.pump(const Duration(seconds: 2));
      expect(runner.calls, ['pull:u1', 'push:u1:body']);
      scheduler.dispose();
    });

    testWidgets('AC10 offline says so and tries again when back', (
      tester,
    ) async {
      await start(tester);
      online.add(false);
      users.add(me);
      await tester.pump();
      expect(runner.error, SyncErrorKind.offline);
      expect(runner.calls, isEmpty);
      online.add(true);
      await tester.pump();
      expect(runner.calls, ['push:u1:body']);
      scheduler.dispose();
    });

    testWidgets('AC9 Back up now runs at once and resets the wait', (
      tester,
    ) async {
      await start(tester);
      users.add(me);
      await tester.pump();
      runner.calls.clear();
      await scheduler.backUpNow();
      expect(runner.calls, ['pull:u1', 'push:u1:body']);
      scheduler.dispose();
    });

    testWidgets('AC7 the body backup switch reaches the push', (tester) async {
      await start(tester);
      body = false;
      users.add(me);
      await tester.pump();
      expect(runner.calls.last, 'push:u1:nobody');
      body = true;
      await scheduler.backUpNow();
      expect(runner.calls.last, 'push:u1:body');
      scheduler.dispose();
    });

    testWidgets('edge a failed pull still backs up, then retries', (
      tester,
    ) async {
      await start(tester);
      runner.failPullWith = const SyncFailure(SyncErrorKind.server);
      users.add(me);
      await tester.pump();
      expect(runner.calls, ['push:u1:body']);
      expect(runner.error, SyncErrorKind.server);
      scheduler.dispose();
    });

    testWidgets('AC10 the wait doubles from 30 s and stops at 1 h', (
      tester,
    ) async {
      await start(tester);
      runner.failWith = const SyncFailure(SyncErrorKind.server);
      users.add(me);
      await tester.pump();
      expect(runner.pushes, 1);
      // Each retry fails again, so each wait is twice the last.
      for (final (i, wait) in [30, 60, 120, 240, 480, 960, 1920].indexed) {
        await tester.pump(Duration(seconds: wait - 1));
        expect(runner.pushes, i + 1, reason: 'not yet at ${wait}s');
        await tester.pump(const Duration(seconds: 1));
        expect(runner.pushes, i + 2, reason: 'retried at ${wait}s');
      }
      // 3840 s would be next; capped at an hour.
      await tester.pump(const Duration(seconds: 3599));
      expect(runner.pushes, 8);
      await tester.pump(const Duration(seconds: 1));
      expect(runner.pushes, 9);
      scheduler.dispose();
    });

    testWidgets('edge a run stops writing once the account changes', (
      tester,
    ) async {
      await start(tester);
      users.add(me);
      await tester.pump();
      final current = runner.lastCurrent!;
      expect(current(), isTrue);
      users.add(null);
      await tester.pump();
      expect(current(), isFalse);
      scheduler.dispose();
    });
  });
}
