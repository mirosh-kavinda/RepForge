import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;

// One plugin set up once for every local notification (LOG-03 rest timer,
// SET-01 reminders): a second initialize would replace the tap handler.
class LocalNotifications {
  LocalNotifications._();

  static final instance = LocalNotifications._();

  final plugin = FlutterLocalNotificationsPlugin();

  // Called with the tapped notification's payload; set by the app.
  void Function(String? payload)? onTap;

  Future<void>? _ready;

  Future<void> ready() => _ready ??= _init().catchError((Object e) {
    _ready = null;
    throw e;
  });

  Future<void> _init() async {
    tzdata.initializeTimeZones();
    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (r) => onTap?.call(r.payload),
    );
    // Opened from a notification while the app was closed.
    final launch = await plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      onTap?.call(launch!.notificationResponse?.payload);
    }
  }

  AndroidFlutterLocalNotificationsPlugin? get android => plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  IOSFlutterLocalNotificationsPlugin? get _ios => plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  Future<bool> allowed() async {
    await ready();
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await android?.areNotificationsEnabled() ?? false;
    }
    final p = await _ios?.checkPermissions();
    return p?.isEnabled ?? false;
  }

  // Asks once (Android 13+, iOS); returns whether alerts are allowed.
  Future<bool> request() async {
    await ready();
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await android?.requestNotificationsPermission() ?? false;
    }
    return await _ios?.requestPermissions(alert: true, sound: true) ?? false;
  }

  Future<void> openSettings() =>
      AppSettings.openAppSettings(type: AppSettingsType.notification);
}
