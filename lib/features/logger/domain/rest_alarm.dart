// LOG-03 AC5, AC7: the phone's "rest over" alert, kept behind a port so the
// domain and tests never touch the plugin.
abstract interface class RestAlarm {
  Future<bool> allowed();

  // Asks once (Android 13+, iOS); returns whether alerts are allowed.
  Future<bool> request();

  // Replaces any pending alert.
  Future<void> schedule(
    DateTime at, {
    required String title,
    required String body,
  });

  Future<void> cancel();

  Future<void> openSettings();
}
