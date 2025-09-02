import "package:flutter/foundation.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";

import "push_message.dart";

/// Creates a notification
///
abstract class NotificationFactory {
  /// Handles creation of a [Notification] object
  ///
  /// @param context [Application Context][Context.getApplicationContext]
  /// @param message [Push Message][PushMessage]
  ///
  Future<void> createNotification(PushMessage message);
}

class AppNotificationFactory extends NotificationFactory {
  final _localNotifications = FlutterLocalNotificationsPlugin();
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

  Future<void> onDidReceiveNotification(NotificationResponse response) async {
    debugPrint("Notification clicked: ${response.payload}");
    // Handle notification click
  }

  Future<void> init() async {
    if (!kIsWeb) {
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

    // Request permission for android
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
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
