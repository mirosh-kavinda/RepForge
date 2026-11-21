import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_coverage.dart';

String record(String path, Map<int, int> hits) => [
  'SF:$path',
  for (final MapEntry(:key, :value) in hits.entries) 'DA:$key,$value',
  'end_of_record',
].join('\n');

void main() {
  group('FND-01 AC4 coverage gate', () {
    test('passes when the gated set is empty', () {
      final lcov = record('lib/app/app.dart', {1: 0, 2: 0});
      final result = evaluateCoverage(lcov, filesOnDisk: const []);
      expect(result.files, isEmpty);
      expect(result.passed, isTrue);
    });

    test('only gates lib/core/** and lib/features/*/domain/**', () {
      final lcov = [
        record('lib/core/metrics/bmi.dart', {1: 1, 2: 1}),
        record('lib/features/body/domain/snapshot.dart', {1: 1}),
        record('lib/features/body/data/repo.dart', {1: 0}),
        record('lib/features/body/presentation/screen.dart', {1: 0}),
        record('lib/app/app.dart', {1: 0}),
      ].join('\n');
      final result = evaluateCoverage(lcov, filesOnDisk: const []);
      expect(result.files.keys, {
        'lib/core/metrics/bmi.dart',
        'lib/features/body/domain/snapshot.dart',
      });
      expect(result.percent, 100);
      expect(result.passed, isTrue);
    });

    test('fails below 80 % and passes at exactly 80 %', () {
      final failing = record('lib/core/a.dart', {
        for (var i = 1; i <= 10; i++) i: i <= 7 ? 1 : 0,
      });
      expect(evaluateCoverage(failing, filesOnDisk: const []).passed, isFalse);

      final edge = record('lib/core/a.dart', {
        for (var i = 1; i <= 10; i++) i: i <= 8 ? 1 : 0,
      });
      final result = evaluateCoverage(edge, filesOnDisk: const []);
      expect(result.percent, 80);
      expect(result.passed, isTrue);
    });

    test('normalises Windows and absolute paths', () {
      final lcov = [
        record(r'lib\core\a.dart', {1: 1}),
        record(r'C:\src\repforge\lib\features\goals\domain\goal.dart', {1: 0}),
        record('/home/ci/repforge/lib/core/b.dart', {1: 1}),
      ].join('\n');
      final result = evaluateCoverage(lcov, filesOnDisk: const []);
      expect(result.files.keys, {
        'lib/core/a.dart',
        'lib/features/goals/domain/goal.dart',
        'lib/core/b.dart',
      });
    });

    test('ignores generated files', () {
      final lcov = [
        record('lib/core/a.g.dart', {1: 0}),
        record('lib/features/x/domain/m.freezed.dart', {1: 0}),
        record('lib/core/db.drift.dart', {1: 0}),
      ].join('\n');
      expect(evaluateCoverage(lcov, filesOnDisk: const []).files, isEmpty);
    });

    test('fails when a gated file on disk was never loaded by a test', () {
      final lcov = record('lib/core/a.dart', {1: 1});
      final result = evaluateCoverage(
        lcov,
        filesOnDisk: const [
          'lib/core/a.dart',
          r'lib\core\untested.dart',
          'lib/features/x/presentation/ignored.dart',
          'lib/core/gen.g.dart',
        ],
      );
      expect(result.untested, ['lib/core/untested.dart']);
      expect(result.passed, isFalse);
    });

    test('merges duplicate records for the same file', () {
      final lcov = [
        record('lib/core/a.dart', {1: 0, 2: 1}),
        record('lib/core/a.dart', {1: 1}),
      ].join('\n');
      final result = evaluateCoverage(lcov, filesOnDisk: const []);
      expect(result.percent, 100);
    });
  });
}
