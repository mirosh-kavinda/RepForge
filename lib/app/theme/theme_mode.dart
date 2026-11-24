import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/settings/data/providers.dart';
import '../../features/settings/domain/settings.dart';

part 'theme_mode.g.dart';

// System until the saved choice is read (SET-01 AC3); kept on the phone.
@Riverpod(keepAlive: true)
class AppThemeMode extends _$AppThemeMode {
  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  var _chosen = false;

  Future<void> _load() async {
    try {
      final saved = await ref.read(settingsRepositoryProvider).readTheme();
      // A choice made while loading wins.
      if (!_chosen) state = _mode(saved);
    } on Object {
      // Keep System.
    }
  }

  static ThemeMode _mode(ThemePref p) => switch (p) {
    ThemePref.system => ThemeMode.system,
    ThemePref.light => ThemeMode.light,
    ThemePref.dark => ThemeMode.dark,
  };

  static ThemePref _pref(ThemeMode m) => switch (m) {
    ThemeMode.system => ThemePref.system,
    ThemeMode.light => ThemePref.light,
    ThemeMode.dark => ThemePref.dark,
  };

  Future<void> set(ThemeMode mode) async {
    _chosen = true;
    final before = state;
    state = mode;
    try {
      await ref.read(settingsRepositoryProvider).setTheme(_pref(mode));
    } on Object {
      state = before;
      rethrow;
    }
  }
}
