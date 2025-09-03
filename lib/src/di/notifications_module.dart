import "package:firebase_core/firebase_core.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/foundation.dart";
import "package:injectable/injectable.dart";

import "../push/firebase/app_firebase_messaging_service.dart";
import "../push/firebase/firebase_push_token_generator.dart";
import "../push/notification/app_notification_factory.dart";
import "../push/notification/notification_factory.dart";
import "../push/notification/web_notification_factory.dart";
import "../push/push_handler.dart";
import "../push/push_message_mapper.dart";
import "../push/push_token_generator.dart";

@module
abstract class NotificationsModule {
  @preResolve
  Future<FirebaseApp> provideFirebaseApp() async => Firebase.initializeApp();

  @lazySingleton
  FirebaseMessaging firebaseMessaging() => FirebaseMessaging.instance;

  @lazySingleton
  PushTokenGenerator tokenGenerator({required FirebaseMessaging messaging}) => FirebasePushTokenGenerator(messaging);

  @preResolve
  Future<NotificationFactory> notificationsFactory() async => kIsWeb
      ? await WebNotificationFactory.create()
      : await AppNotificationFactory.create();

  @lazySingleton
  PushHandler pushHandler({required NotificationFactory factory}) =>
      AppPushHandler(notificationFactory: factory);

  @lazySingleton
  PushMessageMapper pushMapper() => PushMessageMapper();


  @lazySingleton
  AppFirebaseMessagingService messagingService(
    PushHandler handler,
    PushMessageMapper mapper,
  ) => AppFirebaseMessagingService(
    pushHandler: handler,
    pushMessageMapper: mapper,
  );
}
