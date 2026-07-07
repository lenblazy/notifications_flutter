import "package:firebase_core/firebase_core.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:notifications_flutter/src/di/notifications_module.dart";
import "package:notifications_flutter/src/push/firebase/app_firebase_messaging_service.dart";
import "package:notifications_flutter/src/push/firebase/firebase_push_token_generator.dart";
import "package:notifications_flutter/src/push/notification/app_notification_factory.dart";
import "package:notifications_flutter/src/push/notification/notification_factory.dart";
import "package:notifications_flutter/src/push/notification/web_notification_factory.dart";
import "package:notifications_flutter/src/push/push_handler.dart";
import "package:notifications_flutter/src/push/push_message_mapper.dart";

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class MockNotificationFactory extends Mock implements NotificationFactory {}

class MockFirebaseApp extends Mock implements FirebaseApp {}

class FakeFirebaseMessagingClient implements FirebaseMessagingClient {
  @override
  Future<RemoteMessage?> getInitialMessage() async => null;

  @override
  Stream<RemoteMessage> get onMessage => const Stream.empty();

  @override
  Stream<RemoteMessage> get onMessageOpenedApp => const Stream.empty();

  @override
  void registerOnBackgroundMessage(BackgroundMessageHandler handler) {}
}

void main() {
  late MockFirebaseMessaging firebaseMessaging;
  late MockNotificationFactory webFactory;
  late MockNotificationFactory appFactory;
  late MockFirebaseApp firebaseApp;
  late _TestNotificationsModule module;

  setUp(() {
    firebaseMessaging = MockFirebaseMessaging();
    webFactory = MockNotificationFactory();
    appFactory = MockNotificationFactory();
    firebaseApp = MockFirebaseApp();
    module = _TestNotificationsModule(
      initializeFirebaseApp: () async => firebaseApp,
      firebaseMessagingProvider: () => firebaseMessaging,
      webNotificationFactoryCreator: () async => webFactory,
      appNotificationFactoryCreator: () async => appFactory,
      isWeb: true,
    );
  });

  test("provideFirebaseApp delegates to configured initializer", () async {
    expect(await module.provideFirebaseApp(), firebaseApp);
  });

  test("firebaseMessaging delegates to configured provider", () {
    expect(module.firebaseMessaging(), firebaseMessaging);
  });

  test("tokenGenerator returns FirebasePushTokenGenerator", () {
    expect(
      module.tokenGenerator(messaging: firebaseMessaging),
      isA<FirebasePushTokenGenerator>(),
    );
  });

  test("pushHandler returns AppPushHandler", () {
    expect(
      module.pushHandler(factory: MockNotificationFactory()),
      isA<AppPushHandler>(),
    );
  });

  test("pushMapper returns PushMessageMapper", () {
    expect(module.pushMapper(), isA<PushMessageMapper>());
  });

  test(
    "notificationsFactory returns web factory when configured for web",
    () async {
      expect(await module.notificationsFactory(), webFactory);
    },
  );

  test(
    "notificationsFactory returns app factory when configured for mobile",
    () async {
      final mobileModule = _TestNotificationsModule(
        initializeFirebaseApp: () async => firebaseApp,
        firebaseMessagingProvider: () => firebaseMessaging,
        webNotificationFactoryCreator: () async => webFactory,
        appNotificationFactoryCreator: () async => appFactory,
        isWeb: false,
      );

      expect(await mobileModule.notificationsFactory(), appFactory);
    },
  );

  test("messagingService returns AppFirebaseMessagingService", () {
    final service = module.messagingService(
      PushHandler((_) {}),
      PushMessageMapper(),
      messagingClient: FakeFirebaseMessagingClient(),
    );

    expect(service, isA<AppFirebaseMessagingService>());
  });

  test("default constructor can be created without eagerly bootstrapping", () {
    expect(_TestNotificationsModule.new, returnsNormally);
  });

  test(
    "default firebaseMessaging path currently requires Firebase app setup",
    () {
      final defaultModule = _TestNotificationsModule();

      expect(defaultModule.firebaseMessaging, throwsA(isA<Exception>()));
    },
  );
}

class _TestNotificationsModule extends NotificationsModule {
  _TestNotificationsModule({
    super.initializeFirebaseApp,
    super.firebaseMessagingProvider,
    super.webNotificationFactoryCreator,
    super.appNotificationFactoryCreator,
    super.isWeb,
  });
}
