import 'dart:convert';
import 'dart:io';

import 'seed/seed_builder.dart';

void main() {
  final source =
      (jsonDecode(File('tool/seed/source/exercises.json').readAsStringSync())
              as List)
          .cast<Map<String, Object?>>();
  try {
    final seed = buildSeed(
      source,
      catalogVersion: seedCatalogVersion,
      sourceCommit: seedSourceCommit,
    );
    final out = File('assets/exercises/seed.json')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(encodeSeed(seed));
    stdout.writeln(
      'Wrote ${(seed['exercises']! as List).length} exercises to ${out.path}',
    );
  } on SeedError catch (e) {
    stderr.writeln(e);
    exitCode = 1;
  }
}
