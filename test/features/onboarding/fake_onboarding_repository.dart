import 'dart:async';

import 'package:repforge/features/onboarding/domain/onboarding_answers.dart';
import 'package:repforge/features/onboarding/domain/onboarding_repository.dart';

class FakeOnboardingRepository implements OnboardingRepository {
  FakeOnboardingRepository({bool done = false}) : _done = done;

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
  Future<void> complete(OnboardingAnswers answers) async {
    if (failWith case final error?) throw error;
    saved.add(answers);
    done = true;
  }
}
