import "package:flutter/foundation.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";

import "../../../notifications.dart";
import "notification_factory.dart";

class AppNotificationFactory extends NotificationFactory {
  AppNotificationFactory({required FlutterLocalNotificationsPlugin plugin})
      : _localNotifications = plugin;

  AppNotificationFactory._() : _localNotifications = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _localNotifications;

  static Future<AppNotificationFactory> create() async {
    final factory = AppNotificationFactory._();
    await factory._init();
    return factory;
  }

  final _notificationDetails = const NotificationDetails(
    android: AndroidNotificationDetails(
      "high_importance_channel",
      "High Importance Notifications",
      channelDescription: "This channel is used for important notifications.",
      importance: Importance.high,
      priority: Priority.high,
      icon: "@mipmap/ic_launcher",
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  static Future<void> onDidReceiveNotification(
      NotificationResponse response,
      ) async {
    debugPrint("Notification clicked: ${response.payload}");
  }

  Future<void> _init() async {
    // Ask for permissions (Android 13+)
    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    const initializationSettingsAndroid = AndroidInitializationSettings(
      "@mipmap/ic_launcher",
    );
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotification,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveNotification,
    );
  }

  @override
  Future<void> createNotification(PushMessage message) async {
    await _localNotifications.show(
      message.hashCode,
      message.title,
      message.body,
      _notificationDetails,
      payload: message.toString(),
    );
  }
}

