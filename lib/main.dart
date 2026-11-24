import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/router.dart';
import 'data/notifications/local_notifications.dart';
import 'features/auth/data/providers.dart';
import 'features/library/data/providers.dart';
import 'features/settings/data/providers.dart';

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
  startAuth(container);
  // SET-01 AC8, AC9: reminders follow the cycle while the app runs; a
  // reminder's tap opens Home.
  LocalNotifications.instance.onTap = (payload) =>
      openFromNotification(payload, container.read(routerProvider).go);
  LocalNotifications.instance.ready().ignore();
  container.listen(reminderSchedulerProvider, (_, _) {});
}
