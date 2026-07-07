import "package:core_flutter/core.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:get_it/get_it.dart";

import "../../../notifications.dart";
import "notification_factory.dart";

typedef DeepLinkOpener = void Function(String? deeplink);

class AppNotificationFactory extends NotificationFactory {
  AppNotificationFactory({required FlutterLocalNotificationsPlugin plugin})
    : _localNotifications = plugin;

  final FlutterLocalNotificationsPlugin _localNotifications;

  static Future<AppNotificationFactory> create({
    FlutterLocalNotificationsPlugin? plugin,
    Future<void> Function(AppNotificationFactory factory)? initializer,
  }) async {
    final factory = AppNotificationFactory(
      plugin: plugin ?? FlutterLocalNotificationsPlugin(),
    );
    await (initializer ?? (factory) => factory._init())(factory);
    return factory;
  }

  final _notificationDetails = const NotificationDetails(
    android: AndroidNotificationDetails(
      "high_importance_channel",
      "High Importance Notifications",
      channelDescription: "This channel is used for important notifications.",
      importance: Importance.high,
      priority: Priority.high,
      icon: "@mipmap/launcher_icon",
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  static Future<void> onDidReceiveNotification(
    NotificationResponse response, {
    DeepLinkOpener? openDeepLink,
  }) async {
    (openDeepLink ?? _defaultOpenDeepLink)(response.payload);
  }

  static void _defaultOpenDeepLink(String? deeplink) {
    GetIt.I.get<AppNavigator>().toDeepLink(deeplink);
  }

  Future<void> _init() async {
    // Ask for permissions (Android 13+)
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    const initializationSettingsAndroid = AndroidInitializationSettings(
      "@mipmap/launcher_icon",
    );
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _localNotifications.initialize(
      onDidReceiveNotificationResponse: onDidReceiveNotification,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveNotification,
      settings: initializationSettings,
    );
  }

  @override
  Future<void> createNotification(PushMessage message) async {
    await _localNotifications.show(
      id: message.hashCode,
      title: message.title,
      body: message.body,
      notificationDetails: _notificationDetails,
      payload: message.deeplink,
    );
  }
}
