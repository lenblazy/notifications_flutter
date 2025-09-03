import "package:flutter/foundation.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:fluttertoast/fluttertoast.dart";

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
  AppNotificationFactory._();

  static Future<AppNotificationFactory> create() async {
    final factory = AppNotificationFactory._();
    await factory._init();
    return factory;
  }

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

  static Future<void> onDidReceiveNotification(
    NotificationResponse response,
  ) async {
    debugPrint("Notification clicked: ${response.payload}");
  }

  Future<void> _init() async {
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

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  @override
  Future<void> createNotification(PushMessage message) async {
    try {
      if (!kIsWeb) {
        await _localNotifications.show(
          message.hashCode,
          message.title,
          message.body,
          _notificationDetails,
          payload: message.toString(),
        );
        return;
      }

      await Fluttertoast.showToast(
          msg: message.body,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP_RIGHT,
      );
    } catch (e) {
      debugPrint("Error showing notification: $e");
    }
  }
}
