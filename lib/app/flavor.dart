import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

// Values come from `--dart-define-from-file=config/<flavor>.json` (gitignored;
// see config/example.json), so no Firebase config file is committed.
enum Flavor {
  dev,
  prod;

  static Flavor fromName(String name) => name == 'prod' ? prod : dev;
}

const appFlavorName = String.fromEnvironment('FLAVOR');

Flavor get appFlavor => Flavor.fromName(appFlavorName);

({AndroidAppCheckProvider android, AppleAppCheckProvider apple})
appCheckProvidersFor(Flavor flavor) => switch (flavor) {
  Flavor.dev => (
    android: const AndroidDebugProvider(),
    apple: const AppleDebugProvider(),
  ),
  Flavor.prod => (
    android: const AndroidPlayIntegrityProvider(),
    apple: const AppleAppAttestWithDeviceCheckFallbackProvider(),
  ),
};

class FirebaseConfig {
  const FirebaseConfig({
    required this.projectId,
    required this.messagingSenderId,
    required this.storageBucket,
    required this.androidApiKey,
    required this.androidAppId,
    required this.iosApiKey,
    required this.iosAppId,
    required this.iosBundleId,
  });

  const FirebaseConfig.fromEnvironment()
    : projectId = const String.fromEnvironment('FIREBASE_PROJECT_ID'),
      messagingSenderId = const String.fromEnvironment(
        'FIREBASE_MESSAGING_SENDER_ID',
      ),
      storageBucket = const String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
      androidApiKey = const String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
      androidAppId = const String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
      iosApiKey = const String.fromEnvironment('FIREBASE_IOS_API_KEY'),
      iosAppId = const String.fromEnvironment('FIREBASE_IOS_APP_ID'),
      iosBundleId = const String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID');

  final String projectId;
  final String messagingSenderId;
  final String storageBucket;
  final String androidApiKey;
  final String androidAppId;
  final String iosApiKey;
  final String iosAppId;
  final String iosBundleId;

  bool get isConfigured => projectId.isNotEmpty;

  FirebaseOptions? optionsFor(TargetPlatform platform) {
    if (!isConfigured) return null;
    return switch (platform) {
      TargetPlatform.android => FirebaseOptions(
        apiKey: androidApiKey,
        appId: androidAppId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        storageBucket: storageBucket,
      ),
      TargetPlatform.iOS => FirebaseOptions(
        apiKey: iosApiKey,
        appId: iosAppId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        storageBucket: storageBucket,
        iosBundleId: iosBundleId,
      ),
      _ => null,
    };
  }
}

const googleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
