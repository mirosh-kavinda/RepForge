import 'dart:async';

import 'package:repforge/core/metrics/units.dart';
import 'package:repforge/features/settings/domain/settings.dart';
import 'package:repforge/features/settings/domain/settings_repository.dart';

class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository({
    this.settings = const TrainingSettings(),
    this.theme = ThemePref.system,
    this.reminder = const ReminderPref(),
  });

  TrainingSettings settings;
  ThemePref theme;
  ReminderPref reminder;
  Object? failWith;
  final _changes = StreamController<void>.broadcast();

  Stream<T> _watch<T>(T Function() read) async* {
    yield read();
    await for (final _ in _changes.stream) {
      yield read();
    }
  }

  Future<void> _change(void Function() f) async {
    if (failWith case final e?) throw e;
    f();
    _changes.add(null);
  }

  TrainingSettings _with({
    UnitSystem? units,
    int? restSec,
    UnitSystem? platesFor,
    double? barKg,
    List<double>? platesKg,
  }) {
    final s = settings;
    final metric = platesFor == UnitSystem.metric;
    final imperial = platesFor == UnitSystem.imperial;
    return TrainingSettings(
      units: units ?? s.units,
      restSec: restSec ?? s.restSec,
      barKgMetric: metric ? barKg : s.barKgMetric,
      barKgImperial: imperial ? barKg : s.barKgImperial,
      platesKgMetric: metric ? platesKg : s.platesKgMetric,
      platesKgImperial: imperial ? platesKg : s.platesKgImperial,
    );
  }

  @override
  Stream<TrainingSettings> watch() => _watch(() => settings);

  @override
  Future<void> setUnits(UnitSystem units) =>
      _change(() => settings = _with(units: units));

  @override
  Future<void> setDefaultRest(int seconds) =>
      _change(() => settings = _with(restSec: seconds));

  @override
  Future<void> setPlates(UnitSystem u, double barKg, List<double> platesKg) =>
      _change(
        () => settings = _with(platesFor: u, barKg: barKg, platesKg: platesKg),
      );

  @override
  Future<ThemePref> readTheme() async => theme;

  @override
  Future<void> setTheme(ThemePref t) => _change(() => theme = t);

  @override
  Stream<ReminderPref> watchReminder() => _watch(() => reminder);

  @override
  Future<void> setReminder(ReminderPref pref) => _change(() => reminder = pref);
}
