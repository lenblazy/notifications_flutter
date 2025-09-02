import "package:firebase_messaging/firebase_messaging.dart";
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
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> onDidReceiveNotification(
    NotificationResponse notificationResponse,
  ) async {}

  Future<void> init() async {
    const androidInitializationSettings = AndroidInitializationSettings(
      "@mipmap/ic_launcher",
    );

    // const DarwinInitializationSettings darwinInitializationSettings = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotification,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveNotification,
    );

    // Request permission for android
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    ///////////////////
    final _firebaseMessaging = FirebaseMessaging.instance;
    final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

     Future init() async {
      try {
        // Request permission
        NotificationSettings settings = await _firebaseMessaging.requestPermission(
          alert: true,
          announcement: true,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        debugPrint('User granted permission: ${settings.authorizationStatus}');

        if (!kIsWeb) {
          // Initialize local notifications for mobile
          const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
          const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);
          await _flutterLocalNotificationsPlugin.initialize(
            initializationSettings,
            onDidReceiveNotificationResponse: (NotificationResponse response) {
              debugPrint('Notification clicked: ${response.payload}');
              // Handle notification click
            },
          );
        }

        // Initialize foreground handler
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('Got a message whilst in the foreground!');
          debugPrint('Message data: ${message.data}');

          if (message.notification != null) {
            debugPrint('Message notification details: ');
            debugPrint('Title: ${message.notification?.title}');
            debugPrint('Body: ${message.notification?.body}');
            debugPrint('Data: ${message.data}');

            try {
              if (kIsWeb) {
                // showWebNotification(
                //   title: message.notification?.title ?? 'New Notification',
                //   body: message.notification?.body ?? 'You have a new notification',
                //   data: message.data,
                // );
              } else {
                // showSimpleNotification(
                //   title: message.notification?.title ?? 'New Notification',
                //   body: message.notification?.body ?? 'You have a new notification',
                //   payload: message.data.toString(),
                // );
              }
            } catch (e) {
              debugPrint('Error showing notification: $e');
            }
          }
        });

        // Get initial message if app was launched from notification
        RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
        // if (initialMessage != null) {
        //   _handleMessage(initialMessage);
        // }

        // Handle background/terminated state messages
        // FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
        // FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessageHandler);

        // Get FCM token
        // await getFCMToken();

      } catch (e) {
        debugPrint('Error initializing push notifications: $e');
      }
    }


    ///////////////


  }

  @override
  Future<void> createNotification(PushMessage message) async {
    const platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        "channelId",
        "channelName",
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      message.title,
      message.body,
      platformChannelSpecifics,
    );
  }
}
