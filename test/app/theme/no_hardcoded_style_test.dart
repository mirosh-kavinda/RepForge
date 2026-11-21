import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _banned = RegExp(
  r'Color\(0x|Color\.from(ARGB|RGBO)|\bColors\.|fontSize:|fontFamily:',
);
final _generated = RegExp(r'\.(g|freezed|drift)\.dart$');

void main() {
  test('FND-02 no hard-coded colours or type outside lib/app/theme/', () {
    final offenders = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    for (final file in files) {
      final path = file.path.replaceAll(r'\', '/');
      if (path.startsWith('lib/app/theme/') ||
          path.startsWith('lib/app/l10n/generated/') ||
          _generated.hasMatch(path)) {
        continue;
      }
      for (final (i, line) in file.readAsLinesSync().indexed) {
        if (_banned.hasMatch(line)) {
          offenders.add('$path:${i + 1}: ${line.trim()}');
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
