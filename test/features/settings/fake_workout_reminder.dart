import 'package:repforge/features/settings/domain/workout_reminder.dart';

class FakeWorkoutReminder implements WorkoutReminder {
  FakeWorkoutReminder({this.enabled = true, this.grant = true});

  bool enabled;
  // What the permission prompt answers.
  bool grant;
  var requests = 0;
  var settingsOpened = 0;
  var replaced = 0;
  List<ScheduledReminder> scheduled = const [];

  @override
  Future<bool> allowed() async => enabled;

  @override
  Future<bool> request() async {
    requests++;
    enabled = grant;
    return grant;
  }

  @override
  Future<void> replaceAll(List<ScheduledReminder> reminders) async {
    replaced++;
    scheduled = reminders;
  }

  @override
  Future<void> openSettings() async => settingsOpened++;
}
