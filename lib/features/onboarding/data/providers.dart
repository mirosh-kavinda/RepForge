import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/metrics/units.dart';
import '../../../data/local/database_provider.dart';
import '../domain/onboarding_repository.dart';
import 'drift_onboarding_repository.dart';

part 'providers.g.dart';

Duration? _noRetry(int retryCount, Object error) => null;

@Riverpod(keepAlive: true)
OnboardingRepository onboardingRepository(Ref ref) =>
    DriftOnboardingRepository(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true, retry: _noRetry)
Stream<bool> onboardingDone(Ref ref) =>
    ref.watch(onboardingRepositoryProvider).watchDone();

// The phone's region, for the default unit system (AC4).
@Riverpod(keepAlive: true)
String? deviceRegion(Ref ref) => PlatformDispatcher.instance.locale.countryCode;

@Riverpod(keepAlive: true)
Stream<UnitSystem> unitSystem(Ref ref) =>
    ref.watch(onboardingRepositoryProvider).watchUnits();
