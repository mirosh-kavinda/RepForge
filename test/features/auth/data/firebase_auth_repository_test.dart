import 'package:drift/native.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repforge/data/local/app_database.dart';
import 'package:repforge/data/local/local_data_wiper.dart';
import 'package:repforge/features/auth/data/auth_local_store.dart';
import 'package:repforge/features/auth/data/firebase_auth_repository.dart';
import 'package:repforge/features/auth/data/provider_credentials.dart';
import 'package:repforge/features/auth/domain/auth_failure.dart';
import 'package:repforge/features/auth/domain/auth_user.dart';

class MockAuth extends Mock implements FirebaseAuth {}

class FakeCredential extends Fake implements UserCredential {}

class FakeInfo extends Fake implements UserInfo {
  FakeInfo(this.providerId);

  @override
  final String providerId;
}

class FakeUser extends Fake implements User {
  FakeUser(
    this.uid, {
    this.isAnonymous = false,
    this.emailVerified = false,
    this.email,
    List<String> providers = const [],
  }) : providerData = [for (final p in providers) FakeInfo(p)];

  @override
  final String uid;
  @override
  final bool isAnonymous;
  @override
  final bool emailVerified;
  @override
  final String? email;
  @override
  final List<UserInfo> providerData;
  @override
  String? get displayName => null;
  @override
  String? get photoURL => null;

  Future<UserCredential> Function(AuthCredential)? onLink;
  Future<void> Function()? onReload;
  var linkCalls = 0;
  var verificationsSent = 0;

  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) {
    linkCalls++;
    return onLink!(credential);
  }

  @override
  Future<void> reload() => onReload!();

  @override
  Future<void> sendEmailVerification([ActionCodeSettings? settings]) async =>
      verificationsSent++;
}

class FakeProviders implements ProviderCredentials {
  AuthCredential? next = GoogleAuthProvider.credential(idToken: 'g');
  var calls = 0;
  var signedOut = false;

  @override
  Future<AuthCredential?> google() async {
    calls++;
    return next;
  }

  @override
  Future<AuthCredential?> apple() async {
    calls++;
    return next;
  }

  @override
  Future<void> signOut() async => signedOut = true;
}

