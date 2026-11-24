import 'dart:async';

import 'package:repforge/core/metrics/units.dart';
import 'package:repforge/features/onboarding/domain/onboarding_answers.dart';
import 'package:repforge/features/onboarding/domain/onboarding_repository.dart';

class FakeOnboardingRepository implements OnboardingRepository {
  FakeOnboardingRepository({bool done = false, this.units = UnitSystem.metric})
    : _done = done;

  UnitSystem units;

  final saved = <OnboardingAnswers>[];
  final _changes = StreamController<bool>.broadcast();
  bool _done;
  Object? failWith;

  set done(bool value) {
    _done = value;
    _changes.add(value);
  }

  @override
  Stream<bool> watchDone() async* {
    yield _done;
    yield* _changes.stream;
  }

  @override
  Stream<UnitSystem> watchUnits() => Stream.value(units);

  @override
  Future<void> complete(
    OnboardingAnswers answers, {
    Future<void> Function()? alsoWrite,
  }) async {
    // Fails before alsoWrite, as a rolled-back transaction would leave it.
    if (failWith case final error?) throw error;
    await alsoWrite?.call();
    saved.add(answers);
    done = true;
  }

  // SYN-02 AC5: whether a restored profile is on the phone.
  var hasProfile = false;

  @override
  Future<bool> skipIfProfile() async {
    if (hasProfile) done = true;
    return hasProfile;
  }
}
