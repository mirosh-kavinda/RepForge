import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/core/metrics/units.dart';
import 'package:repforge/data/local/app_database.dart';
import 'package:repforge/features/settings/data/drift_settings_repository.dart';
import 'package:repforge/features/settings/domain/settings.dart';

void main() {
  late AppDatabase db;
  late DriftSettingsRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftSettingsRepository(db, now: () => DateTime.utc(2026, 11, 24));
  });
  tearDown(() => db.close());

  Future<void> profile() => db
      .into(db.userProfiles)
      .insert(
        UserProfilesCompanion.insert(
          id: const Value('p'),
          units: 'metric',
          updatedAt: DateTime.utc(2026, 11, 1),
        ),
      );

  Future<List<String>> outbox() async => [
    for (final r in await db.select(db.outbox).get())
      '${r.entity}:${r.op.name}',
  ];

  group('SET-01 settings repository', () {
    test('AC5 defaults until set; 45 lb stays 45 lb', () async {
      await profile();
      final s = await repo.watch().first;
      expect(s.units, UnitSystem.metric);
      expect(s.restSec, 120);
      expect(s.barKg(UnitSystem.metric), 20);
      expect(s.platesKg(UnitSystem.metric), defaultPlatesKg);
      expect(inUnit(s.barKg(UnitSystem.imperial), UnitSystem.imperial), 45);
      expect([
        for (final p in s.platesKg(UnitSystem.imperial))
          inUnit(p, UnitSystem.imperial),
      ], defaultPlatesLb);
    });

    test('AC2 AC4 AC11 units and rest are saved and backed up', () async {
      await profile();
      await repo.setUnits(UnitSystem.imperial);
      await repo.setDefaultRest(90);
      final s = await repo.watch().first;
      expect((s.units, s.restSec), (UnitSystem.imperial, 90));
      expect(await outbox(), ['userProfile:update', 'userProfile:update']);
    });

    test('AC5 edge each unit keeps its own bar and plates', () async {
      await profile();
      await repo.setPlates(UnitSystem.metric, 15, const [20, 10]);
      final s = await repo.watch().first;
      expect(s.barKg(UnitSystem.metric), 15);
      expect(s.platesKg(UnitSystem.metric), [20, 10]);
      expect(inUnit(s.barKg(UnitSystem.imperial), UnitSystem.imperial), 45);
    });

    test('no profile yet: defaults, and writes do nothing', () async {
      await repo.setDefaultRest(60);
      expect((await repo.watch().first).restSec, 120);
      expect(await outbox(), isEmpty);
    });

    test('AC3 AC8 theme and reminder stay on the phone', () async {
      expect(await repo.readTheme(), ThemePref.system);
      await repo.setTheme(ThemePref.dark);
      expect(await repo.readTheme(), ThemePref.dark);
      expect(await repo.watchReminder().first, const ReminderPref());
      await repo.setReminder(const ReminderPref(on: true, minutes: 7 * 60));
      expect(
        await repo.watchReminder().first,
        const ReminderPref(on: true, minutes: 420),
      );
      expect(await outbox(), isEmpty);
    });
  });
}
