import 'package:repforge/features/auth/domain/account_preferences.dart';

class FakeAccountPreferencesStore implements AccountPreferencesStore {
  AccountPreferences stored = const AccountPreferences();
  var saves = 0;

  @override
  Future<AccountPreferences> load() async => stored;

  @override
  Future<void> save(AccountPreferences preferences) async {
    stored = preferences;
    saves++;
  }
}
