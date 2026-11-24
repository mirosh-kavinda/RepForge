import '../../../core/metrics/units.dart';
import 'settings.dart';

abstract interface class SettingsRepository {
  // The profile's settings; defaults until a profile exists.
  Stream<TrainingSettings> watch();

  // AC2.
  Future<void> setUnits(UnitSystem units);

  // AC4.
  Future<void> setDefaultRest(int seconds);

  // AC5: [u]'s bar and plates, in kg.
  Future<void> setPlates(UnitSystem u, double barKg, List<double> platesKg);

  // AC3: on the phone only.
  Future<ThemePref> readTheme();

  Future<void> setTheme(ThemePref theme);

  // AC8: on the phone only.
  Stream<ReminderPref> watchReminder();

  Future<void> setReminder(ReminderPref pref);
}
