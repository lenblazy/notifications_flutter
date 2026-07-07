import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:notifications_flutter/src/background/background_notifications.dart";

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class FakeInitializationSettings extends Fake
    implements InitializationSettings {}

class FakeNotificationDetails extends Fake implements NotificationDetails {}

void main() {
  late MockFlutterLocalNotificationsPlugin plugin;

  setUpAll(() {
    registerFallbackValue(FakeInitializationSettings());
    registerFallbackValue(FakeNotificationDetails());
  });

  setUp(() {
    plugin = MockFlutterLocalNotificationsPlugin();
    when(
      () => plugin.initialize(settings: any(named: "settings")),
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

  test(
    "initWorkManagerNotifications initializes plugin with settings",
    () async {
      await initWorkManagerNotifications(pluginFactory: () => plugin);

      verify(
        () => plugin.initialize(settings: any(named: "settings")),
      ).called(1);
    },
  );

  test("showWMNotification builds and shows a notification", () async {
    final now = DateTime(2026, 7, 7, 10, 0, 0);

    await showWMNotification(
      title: "Title",
      body: "Body",
      payload: "payload",
      pluginFactory: () => plugin,
      now: () => now,
    );

    verify(
      () => plugin.show(
        id: now.millisecondsSinceEpoch ~/ 1000,
        title: "Title",
        body: "Body",
        notificationDetails: any(named: "notificationDetails"),
        payload: "payload",
      ),
    ).called(1);
  });

  test("showWMNotification stringifies null payload", () async {
    final now = DateTime(2026, 7, 7, 10, 0, 1);

    await showWMNotification(
      title: "Title",
      body: "Body",
      pluginFactory: () => plugin,
      now: () => now,
    );

    verify(
      () => plugin.show(
        id: now.millisecondsSinceEpoch ~/ 1000,
        title: "Title",
        body: "Body",
        notificationDetails: any(named: "notificationDetails"),
        payload: "null",
      ),
    ).called(1);
  });
}
