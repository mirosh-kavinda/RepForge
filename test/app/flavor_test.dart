import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repforge/app/flavor.dart';

void main() {
  group('AUTH-01 flavors and attestation', () {
    test('AC12 dev builds use the debug attestation provider', () {
      final p = appCheckProvidersFor(Flavor.dev);
      expect(p.android, isA<AndroidDebugProvider>());
      expect(p.apple, isA<AppleDebugProvider>());
    });

    test('AC12 prod builds use Play Integrity and App Attest', () {
      final p = appCheckProvidersFor(Flavor.prod);
      expect(p.android, isA<AndroidPlayIntegrityProvider>());
      expect(p.apple, isA<AppleAppAttestWithDeviceCheckFallbackProvider>());
    });

    test('unknown or missing flavor falls back to dev, never prod', () {
      expect(Flavor.fromName(''), Flavor.dev);
      expect(Flavor.fromName('staging'), Flavor.dev);
      expect(Flavor.fromName('prod'), Flavor.prod);
    });

    test('without config the app runs Firebase-free (CI, tests)', () {
      const cfg = FirebaseConfig.fromEnvironment();
      expect(cfg.isConfigured, isFalse);
      expect(cfg.optionsFor(TargetPlatform.android), isNull);
    });

    test('a copied example config (no keys) is not treated as configured', () {
      const cfg = FirebaseConfig(
        projectId: 'repforge-dev',
        messagingSenderId: '',
        storageBucket: '',
        androidApiKey: '',
        androidAppId: '',
        iosApiKey: '',
        iosAppId: '',
        iosBundleId: 'com.repforge.app',
      );
      expect(cfg.optionsFor(TargetPlatform.android), isNull);
      expect(cfg.optionsFor(TargetPlatform.iOS), isNull);
    });

    test('config builds platform options', () {
      const cfg = FirebaseConfig(
        projectId: 'repforge-dev',
        messagingSenderId: '123',
        storageBucket: 'repforge-dev.firebasestorage.app',
        androidApiKey: 'ak',
        androidAppId: '1:123:android:abc',
        iosApiKey: 'ik',
        iosAppId: '1:123:ios:def',
        iosBundleId: 'com.repforge.app',
      );
      final android = cfg.optionsFor(TargetPlatform.android)!;
      expect(android.apiKey, 'ak');
      expect(android.appId, '1:123:android:abc');
      expect(android.projectId, 'repforge-dev');
      final ios = cfg.optionsFor(TargetPlatform.iOS)!;
      expect(ios.apiKey, 'ik');
      expect(ios.iosBundleId, 'com.repforge.app');
      expect(cfg.optionsFor(TargetPlatform.windows), isNull);
    });
  });
}
