import "package:flutter_local_notifications/flutter_local_notifications.dart";

Future<void> initWorkManagerNotifications({
  FlutterLocalNotificationsPlugin? plugin,
  FlutterLocalNotificationsPlugin Function()? pluginFactory,
}) async {
  const android = AndroidInitializationSettings("@mipmap/launcher_icon");
  const ios = DarwinInitializationSettings();

  const settings = InitializationSettings(android: android, iOS: ios);

  await (plugin ?? (pluginFactory ?? FlutterLocalNotificationsPlugin.new)())
      .initialize(settings: settings);
}

Future<void> showWMNotification({
  required String title,
  required String body,
  String? payload,
  FlutterLocalNotificationsPlugin? plugin,
  FlutterLocalNotificationsPlugin Function()? pluginFactory,
  DateTime Function()? now,
}) async {
  const details = NotificationDetails(
    android: AndroidNotificationDetails(
      "background_channel",
      "High Alerts Notifications",
      channelDescription: "WorkManager background alerts",
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

  await (plugin ?? (pluginFactory ?? FlutterLocalNotificationsPlugin.new)())
      .show(
        id: (now ?? DateTime.now)().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload.toString(),
      );
}
