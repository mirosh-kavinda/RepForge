typedef ScheduledReminder = ({DateTime at, String title, String body});

// SET-01 AC8–AC10: local workout reminders.
abstract interface class WorkoutReminder {
  Future<bool> allowed();

  // Asks once; returns whether alerts are allowed.
  Future<bool> request();

  // Replaces every scheduled reminder with [reminders] (none cancels all).
  Future<void> replaceAll(List<ScheduledReminder> reminders);

  Future<void> openSettings();
}

// The payload a reminder carries; its tap opens Home (AC9).
const reminderPayload = 'home';
