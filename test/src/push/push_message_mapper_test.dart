import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter_test/flutter_test.dart";
import "package:notifications_flutter/src/push/push_message.dart";
import "package:notifications_flutter/src/push/push_message_mapper.dart";

void main() {
  test("map converts RemoteMessage data to PushMessage", () {
    const message = RemoteMessage(
      data: {
        "title": "Title",
        "body": "Body",
        "deeplink": "/details",
        "type": "info",
      },
    );

    expect(
      PushMessageMapper().map(message),
      const PushMessage(
        title: "Title",
        body: "Body",
        deeplink: "/details",
        type: "info",
      ),
    );
  });
}
