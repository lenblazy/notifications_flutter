import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:notifications_flutter/src/push/notification/notification_factory.dart";
import "package:notifications_flutter/src/push/push_handler.dart";
import "package:notifications_flutter/src/push/push_message.dart";

class MockNotificationFactory extends Mock implements NotificationFactory {}

void main() {
  const message = PushMessage(
    title: "Title",
    body: "Body",
    deeplink: "/details",
    type: "type",
  );

  test("PushHandler factory delegates to callback", () async {
    PushMessage? handled;
    final handler = PushHandler((pushMessage) {
      handled = pushMessage;
    });

    await handler.handle(message);

    expect(handled, message);
  });

  test("AppPushHandler delegates to notification factory", () async {
    final factory = MockNotificationFactory();
    when(() => factory.createNotification(message)).thenAnswer((_) async {});

    await AppPushHandler(notificationFactory: factory).handle(message);

    verify(() => factory.createNotification(message)).called(1);
  });
}
