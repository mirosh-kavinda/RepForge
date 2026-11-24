import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../data/notifications/local_notifications.dart';
import '../domain/reminder_rules.dart';
import '../domain/workout_reminder.dart';

// Ids 4000 + day; the rest timer uses 3001.
const _firstId = 4000;

class LocalWorkoutReminder implements WorkoutReminder {
  LocalWorkoutReminder([LocalNotifications? notifications])
    : _n = notifications ?? LocalNotifications.instance;

  final LocalNotifications _n;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'workout_reminder',
      'Workout reminder',
      channelDescription: 'Reminds you on days your cycle plans a workout.',
      category: AndroidNotificationCategory.reminder,
    ),
    iOS: DarwinNotificationDetails(presentAlert: true, presentBanner: true),
  );

  @override
  Future<bool> allowed() => _n.allowed();

  @override
  Future<bool> request() => _n.request();

  // One replace at a time, in call order, so the latest list wins.
  Future<void> _last = Future.value();

  @override
  Future<void> replaceAll(List<ScheduledReminder> reminders) {
    final next = _last
        .catchError((Object _) {})
        .then((_) => _replace(reminders));
    _last = next;
    return next;
  }

  Future<void> _replace(List<ScheduledReminder> reminders) async {
    await _n.ready();
    final exact = await _n.android?.canScheduleExactNotifications() ?? false;
    for (var i = 0; i < reminderWindow; i++) {
      await _n.plugin.cancel(id: _firstId + i);
    }
    for (final (i, r) in reminders.take(reminderWindow).indexed) {
      // A UTC instant, as the rest timer: no time zone database needed. A
      // clock change before it fires is fixed by the next re-schedule.
      await _n.plugin.zonedSchedule(
        id: _firstId + i,
        scheduledDate: tz.TZDateTime.from(r.at.toUtc(), tz.UTC),
        notificationDetails: _details,
        androidScheduleMode: exact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        title: r.title,
        body: r.body,
        payload: reminderPayload,
      );
    }
  }

  @override
  Future<void> openSettings() => _n.openSettings();
}
