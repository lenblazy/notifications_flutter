import "package:injectable/injectable.dart";

import "../push/firebase/app_firebase_messaging_service.dart";
import "../push/firebase/firebase_push_token_generator.dart";
import "../push/notification_factory.dart";
import "../push/push_handler.dart";
import "../push/push_message_mapper.dart";
import "../push/push_token_generator.dart";

@module
abstract class NotificationsModule {
  @preResolve
  Future<NotificationFactory> notificationsFactory() async =>
      AppNotificationFactory.create();

  @lazySingleton
  PushHandler pushHandler({required NotificationFactory factory}) =>
      AppPushHandler(notificationFactory: factory);

  @lazySingleton
  PushMessageMapper pushMapper() => PushMessageMapper();

  @lazySingleton
  PushTokenGenerator tokenGenerator() => FirebasePushTokenGenerator();

  @lazySingleton
  AppFirebaseMessagingService messagingService(
    PushHandler handler,
    PushMessageMapper mapper,
  ) => AppFirebaseMessagingService(
    pushHandler: handler,
    pushMessageMapper: mapper,
  );
}
