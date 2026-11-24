import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/core/metrics/body.dart';
import 'package:repforge/core/metrics/energy.dart';
import 'package:repforge/core/metrics/estimate.dart';
import 'package:repforge/data/local/app_database.dart';
import 'package:repforge/data/sync/sync_state.dart';
import 'package:repforge/features/body/data/drift_body_repository.dart';
import 'package:repforge/features/body/domain/body_rules.dart';
import 'package:repforge/features/body/domain/body_snapshot.dart';

const profile = BodyProfile(sex: Sex.male, birthYear: 1996, heightCm: 180);

void main() {
  late AppDatabase db;
  late DateTime clock;
  late DriftBodyRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    clock = DateTime(2026, 11, 24, 8);
    repo = DriftBodyRepository(db, now: () => clock);
    await db
        .into(db.userProfiles)
        .insert(
          UserProfilesCompanion.insert(
            id: const Value('p1'),
            units: 'metric',
            sex: const Value('male'),
            birthYear: const Value(1996),
            heightCm: const Value(180),
            updatedAt: DateTime.utc(2026),
          ),
        );
  });
  tearDown(() => db.close());

  Future<List<(String, OutboxOp)>> outbox() async => [
    for (final r in await db.select(db.outbox).get()) (r.entity, r.op),
  ];

  Future<String> save(double kg, {double? scale}) {
    final input = BodyInput(
      weightKg: kg,
      activity: ActivityLevel.active,
      waistCm: 85,
      neckCm: 38,
      scaleBodyFatPct: scale,
    );
    return repo.saveToday(input, computeBodyResults(input, profile, clock));
  }

  group('BOD-01 body repository', () {
    test('profile reads height, sex, birth year', () async {
      final p = await repo.watchProfile().first;
      expect((p.sex, p.birthYear, p.heightCm), (Sex.male, 1996, 180.0));
      expect(p.activity, isNull);
    });

    test(
      'AC3 inputs and results stored together; activity to profile',
      () async {
        await save(81);
        final s = (await repo.watchAll().first).single;
        expect(s.date, DateTime.utc(2026, 11, 24));
        expect((s.weightKg, s.waistCm, s.neckCm), (81.0, 85.0, 38.0));
        expect(s.activity, ActivityLevel.active);
        expect(s.results![BodyMetric.bmi]!.valueOrNull, closeTo(25.0, 0.01));
        expect(s.results!.keys, BodyMetric.values.toSet());
        expect(
          (await repo.watchProfile().first).activity,
          ActivityLevel.active,
        );
        expect(await outbox(), [
          ('bodySnapshot', OutboxOp.create),
          ('userProfile', OutboxOp.update),
        ]);
      },
    );

    test('AC5 reasons survive the round trip', () async {
      const input = BodyInput(weightKg: 81, activity: ActivityLevel.moderate);
      final r = computeBodyResults(input, const BodyProfile(), clock);
      final back = DriftBodyRepository.decodeResults(
        DriftBodyRepository.encodeResults(r),
      );
      expect(
        back[BodyMetric.bmi],
        const NotEstimable<double>(EstimateReason.missing, Measure.heightCm),
      );
      expect(back, r);
    });

    test('AC6 a second save today replaces it', () async {
      final a = await save(81);
      final b = await save(80.5, scale: 17);
      expect(b, a);
      final all = await repo.watchAll().first;
      expect(all.single.weightKg, 80.5);
      expect(all.single.fatFromScale, isTrue);
      expect((await outbox()).where((e) => e.$1 == 'bodySnapshot').last, (
        'bodySnapshot',
        OutboxOp.update,
      ));
    });

    test('AC7 newest first; delete and restore', () async {
      clock = DateTime(2026, 11, 20, 8);
      final old = await save(82);
      clock = DateTime(2026, 11, 24, 8);
      await save(81);
      expect(
        [for (final s in await repo.watchAll().first) s.weightKg],
        [81.0, 82.0],
      );
      await repo.delete(old);
      expect(await repo.watchAll().first, hasLength(1));
      expect(await repo.byId(old), isNotNull);
      await repo.restore(old);
      expect(await repo.watchAll().first, hasLength(2));
    });

    test('AC6 Undo after a same-day re-save keeps one row per day', () async {
      final a = await save(81);
      await repo.delete(a);
      final b = await save(80);
      expect(b, isNot(a));
      await repo.restore(a);
      final all = await repo.watchAll().first;
      expect([for (final s in all) s.id], [a]);
    });

    test('edge an onboarding snapshot has no results', () async {
      await db
          .into(db.bodySnapshots)
          .insert(
            BodySnapshotsCompanion.insert(
              id: const Value('o1'),
              date: DateTime.utc(2026, 11, 1),
              weightKg: const Value(84),
              updatedAt: DateTime.utc(2026, 11, 1),
            ),
          );
      final s = (await repo.byId('o1'))!;
      expect(s.weightKg, 84);
      expect(s.results, isNull);
    });
  });
}
