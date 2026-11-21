import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/data/local/app_database.dart';
import 'package:repforge/features/auth/data/auth_local_store.dart';

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
}
