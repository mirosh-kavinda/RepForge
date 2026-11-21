import 'onboarding_answers.dart';

abstract interface class OnboardingRepository {
  Stream<bool> watchDone();

  // Saves the profile, a first body snapshot when a weight or waist is given,
  // and the done flag, all or nothing (AC6).
  Future<void> complete(OnboardingAnswers answers);
}
