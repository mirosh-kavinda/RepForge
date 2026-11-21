import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'flavor.dart';

// Returns false when this build has no Firebase config (tests, CI, a fresh
// clone): the app then runs local-only and guests stay fully usable.
Future<bool> bootstrapFirebase({
  FirebaseConfig config = const FirebaseConfig.fromEnvironment(),
}) async {
  final options = config.optionsFor(defaultTargetPlatform);
  if (options == null) return false;
  await Firebase.initializeApp(options: options);
  final providers = appCheckProvidersFor(appFlavor);
  await FirebaseAppCheck.instance.activate(
    providerAndroid: providers.android,
    providerApple: providers.apple,
  );
  return true;
}
