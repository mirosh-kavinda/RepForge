// AUTH-01 AC7, AC8 against the real Firebase Auth emulator (no real project):
//   firebase emulators:start --only auth --project demo-repforge
//   adb reverse tcp:9099 tcp:9099   (physical phone)
//   flutter test integration_test/auth01_emulator_test.dart --flavor dev \
//     --dart-define=EMULATOR_HOST=127.0.0.1
import 'package:drift/native.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:repforge/data/local/app_database.dart';
import 'package:repforge/data/local/local_data_wiper.dart';
import 'package:repforge/features/auth/data/auth_local_store.dart';
import 'package:repforge/features/auth/data/firebase_auth_repository.dart';
import 'package:repforge/features/auth/data/provider_credentials.dart';
import 'package:repforge/features/auth/domain/auth_failure.dart';

const _host = String.fromEnvironment('EMULATOR_HOST', defaultValue: '10.0.2.2');

class _NoProviders implements ProviderCredentials {
  @override
  Future<AuthCredential?> google() async => null;

  @override
  Future<AuthCredential?> apple() async => null;

  @override
  Future<void> signOut() async {}
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late FirebaseAuth auth;

  setUpAll(() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'demo-key',
        appId: '1:1:android:1',
        messagingSenderId: '1',
        projectId: 'demo-repforge',
      ),
    );
    auth = FirebaseAuth.instance;
    await auth.useAuthEmulator(_host, 9099);
  });

  Future<(FirebaseAuthRepository, AppDatabase)> fresh() async {
    await auth.signOut();
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = FirebaseAuthRepository(
      auth: Future.value(auth),
      providers: _NoProviders(),
      store: AuthLocalStore(db),
      wiper: LocalDataWiper(db),
      isOnline: () async => true,
    );
    return (repo, db);
  }

  Future<int> outboxRows(AppDatabase db) async =>
      (await db.customSelect('SELECT count(*) AS c FROM outbox').getSingle())
          .read<int>('c');

  Future<void> addLocalData(AppDatabase db) => db.customInsert(
    'INSERT INTO outbox (entity, entity_id, op, created_at) '
    "VALUES ('note', 'n1', 'create', 0)",
  );

  String email() => 'u${DateTime.now().microsecondsSinceEpoch}@example.com';

  testWidgets('AC7 a guest who signs up keeps the same uid and records', (
    _,
  ) async {
    final (repo, db) = await fresh();
    expect(await repo.continueAsGuest(), isNull);
    final guestUid = auth.currentUser!.uid;
    expect(auth.currentUser!.isAnonymous, isTrue);
    await addLocalData(db);

    expect(await repo.signInWithEmail(email(), 'password1'), isNull);

    expect(auth.currentUser!.uid, guestUid);
    expect(auth.currentUser!.isAnonymous, isFalse);
    expect(await outboxRows(db), 1);
  });

  testWidgets('AC8 an existing account asks; keep signs in and flags merge', (
    _,
  ) async {
    final existing = email();
    final created = await auth.createUserWithEmailAndPassword(
      email: existing,
      password: 'password1',
    );
    final existingUid = created.user!.uid;

    final (repo, db) = await fresh();
    await repo.continueAsGuest();
    final guestUid = auth.currentUser!.uid;
    await addLocalData(db);

    final failure = await repo.signInWithEmail(existing, 'password1');
    expect(failure, isA<AuthAccountExists>());
    expect(auth.currentUser!.uid, guestUid);

    expect(
      await repo.completeExistingAccount(
        (failure! as AuthAccountExists).pending,
        keepGuestData: true,
      ),
      isNull,
    );
    expect(auth.currentUser!.uid, existingUid);
    expect(await outboxRows(db), 1);
    expect(await AuthLocalStore(db).pendingMergeFrom(), guestUid);
  });
}
