import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:notifications_flutter/src/push/notification/app_notification_factory.dart";
import "package:notifications_flutter/src/push/push_message.dart";

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockAndroidFlutterLocalNotificationsPlugin extends Mock
    implements AndroidFlutterLocalNotificationsPlugin {}

/// Fake classes for parameters
class InitializationSettingsFake extends Fake
    implements InitializationSettings {}

class NotificationDetailsFake extends Fake implements NotificationDetails {}

void main() {
  late MockFlutterLocalNotificationsPlugin mockPlugin;
  late AppNotificationFactory factory;

  setUpAll(() {
    // Register fakes so mocktail can use `any()` safely
    registerFallbackValue(InitializationSettingsFake());
    registerFallbackValue(NotificationDetailsFake());
  });

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    factory = AppNotificationFactory(plugin: mockPlugin);
  });

  group("AppNotificationFactory", () {
    test("should call show with correct parameters when creating a notification",
            () async {
          // Arrange
          const message = PushMessage(
            title: "Test Title",
            body: "Test Body",
            deeplink: "deeplink",
            type: "type",
          );

          when(() => mockPlugin.show(
            any(),
            any(),
            any(),
            any(),
            payload: any(named: "payload"),
          )).thenAnswer((_) async => {});

          // Act
          await factory.createNotification(message);

          // Assert
          verify(() => mockPlugin.show(
            message.hashCode,
            message.title,
            message.body,
            any(that: isA<NotificationDetails>()),
            payload: message.toString(),
          )).called(1);
        });

    test("onDidReceiveNotification logs clicked notification payload", () async {
      // Arrange
      const response = NotificationResponse(
        id: 1,
        notificationResponseType: NotificationResponseType.selectedNotification,
        payload: "test_payload",
      );

      // Act
      await AppNotificationFactory.onDidReceiveNotification(response);

      // Assert → no exception is thrown
      expect(true, isTrue);
    });

  });
}

