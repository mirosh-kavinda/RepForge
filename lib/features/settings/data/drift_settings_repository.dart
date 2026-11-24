import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/metrics/units.dart';
import '../../../data/local/app_database.dart';
import '../../../data/local/base_columns.dart';
import '../../../data/sync/sync_state.dart';
import '../../../data/sync/synced_writer.dart';
import '../domain/settings.dart';
import '../domain/settings_repository.dart';

class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._db, {DateTime Function()? now})
    : _writer = SyncedWriter(_db, now: now);

  static const _themeKey = 'settings.theme';
  static const _reminderOnKey = 'settings.reminderOn';
  static const _reminderTimeKey = 'settings.reminderTime';

  final AppDatabase _db;
  final SyncedWriter _writer;

  SimpleSelectStatement<$UserProfilesTable, UserProfile> _profile() =>
      _db.selectActive(_db.userProfiles)
        ..orderBy([(p) => OrderingTerm.desc(p.updatedAt)])
        ..limit(1);

  static List<double>? _plates(String? json) => json == null
      ? null
      : [for (final v in jsonDecode(json) as List) (v as num).toDouble()];

  @override
  Stream<TrainingSettings> watch() => _profile().watchSingleOrNull().map(
    (p) => p == null
        ? const TrainingSettings()
        : TrainingSettings(
            units: UnitSystem.values.byName(p.units),
            restSec: p.defaultRestSec,
            barKgMetric: p.barKgMetric,
            barKgImperial: p.barKgImperial,
            platesKgMetric: _plates(p.platesMetric),
            platesKgImperial: _plates(p.platesImperial),
          ),
  );

  // Writes to the profile with its outbox row; no profile yet, nothing to do.
  Future<void> _update(UserProfilesCompanion c) => _db.transaction(() async {
    final p = await _profile().getSingleOrNull();
    if (p == null) return;
    await _writer.run(
      table: 'user_profiles',
      entity: 'userProfile',
      id: p.id,
      op: OutboxOp.update,
      write: (_) => (_db.update(
        _db.userProfiles,
      )..where((r) => r.id.equals(p.id))).write(c),
    );
  });

  @override
  Future<void> setUnits(UnitSystem units) =>
      _update(UserProfilesCompanion(units: Value(units.name)));

  @override
  Future<void> setDefaultRest(int seconds) =>
      _update(UserProfilesCompanion(defaultRestSec: Value(seconds)));

  @override
  Future<void> setPlates(UnitSystem u, double barKg, List<double> platesKg) {
    final plates = Value(jsonEncode(platesKg));
    return _update(switch (u) {
      UnitSystem.metric => UserProfilesCompanion(
        barKgMetric: Value(barKg),
        platesMetric: plates,
      ),
      UnitSystem.imperial => UserProfilesCompanion(
        barKgImperial: Value(barKg),
        platesImperial: plates,
      ),
    });
  }

  @override
  Future<ThemePref> readTheme() async =>
      ThemePref.values.asNameMap()[await _db.readMeta(_themeKey)] ??
      ThemePref.system;

  @override
  Future<void> setTheme(ThemePref theme) =>
      _db.writeMeta(_themeKey, theme.name);

  @override
  Stream<ReminderPref> watchReminder() =>
      (_db.select(_db.appMeta)
            ..where((m) => m.key.isIn([_reminderOnKey, _reminderTimeKey])))
          .watch()
          .map((rows) {
            final m = {for (final r in rows) r.key: r.value};
            const d = ReminderPref();
            return ReminderPref(
              on: m[_reminderOnKey] == 'true',
              minutes: int.tryParse(m[_reminderTimeKey] ?? '') ?? d.minutes,
            );
          })
          .distinct();

  @override
  Future<void> setReminder(ReminderPref pref) => _db.transaction(() async {
    await _db.writeMeta(_reminderOnKey, '${pref.on}');
    await _db.writeMeta(_reminderTimeKey, '${pref.minutes}');
  });
}
