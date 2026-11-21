import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/data/local/app_database.dart';
import 'package:repforge/features/library/data/catalog_importer.dart';
import 'package:repforge/features/library/data/drift_exercise_catalog_repository.dart';
import 'package:repforge/features/library/domain/exercise.dart';
import 'package:repforge/features/library/domain/exercise_query.dart';

void main() {
  late AppDatabase db;
  late DriftExerciseCatalogRepository repo;

  setUpAll(() async {
    db = AppDatabase(NativeDatabase.memory());
    final seed = File('assets/exercises/seed.json').readAsStringSync();
    await CatalogImporter(db, loadSeed: () async => seed).run();
    repo = DriftExerciseCatalogRepository(db);
  });
  tearDownAll(() => db.close());

  Future<List<String>> names(ExerciseQuery q) async =>
      (await repo.search(q)).map((e) => e.name).toList();

  group('FND-03 exercise search', () {
    test('AC4 each word matches the start of a word in the name', () async {
      final found = await names(const ExerciseQuery(text: 'bench pr'));
      expect(found, contains('Barbell Bench Press - Medium Grip'));
      for (final name in found) {
        final words = name.toLowerCase().split(RegExp(r'[^a-z0-9]+'));
        expect(words.any((w) => w.startsWith('bench')), isTrue, reason: name);
        expect(words.any((w) => w.startsWith('pr')), isTrue, reason: name);
      }
    });

    test('AC4 ignores case and punctuation', () async {
      expect(
        await names(const ExerciseQuery(text: 'BENCH-PRESS!')),
        await names(const ExerciseQuery(text: 'bench press')),
      );
      expect(
        await names(const ExerciseQuery(text: 'bench "press')),
        isNotEmpty,
      );
    });

    test('AC4 best name match first', () async {
      expect((await names(const ExerciseQuery(text: 'plank'))).first, 'Plank');
    });

    test('AC4 no match returns an empty list', () async {
      expect(await names(const ExerciseQuery(text: 'zzzqqq')), isEmpty);
    });

    test('AC5 several values of one filter widen the results', () async {
      final dumbbell = await repo.search(
        const ExerciseQuery(equipment: {Equipment.dumbbell}),
      );
      final cable = await repo.search(
        const ExerciseQuery(equipment: {Equipment.cable}),
      );
      final both = await repo.search(
        const ExerciseQuery(equipment: {Equipment.dumbbell, Equipment.cable}),
      );
      expect(dumbbell, hasLength(123));
      expect(both, hasLength(dumbbell.length + cable.length));
    });

    test('AC5 different filters narrow the results', () async {
      final narrowed = await repo.search(
        const ExerciseQuery(
          text: 'curl',
          equipment: {Equipment.dumbbell},
          levels: {ExerciseLevel.beginner},
          categories: {ExerciseCategory.strength},
        ),
      );
      expect(narrowed, isNotEmpty);
      for (final e in narrowed) {
        expect(e.equipment, Equipment.dumbbell);
        expect(e.level, ExerciseLevel.beginner);
        expect(e.category, ExerciseCategory.strength);
      }
    });

    test('AC5 muscle filter matches primary then secondary', () async {
      final results = await repo.search(
        const ExerciseQuery(muscles: {Muscle.triceps}),
      );
      expect(results, hasLength(73 + 148));
      final isPrimary = [
        for (final e in results) e.primaryMuscles.contains(Muscle.triceps),
      ];
      expect(isPrimary.indexOf(false), 73, reason: 'all primaries come first');
      expect(isPrimary.skip(73).every((p) => !p), isTrue);
      expect(
        results.map((e) => e.name),
        contains('Barbell Bench Press - Medium Grip'),
      );
    });

    test('edge: empty search lists the whole catalog A–Z', () async {
      final all = await names(const ExerciseQuery());
      expect(all, hasLength(876));
      final sorted = [...all]
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      expect(all, sorted);
    });

    test(
      'edge: exercises without mechanic or force are found by text',
      () async {
        final rows = await db
            .customSelect(
              'SELECT name FROM catalog_exercises '
              'WHERE mechanic IS NULL AND force IS NULL LIMIT 1',
            )
            .get();
        expect(rows, isNotEmpty);
        final name = rows.single.read<String>('name');
        expect(await names(ExerciseQuery(text: name)), contains(name));
      },
    );

    test('maps every field and finds by id', () async {
      final e = await repo.byId('Barbell_Bench_Press_-_Medium_Grip');
      expect(e, isNotNull);
      expect(e!.name, 'Barbell Bench Press - Medium Grip');
      expect(e.primaryMuscles, contains(Muscle.chest));
      expect(e.equipment, Equipment.barbell);
      expect(e.instructions, isNotEmpty);
      expect(e.images, isNotEmpty);
      expect(await repo.byId('nope'), isNull);
    });

    test('AC9 retired exercises are left out of search', () async {
      await db.customStatement(
        "UPDATE catalog_exercises SET retired_at = '2026-11-21T00:00:00.000Z' "
        "WHERE id = 'Barbell_Bench_Press_-_Medium_Grip'",
      );
      addTearDown(
        () => db.customStatement(
          'UPDATE catalog_exercises SET retired_at = NULL '
          "WHERE id = 'Barbell_Bench_Press_-_Medium_Grip'",
        ),
      );
      expect(
        await names(const ExerciseQuery(text: 'bench press')),
        isNot(contains('Barbell Bench Press - Medium Grip')),
      );
    });

    test('AC6 desktop smoke: 95th percentile under 100 ms', () async {
      final queries = <ExerciseQuery>[
        const ExerciseQuery(text: 'bench'),
        const ExerciseQuery(text: 'dumbbell curl'),
        const ExerciseQuery(text: 's'),
        const ExerciseQuery(muscles: {Muscle.chest, Muscle.triceps}),
        const ExerciseQuery(
          text: 'press',
          equipment: {Equipment.barbell},
          levels: {ExerciseLevel.intermediate},
        ),
        const ExerciseQuery(),
      ];
      final times = <int>[];
      for (var i = 0; i < 120; i++) {
        final sw = Stopwatch()..start();
        await repo.search(queries[i % queries.length]);
        times.add(sw.elapsedMicroseconds);
      }
      times.sort();
      final p95 = times[(times.length * 0.95).floor() - 1] / 1000;
      expect(p95, lessThan(100), reason: 'p95 = $p95 ms');
    });
  });
}
