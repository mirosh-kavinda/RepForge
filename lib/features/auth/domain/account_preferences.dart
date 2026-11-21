import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_preferences.freezed.dart';

abstract interface class AccountPreferencesStore {
  Future<AccountPreferences> load();

  Future<void> save(AccountPreferences preferences);

  Stream<bool> watchUseProviderProfile();
}

// Choices made on Account (09b). Workouts and goals always back up; the
// backup and notification slices read these (AUTH-01 AC13).
@freezed
abstract class AccountPreferences with _$AccountPreferences {
  const factory AccountPreferences({
    @Default(true) bool backUpBodyMetrics,
    @Default(true) bool backUpPhotos,
    @Default(true) bool useProviderProfile,
    @Default(true) bool syncSettings,
    @Default(true) bool remindersEverywhere,
  }) = _AccountPreferences;
}
