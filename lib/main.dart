import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'features/library/data/providers.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    for (final (font, file) in [
      ('Space Grotesk', 'OFL-SpaceGrotesk.txt'),
      ('Inter', 'OFL-Inter.txt'),
    ]) {
      yield LicenseEntryWithLineBreaks([
        font,
      ], await rootBundle.loadString('assets/fonts/$file'));
    }
  });
  final container = ProviderContainer();
  runApp(
    UncontrolledProviderScope(container: container, child: const RepForgeApp()),
  );
  startCatalogImport(container);
}
