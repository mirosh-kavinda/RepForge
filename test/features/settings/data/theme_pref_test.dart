import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/theme/theme_mode.dart';
import 'package:repforge/features/settings/data/providers.dart';
import 'package:repforge/features/settings/domain/settings.dart';

import '../fake_settings_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'SET-01 AC3 the saved theme comes back; a new choice is saved',
    () async {
      final repo = FakeSettingsRepository(theme: ThemePref.dark);
      final container = ProviderContainer(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      expect(container.read(appThemeModeProvider), ThemeMode.system);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(appThemeModeProvider), ThemeMode.dark);
      await container.read(appThemeModeProvider.notifier).set(ThemeMode.light);
      expect(repo.theme, ThemePref.light);
    },
  );

  test('SET-01 a failed theme save keeps the old theme', () async {
    final repo = FakeSettingsRepository();
    final container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    container.read(appThemeModeProvider);
    await Future<void>.delayed(Duration.zero);
    repo.failWith = StateError('db');
    await expectLater(
      container.read(appThemeModeProvider.notifier).set(ThemeMode.dark),
      throwsStateError,
    );
    expect(container.read(appThemeModeProvider), ThemeMode.system);
  });
}
