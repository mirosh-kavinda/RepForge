import '../../../core/metrics/units.dart';
import 'onboarding_answers.dart';

abstract interface class OnboardingRepository {
  Stream<bool> watchDone();

  // The profile's units; metric until a profile exists.
  Stream<UnitSystem> watchUnits();

  // Saves the profile, a first body snapshot when a weight or waist is given,
  // and the done flag, all or nothing (AC6). [alsoWrite] runs inside the same
  // transaction (SCH-01: the starter cycle), before the flag.
  Future<void> complete(
    OnboardingAnswers answers, {
    Future<void> Function()? alsoWrite,
  });
}
