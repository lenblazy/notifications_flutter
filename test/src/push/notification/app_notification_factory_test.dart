import "package:core_flutter/core.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get_it/get_it.dart";
import "package:mocktail/mocktail.dart";
import "package:notifications_flutter/src/push/notification/app_notification_factory.dart";
import "package:notifications_flutter/src/push/push_message.dart";

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockAndroidFlutterLocalNotificationsPlugin extends Mock
    implements AndroidFlutterLocalNotificationsPlugin {}

class MockAppNavigator extends Mock implements AppNavigator {}

class FakeNotificationDetails extends Fake implements NotificationDetails {}

class FakeInitializationSettings extends Fake
    implements InitializationSettings {}

void main() {
  late MockFlutterLocalNotificationsPlugin plugin;
  late MockAndroidFlutterLocalNotificationsPlugin androidPlugin;
  late AppNotificationFactory factory;

  setUpAll(() {
    registerFallbackValue(FakeNotificationDetails());
    registerFallbackValue(FakeInitializationSettings());
  });

  setUp(() {
    GetIt.I.reset();
    plugin = MockFlutterLocalNotificationsPlugin();
    androidPlugin = MockAndroidFlutterLocalNotificationsPlugin();
    factory = AppNotificationFactory(plugin: plugin);
    when(
      () => plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >(),
    ).thenReturn(androidPlugin);
    when(
      () => androidPlugin.requestNotificationsPermission(),
    ).thenAnswer((_) async => true);
    when(
      () => plugin.initialize(
        settings: any(named: "settings"),
        onDidReceiveNotificationResponse: any(
          named: "onDidReceiveNotificationResponse",
        ),
        onDidReceiveBackgroundNotificationResponse: any(
          named: "onDidReceiveBackgroundNotificationResponse",
        ),
      ),
    ).thenAnswer((_) async => true);
    when(
      () => plugin.show(
        id: any(named: "id"),
        title: any(named: "title"),
        body: any(named: "body"),
        notificationDetails: any(named: "notificationDetails"),
        payload: any(named: "payload"),
      ),
    ).thenAnswer((_) async {});
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test(
    "createNotification shows local notification with deeplink payload",
    () async {
      const message = PushMessage(
        title: "Test Title",
        body: "Test Body",
        deeplink: "/notifications/1",
        type: "type",
      );

      await factory.createNotification(message);

      verify(
        () => plugin.show(
          id: message.hashCode,
          title: message.title,
          body: message.body,
          notificationDetails: any(named: "notificationDetails"),
          payload: message.deeplink,
        ),
      ).called(1);
    },
  );

  test("onDidReceiveNotification opens the payload deeplink", () async {
    const response = NotificationResponse(
      id: 1,
      notificationResponseType: NotificationResponseType.selectedNotification,
      payload: "/notifications/1",
    );
    String? deeplink;

    await AppNotificationFactory.onDidReceiveNotification(
      response,
      openDeepLink: (value) => deeplink = value,
    );

    expect(deeplink, "/notifications/1");
  });

  test("onDidReceiveNotification uses GetIt navigator by default", () async {
    final navigator = MockAppNavigator();
    GetIt.I.registerSingleton<AppNavigator>(navigator);
    const response = NotificationResponse(
      notificationResponseType: NotificationResponseType.selectedNotification,
      payload: "/notifications/2",
    );

    await AppNotificationFactory.onDidReceiveNotification(response);

    verify(() => navigator.toDeepLink("/notifications/2")).called(1);
  });

  test("create initializes plugin permissions and callbacks", () async {
    final AppNotificationFactory createdFactory = await AppNotificationFactory.create(plugin: plugin);

    expect(createdFactory, isA<AppNotificationFactory>());
    verify(() => androidPlugin.requestNotificationsPermission()).called(1);
    verify(
      () => plugin.initialize(
        settings: any(named: "settings"),
        onDidReceiveNotificationResponse: any(
          named: "onDidReceiveNotificationResponse",
        ),
        onDidReceiveBackgroundNotificationResponse: any(
          named: "onDidReceiveBackgroundNotificationResponse",
        ),
      ),
    ).called(1);
  });

  test(
    "create can build with default plugin when initializer is injected",
    () async {
      AppNotificationFactory? initializedFactory;

      final AppNotificationFactory createdFactory = await AppNotificationFactory.create(
        initializer: (factory) async {
          initializedFactory = factory;
        },
      );

      expect(createdFactory, isA<AppNotificationFactory>());
      expect(initializedFactory, same(createdFactory));
    },
  );
}
