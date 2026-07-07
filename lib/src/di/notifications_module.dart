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
  NotificationsModule({
    Future<FirebaseApp> Function()? initializeFirebaseApp,
    FirebaseMessaging Function()? firebaseMessagingProvider,
    Future<NotificationFactory> Function()? webNotificationFactoryCreator,
    Future<NotificationFactory> Function()? appNotificationFactoryCreator,
    bool? isWeb,
  }) : _initializeFirebaseApp = initializeFirebaseApp ?? Firebase.initializeApp,
       _firebaseMessagingProvider =
           firebaseMessagingProvider ?? (() => FirebaseMessaging.instance),
       _webNotificationFactoryCreator =
           webNotificationFactoryCreator ?? WebNotificationFactory.create,
       _appNotificationFactoryCreator =
           appNotificationFactoryCreator ?? AppNotificationFactory.create,
       _isWeb = isWeb ?? kIsWeb;

  final Future<FirebaseApp> Function() _initializeFirebaseApp;
  final FirebaseMessaging Function() _firebaseMessagingProvider;
  final Future<NotificationFactory> Function() _webNotificationFactoryCreator;
  final Future<NotificationFactory> Function() _appNotificationFactoryCreator;
  final bool _isWeb;

  @preResolve
  Future<FirebaseApp> provideFirebaseApp() async => _initializeFirebaseApp();

  @lazySingleton
  FirebaseMessaging firebaseMessaging() => _firebaseMessagingProvider();

  @lazySingleton
  PushTokenGenerator tokenGenerator({required FirebaseMessaging messaging}) =>
      FirebasePushTokenGenerator(messaging);

  @preResolve
  Future<NotificationFactory> notificationsFactory() async => _isWeb
      ? await _webNotificationFactoryCreator()
      : await _appNotificationFactoryCreator();

  @lazySingleton
  PushHandler pushHandler({required NotificationFactory factory}) =>
      AppPushHandler(notificationFactory: factory);

  @lazySingleton
  PushMessageMapper pushMapper() => PushMessageMapper();

  @lazySingleton
  AppFirebaseMessagingService messagingService(
    PushHandler handler,
    PushMessageMapper mapper, {
    FirebaseMessagingClient? messagingClient,
  }) => AppFirebaseMessagingService(
    pushHandler: handler,
    pushMessageMapper: mapper,
    messagingClient: messagingClient,
  );
}
