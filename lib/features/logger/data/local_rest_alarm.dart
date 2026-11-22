import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../domain/rest_alarm.dart';

// One notification id: a new rest always replaces the last one.
const _id = 3001;

class LocalRestAlarm implements RestAlarm {
  LocalRestAlarm([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

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

  Future<void> _init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  IOSFlutterLocalNotificationsPlugin? get _ios => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  @override
  Future<bool> allowed() async {
    await _init();
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _android?.areNotificationsEnabled() ?? false;
    }
    final p = await _ios?.checkPermissions();
    return p?.isEnabled ?? false;
  }

  @override
  Future<bool> request() async {
    await _init();
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _android?.requestNotificationsPermission() ?? false;
    }
    return await _ios?.requestPermissions(alert: true, sound: true) ?? false;
  }

  @override
  Future<void> schedule(
    DateTime at, {
    required String title,
    required String body,
  }) async {
    await _init();
    // UTC instant, so the device's time zone database is not needed.
    final when = tz.TZDateTime.from(at.toUtc(), tz.UTC);
    final exact = await _android?.canScheduleExactNotifications() ?? false;
    await _plugin.zonedSchedule(
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
    await _init();
    await _plugin.cancel(id: _id);
  }

  @override
  Future<void> openSettings() =>
      AppSettings.openAppSettings(type: AppSettingsType.notification);
}
