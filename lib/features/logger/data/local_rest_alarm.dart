import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../data/notifications/local_notifications.dart';
import '../domain/rest_alarm.dart';

// One notification id: a new rest always replaces the last one.
const _id = 3001;

class LocalRestAlarm implements RestAlarm {
  LocalRestAlarm([LocalNotifications? notifications])
    : _n = notifications ?? LocalNotifications.instance;

  final LocalNotifications _n;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'rest_timer',
      'Rest timer',
      channelDescription: 'Tells you when rest between sets is over.',
      importance: Importance.high,
      priority: Priority.high,
      // No alarm category: it would break through Do Not Disturb (edge).
      category: AndroidNotificationCategory.reminder,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBanner: true,
    ),
  );

  @override
  Future<bool> allowed() => _n.allowed();

  @override
  Future<bool> request() => _n.request();

  @override
  Future<void> schedule(
    DateTime at, {
    required String title,
    required String body,
  }) async {
    await _n.ready();
    // UTC instant, so the device's time zone database is not needed.
    final when = tz.TZDateTime.from(at.toUtc(), tz.UTC);
    final exact = await _n.android?.canScheduleExactNotifications() ?? false;
    await _n.plugin.zonedSchedule(
      id: _id,
      scheduledDate: when,
      notificationDetails: _details,
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      title: title,
      body: body,
    );
  }

  @override
  Future<void> cancel() async {
    await _n.ready();
    await _n.plugin.cancel(id: _id);
  }

  @override
  Future<void> openSettings() => _n.openSettings();
}
