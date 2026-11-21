import 'dart:async';

import 'package:repforge/features/auth/domain/account_preferences.dart';

class FakeAccountPreferencesStore implements AccountPreferencesStore {
  AccountPreferences stored = const AccountPreferences();
  var saves = 0;
  Object? failWith;
  final _profile = StreamController<bool>.broadcast();

  @override
  Future<AccountPreferences> load() async => stored;

  @override
  Future<void> save(AccountPreferences preferences) async {
    if (failWith case final error?) throw error;
    stored = preferences;
    saves++;
    _profile.add(preferences.useProviderProfile);
  }

  @override
  Stream<bool> watchUseProviderProfile() async* {
    yield stored.useProviderProfile;
    yield* _profile.stream;
  }
}
