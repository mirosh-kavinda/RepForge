// FND-01 AC4 / NFR-08: coverage gate for lib/core/** and lib/features/*/domain/**.
//
// Usage: dart run tool/check_coverage.dart [path/to/lcov.info] [--min=80]
//        [--only=lib/core/metrics]  (gate just the files under that path)
//
// Exit codes: 0 pass, 1 below threshold or gated files never loaded, 2 bad input.
// Runs the same locally and in CI. Passes when the gated set is empty.
import 'dart:io';

const defaultMinPercent = 80.0;

final _gated = [
  RegExp(r'^lib/core/.+\.dart$'),
  RegExp(r'^lib/features/[^/]+/domain/.+\.dart$'),
];
final _generated = RegExp(r'\.(g|freezed|drift)\.dart$');

class FileCoverage {
  FileCoverage(this.lines);

  /// Line number → hit count.
  final Map<int, int> lines;

  int get found => lines.length;
  int get hit => lines.values.where((h) => h > 0).length;
}

class CoverageResult {
  CoverageResult({
    required this.files,
    required this.untested,
    required this.minPercent,
  });

  /// Gated files present in lcov, keyed by `lib/...` path.
  final Map<String, FileCoverage> files;

  /// Gated files on disk that no test loaded (absent from lcov).
  final List<String> untested;
  final double minPercent;

  int get found => files.values.fold(0, (sum, f) => sum + f.found);
  int get hit => files.values.fold(0, (sum, f) => sum + f.hit);
  double get percent => found == 0 ? 100 : hit * 100 / found;
  bool get passed => untested.isEmpty && percent >= minPercent;
}

/// Turns any lcov `SF:` path (relative, absolute, Windows) into `lib/...`,
/// or null when it is not under `lib/`.
String? normalisePath(String raw) {
  final path = raw.trim().replaceAll(r'\', '/');
  if (path.startsWith('lib/')) return path;
  final index = path.lastIndexOf('/lib/');
  return index < 0 ? null : path.substring(index + 1);
}

bool isGated(String libPath) =>
    !_generated.hasMatch(libPath) && _gated.any((r) => r.hasMatch(libPath));

// The VM leaves files with no executable lines (pure interfaces, plain enums)
// out of lcov even when loaded, so only files with a body can be "untested".
final _body = RegExp(
  r'(\)\s*(async\*?|sync\*)?\s*(\{|=>))|(\bget\s+\w+\s*(\{|=>))',
);

bool hasExecutableCode(String source) => _body.hasMatch(
  source
      .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '')
      .replaceAll(RegExp(r'//[^\n]*'), ''),
);

CoverageResult evaluateCoverage(
  String lcov, {
  required Iterable<String> filesOnDisk,
  double minPercent = defaultMinPercent,
  bool Function(String path) hasCode = _always,
  String only = '',
}) {
  bool gated(String path) => isGated(path) && path.startsWith(only);
  final files = <String, FileCoverage>{};
  String? current;
  for (final line in lcov.split(RegExp(r'\r?\n'))) {
    if (line.startsWith('SF:')) {
      final path = normalisePath(line.substring(3));
      current = path != null && gated(path) ? path : null;
      if (current != null) files.putIfAbsent(current, () => FileCoverage({}));
    } else if (line.startsWith('DA:') && current != null) {
      final parts = line.substring(3).split(',');
      final lineNo = int.parse(parts[0]);
      final hits = int.parse(parts[1]);
      final lines = files[current]!.lines;
      lines[lineNo] = (lines[lineNo] ?? 0) + hits;
    } else if (line.trim() == 'end_of_record') {
      current = null;
    }
  }

  final untested =
      filesOnDisk
          .map(normalisePath)
          .whereType<String>()
          .where(gated)
          .where((p) => !files.containsKey(p))
          .where(hasCode)
          .toSet()
          .toList()
        ..sort();

  return CoverageResult(
    files: files,
    untested: untested,
    minPercent: minPercent,
  );
}

void main(List<String> args) {
  var lcovPath = 'coverage/lcov.info';
  var minPercent = defaultMinPercent;
  var only = '';
  for (final arg in args) {
    if (arg.startsWith('--only=')) {
      only = arg.substring(7);
    } else if (arg.startsWith('--min=')) {
      final value = double.tryParse(arg.substring(6));
      if (value == null) {
        stderr.writeln('Invalid --min value: $arg');
        exit(2);
      }
      minPercent = value;
    } else {
      lcovPath = arg;
    }
  }

  final lcovFile = File(lcovPath);
  if (!lcovFile.existsSync()) {
    stderr.writeln(
      'No coverage file at $lcovPath. Run: flutter test --coverage',
    );
    exit(2);
  }

  final libDir = Directory('lib');
  final onDisk = libDir.existsSync()
      ? libDir
            .listSync(recursive: true)
            .whereType<File>()
            .map((f) => f.path)
            .where((p) => p.endsWith('.dart'))
      : const <String>[];

  final result = evaluateCoverage(
    lcovFile.readAsStringSync(),
    filesOnDisk: onDisk,
    minPercent: minPercent,
    hasCode: (path) => hasExecutableCode(File(path).readAsStringSync()),
    only: only,
  );

  final out = stdout;
  if (result.files.isEmpty && result.untested.isEmpty) {
    out.writeln('Coverage gate: no gated files yet (lib/core, */domain). PASS');
    return;
  }
  final paths = result.files.keys.toList()..sort();
  for (final path in paths) {
    final f = result.files[path]!;
    final pct = f.found == 0 ? 100 : f.hit * 100 / f.found;
    out.writeln('  ${pct.toStringAsFixed(1).padLeft(5)} %  $path');
  }
  for (final path in result.untested) {
    out.writeln('  not loaded by any test: $path');
  }
  out.writeln(
    'Coverage gate: ${result.percent.toStringAsFixed(1)} % '
    '(${result.hit}/${result.found} lines), min ${minPercent.toStringAsFixed(0)} %',
  );
  if (!result.passed) {
    out.writeln('FAIL');
    exit(1);
  }
  out.writeln('PASS');
}

bool _always(String _) => true;
