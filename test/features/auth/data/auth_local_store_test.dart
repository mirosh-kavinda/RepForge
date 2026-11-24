import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/data/local/app_database.dart';
import 'package:repforge/features/auth/data/auth_local_store.dart';
import 'package:repforge/features/auth/domain/account_preferences.dart';

void main() {
  late AppDatabase db;
  late AuthLocalStore store;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    store = AuthLocalStore(db);
  });
  tearDown(() => db.close());

  group('AUTH-01 auth local store', () {
    test(
      'AC1 a fresh install has made no choice; the choice persists',
      () async {
        expect(await store.choiceMade(), isFalse);
        await store.setChoiceMade();
        expect(await store.choiceMade(), isTrue);
        expect(await AuthLocalStore(db).choiceMade(), isTrue);
      },
    );

    test('AC1 choice changes are watchable for the router', () async {
      final seen = <bool>[];
      final sub = store.watchChoiceMade().listen(seen.add);
      await pumpEventQueue();
      await store.setChoiceMade();
      await pumpEventQueue();
      await store.clearChoice();
      await pumpEventQueue();
      await sub.cancel();
      expect(seen, [false, true, false]);
    });

    test('AC6 local guest id is stored until cleared', () async {
      expect(await store.localGuestId(), isNull);
      await store.setLocalGuestId('g1');
      expect(await store.localGuestId(), 'g1');
      await store.clearLocalGuestId();
      expect(await store.localGuestId(), isNull);
    });

    test(
      'AC8 kept guest data is flagged for merge with the guest uid',
      () async {
        expect(await store.pendingMergeFrom(), isNull);
        await store.setPendingMergeFrom('anon-uid');
        expect(await store.pendingMergeFrom(), 'anon-uid');
      },
    );
  });

  group('SYN-01 AC7 body backup switch', () {
    test('turning it back on queues the profile again', () async {
      await db
          .into(db.userProfiles)
          .insert(
            UserProfilesCompanion.insert(
              id: const Value('p'),
              units: 'metric',
              updatedAt: DateTime.utc(2026, 11),
            ),
          );
      const off = AccountPreferences(backUpBodyMetrics: false);
      await store.save(off);
      expect(await db.select(db.outbox).get(), isEmpty);
      await store.save(const AccountPreferences());
      final rows = await db.select(db.outbox).get();
      expect(
        [for (final r in rows) (r.entity, r.entityId)],
        [('userProfile', 'p')],
      );
      // Already on: saving again queues nothing more.
      await store.save(const AccountPreferences());
      expect(await db.select(db.outbox).get(), hasLength(1));
    });
  });
}