void main() {
  late AppDatabase db;
  late AuthLocalStore store;
  late MockAuth auth;
  late FakeProviders providers;
  late bool online;
  late FirebaseAuthRepository repo;
  FakeUser? signedIn;

  setUpAll(() {
    registerFallbackValue(GoogleAuthProvider.credential(idToken: 'x'));
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    store = AuthLocalStore(db);
    auth = MockAuth();
    providers = FakeProviders();
    online = true;
    signedIn = null;
    when(() => auth.currentUser).thenAnswer((_) => signedIn);
    when(() => auth.signOut()).thenAnswer((_) async => signedIn = null);
    repo = FirebaseAuthRepository(
      auth: Future.value(auth),
      providers: providers,
      store: store,
      wiper: LocalDataWiper(db),
      isOnline: () async => online,
    );
  });
  tearDown(() => db.close());

  Future<int> outboxRows() async =>
      (await db.customSelect('SELECT count(*) AS c FROM outbox').getSingle())
          .read<int>('c');

  Future<void> addLocalData() => db.customInsert(
    'INSERT INTO outbox (entity, entity_id, op, created_at) '
    "VALUES ('note', 'n1', 'create', 0)",
  );

  void stubAnonymousSignIn(String uid) =>
      when(() => auth.signInAnonymously()).thenAnswer((_) async {
        signedIn = FakeUser(uid, isAnonymous: true);
        return FakeCredential();
      });

  void stubSignInWithCredential(String uid, {List<String> p = const []}) =>
      when(() => auth.signInWithCredential(any())).thenAnswer((_) async {
        signedIn = FakeUser(uid, providers: p);
        return FakeCredential();
      });

  FakeUser signedInGuest() => signedIn = FakeUser('anon', isAnonymous: true);

  group('AUTH-01 guest', () {
    test('AC6 online guest gets an anonymous account', () async {
      stubAnonymousSignIn('anon');
      expect(await repo.continueAsGuest(), isNull);
      verify(() => auth.signInAnonymously()).called(1);
      expect(await store.choiceMade(), isTrue);
      expect(await store.localGuestId(), isNull);
    });

    test('AC6 offline guest gets a local identity, no network call', () async {
      online = false;
      expect(await repo.continueAsGuest(), isNull);
      verifyNever(() => auth.signInAnonymously());
      final id = await store.localGuestId();
      expect(id, isNotNull);
      expect(repo.currentUser, AuthUser.localGuest(id: id!));
      expect(await store.choiceMade(), isTrue);
    });

    test('AC6 a build without Firebase config still lets guests in', () async {
      final local = FirebaseAuthRepository(
        auth: Future.value(),
        providers: providers,
        store: store,
        wiper: LocalDataWiper(db),
        isOnline: () async => true,
      );
      expect(await local.continueAsGuest(), isNull);
      expect(local.currentUser?.kind, AuthKind.localGuest);
      expect(await local.signInWithGoogle(), const AuthFailure.offline());
    });

    test('AC6 a local guest is upgraded to anonymous once online', () async {
      await store.setLocalGuestId('local-1');
      stubAnonymousSignIn('anon');
      online = false;
      await repo.upgradeLocalGuest();
      verifyNever(() => auth.signInAnonymously());
      online = true;
      await repo.upgradeLocalGuest();
      verify(() => auth.signInAnonymously()).called(1);
      expect(await store.localGuestId(), isNull);
    });

    test(
      'AC6 network failure on anonymous sign-in falls back to local guest',
      () async {
        when(
          () => auth.signInAnonymously(),
        ).thenThrow(FirebaseAuthException(code: 'network-request-failed'));
        expect(await repo.continueAsGuest(), isNull);
        expect(repo.currentUser?.kind, AuthKind.localGuest);
      },
    );
  });

  group('AUTH-01 provider sign-in', () {
    test('AC2 Google signs in when there is no guest', () async {
      stubSignInWithCredential('g-uid', p: ['google.com']);
      expect(await repo.signInWithGoogle(), isNull);
      verify(() => auth.signInWithCredential(any())).called(1);
      expect(repo.currentUser?.uid, 'g-uid');
      expect(repo.currentUser?.canBackUp, isTrue);
      expect(await store.choiceMade(), isTrue);
    });

    test(
      'AC7 a guest who signs in keeps the same uid and every record',
      () async {
        final guest = signedInGuest()
          ..onLink = (_) async {
            signedIn = FakeUser('anon', providers: ['google.com']);
            return FakeCredential();
          };
        await addLocalData();

        expect(await repo.signInWithGoogle(), isNull);

        expect(guest.linkCalls, 1);
        verifyNever(() => auth.signInWithCredential(any()));
        expect(repo.currentUser?.uid, 'anon');
        expect(repo.currentUser?.isGuest, isFalse);
        expect(await outboxRows(), 1);
      },
    );

    test('AC9 offline: provider sheet is never opened', () async {
      online = false;
      expect(await repo.signInWithGoogle(), const AuthFailure.offline());
      expect(await repo.signInWithApple(), const AuthFailure.offline());
      expect(providers.calls, 0);
    });

    test('AC9 a network error from Firebase maps to offline', () async {
      when(
        () => auth.signInWithCredential(any()),
      ).thenThrow(FirebaseAuthException(code: 'network-request-failed'));
      expect(await repo.signInWithGoogle(), const AuthFailure.offline());
    });

    test('edge: cancelling the sheet is silent and makes no choice', () async {
      providers.next = null;
      expect(await repo.signInWithGoogle(), const AuthFailure.cancelled());
      expect(await store.choiceMade(), isFalse);
    });

    test('edge: a Google clash points to Apple', () async {
      when(() => auth.signInWithCredential(any())).thenThrow(
        FirebaseAuthException(code: 'account-exists-with-different-credential'),
      );
      expect(
        await repo.signInWithGoogle(),
        const AuthFailure.useProvider(SignInProvider.apple),
      );
    });

    test('edge: email registered with another provider names Google', () async {
      when(() => auth.signInWithCredential(any())).thenThrow(
        FirebaseAuthException(code: 'account-exists-with-different-credential'),
      );
      expect(
        await repo.signInWithApple(),
        const AuthFailure.useProvider(SignInProvider.google),
      );
    });
  });

  group('AUTH-01 local guest signing in', () {
    test(
      'AC8 a local guest is upgraded first, so an existing account asks',
      () async {
        await store.setLocalGuestId('local-1');
        when(() => auth.signInAnonymously()).thenAnswer((_) async {
          signedIn = FakeUser('anon', isAnonymous: true)
            ..onLink = (_) async => throw FirebaseAuthException(
              code: 'email-already-in-use',
              email: 'a@b.co',
            );
          return FakeCredential();
        });
        final failure = await repo.signInWithEmail('a@b.co', 'password1');
        expect(failure, isA<AuthAccountExists>());
        verifyNever(
          () => auth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        );
      },
    );

    test(
      'AC8 if the upgrade fails, nothing signs in past the guest data',
      () async {
        await store.setLocalGuestId('local-1');
        when(
          () => auth.signInAnonymously(),
        ).thenThrow(FirebaseAuthException(code: 'network-request-failed'));
        expect(
          await repo.signInWithEmail('a@b.co', 'password1'),
          const AuthFailure.offline(),
        );
        expect(await repo.signInWithGoogle(), const AuthFailure.offline());
        verifyNever(() => auth.signInWithCredential(any()));
        expect(await store.localGuestId(), 'local-1');
        expect(await store.choiceMade(), isFalse);
      },
    );
  });

  group('AUTH-01 reachability', () {
    test('AC9 isOnline is false offline', () async {
      expect(await repo.isOnline(), isTrue);
      online = false;
      expect(await repo.isOnline(), isFalse);
    });
  });

  group('AUTH-01 existing account', () {
    late FakeUser guest;

    setUp(() async {
      guest = signedInGuest()
        ..onLink = (_) async => throw FirebaseAuthException(
          code: 'credential-already-in-use',
          credential: GoogleAuthProvider.credential(idToken: 'existing'),
        );
      await addLocalData();
    });

    Future<PendingCredential> clash() async {
      final failure = await repo.signInWithGoogle();
      expect(failure, isA<AuthAccountExists>());
      expect(await store.choiceMade(), isFalse);
      return (failure! as AuthAccountExists).pending;
    }

    test('AC8 keep: signs in, data kept and flagged for merge', () async {
      final pending = await clash();
      stubSignInWithCredential('existing-uid', p: ['google.com']);
      expect(
        await repo.completeExistingAccount(pending, keepGuestData: true),
        isNull,
      );
      expect(repo.currentUser?.uid, 'existing-uid');
      expect(await outboxRows(), 1);
      expect(await store.pendingMergeFrom(), 'anon');
      expect(await store.choiceMade(), isTrue);
    });

    test('AC8 discard: signs in and removes guest data', () async {
      final pending = await clash();
      stubSignInWithCredential('existing-uid');
      expect(
        await repo.completeExistingAccount(pending, keepGuestData: false),
        isNull,
      );
      expect(await outboxRows(), 0);
      expect(await store.pendingMergeFrom(), isNull);
      expect(await store.choiceMade(), isTrue);
    });

    test('AC8 a failed completion never removes data', () async {
      final pending = await clash();
      when(
        () => auth.signInWithCredential(any()),
      ).thenThrow(FirebaseAuthException(code: 'invalid-credential'));
      expect(
        await repo.completeExistingAccount(pending, keepGuestData: false),
        const AuthFailure.wrongPassword(),
      );
      expect(await outboxRows(), 1);
      expect(await store.choiceMade(), isFalse);
    });

    test('AC8 an email clash on link also asks to keep or discard', () async {
      guest.onLink = (_) async => throw FirebaseAuthException(
        code: 'email-already-in-use',
        email: 'a@b.co',
      );
      final failure = await repo.signInWithEmail('a@b.co', 'password1');
      expect(failure, isA<AuthAccountExists>());
      final pending = (failure! as AuthAccountExists).pending;
      expect(pending.provider, SignInProvider.password);
      expect(pending.email, 'a@b.co');
    });
  });

  group('AUTH-01 email', () {
    void stubCreate(String uid) =>
        when(
          () => auth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async {
          signedIn = FakeUser(uid, email: 'new@b.co', providers: ['password']);
          return FakeCredential();
        });

    void stubSignInThrows(String code) => when(
      () => auth.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(FirebaseAuthException(code: code));

    test('AC3 a new email creates an account and sends verification', () async {
      stubSignInThrows('invalid-credential');
      stubCreate('new');
      expect(await repo.signInWithEmail(' New@B.co ', 'password1'), isNull);
      verify(
        () => auth.createUserWithEmailAndPassword(
          email: 'new@b.co',
          password: 'password1',
        ),
      ).called(1);
      expect(signedIn!.verificationsSent, 1);
      expect(repo.currentUser?.needsEmailVerification, isTrue);
      expect(await store.choiceMade(), isTrue);
    });

    test('AC3 an existing email and password signs in', () async {
      when(
        () => auth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {
        signedIn = FakeUser('e', emailVerified: true, providers: ['password']);
        return FakeCredential();
      });
      expect(await repo.signInWithEmail('a@b.co', 'password1'), isNull);
      verifyNever(
        () => auth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
      expect(repo.currentUser?.canBackUp, isTrue);
    });

    test('AC3 a wrong password for an existing email is reported', () async {
      stubSignInThrows('invalid-credential');
      when(
        () => auth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));
      expect(
        await repo.signInWithEmail('a@b.co', 'password1'),
        const AuthFailure.wrongPassword(),
      );
      expect(await store.choiceMade(), isFalse);
    });

    test(
      'AC7 a guest signing up with email links and gets a verification email',
      () async {
        signedInGuest().onLink = (_) async {
          signedIn = FakeUser('anon', email: 'a@b.co', providers: ['password']);
          return FakeCredential();
        };
        expect(await repo.signInWithEmail('a@b.co', 'password1'), isNull);
        expect(repo.currentUser?.uid, 'anon');
        expect(signedIn!.verificationsSent, 1);
      },
    );

    test('edge: invalid form fails before any network call', () async {
      expect(
        await repo.signInWithEmail('nope', 'password1'),
        const AuthFailure.invalidEmail(),
      );
      expect(
        await repo.signInWithEmail('a@b.co', 'short'),
        const AuthFailure.weakPassword(),
      );
      verifyNever(
        () => auth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    test('AC4 reset confirms whether or not the email is registered', () async {
      when(
        () => auth.sendPasswordResetEmail(email: any(named: 'email')),
      ).thenThrow(FirebaseAuthException(code: 'user-not-found'));
      expect(await repo.sendPasswordReset('a@b.co'), isNull);
      when(
        () => auth.sendPasswordResetEmail(email: any(named: 'email')),
      ).thenAnswer((_) async {});
      expect(await repo.sendPasswordReset('a@b.co'), isNull);
      expect(
        await repo.sendPasswordReset('bad'),
        const AuthFailure.invalidEmail(),
      );
    });

    test('AC5 refresh picks up a verification done elsewhere', () async {
      signedIn = FakeUser('e', email: 'a@b.co', providers: ['password'])
        ..onReload = () async {
          signedIn = FakeUser(
            'e',
            email: 'a@b.co',
            emailVerified: true,
            providers: ['password'],
          );
        };
      await repo.refresh();
      expect(repo.currentUser?.needsEmailVerification, isFalse);
      expect(repo.currentUser?.canBackUp, isTrue);
    });

    test('AC5 resend sends another verification email', () async {
      final u = signedIn = FakeUser(
        'e',
        email: 'a@b.co',
        providers: ['password'],
      );
      expect(await repo.resendVerification(), isNull);
      expect(u.verificationsSent, 1);
    });
  });

  group('AUTH-01 sign out', () {
    test('AC10 wipes local data, clears the choice and signs out', () async {
      stubSignInWithCredential('g', p: ['google.com']);
      await repo.signInWithGoogle();
      await addLocalData();

      await repo.signOut();

      expect(await outboxRows(), 0);
      expect(await store.choiceMade(), isFalse);
      expect(repo.currentUser, isNull);
      verify(() => auth.signOut()).called(1);
      expect(providers.signedOut, isTrue);
    });

    test(
      'AC10 a failing remote sign-out still leaves the phone clean',
      () async {
        when(() => auth.signOut()).thenThrow(Exception('offline'));
        await store.setChoiceMade();
        await addLocalData();
        await repo.signOut();
        expect(await outboxRows(), 0);
        expect(await store.choiceMade(), isFalse);
      },
    );
  });

  group('AUTH-01 user stream', () {
    test('start replays a stored local guest, then follows Firebase', () async {
      await store.setLocalGuestId('local-1');
      online = false;
      when(() => auth.userChanges()).thenAnswer((_) => const Stream.empty());
      await repo.start();
      expect(repo.currentUser, AuthUser.localGuest(id: 'local-1'));
      await repo.dispose();
    });
  });
}
