import "package:flutter_test/flutter_test.dart";
import "package:fluttertoast/fluttertoast.dart";
import "package:notifications_flutter/src/push/notification/web_notification_factory.dart";
import "package:notifications_flutter/src/push/push_message.dart";

void main() {
  test("createNotification shows a toast with the message body", () async {
    final calls = <({String msg, ToastGravity gravity})>[];
    final factory = await WebNotificationFactory.create(
      showToast: ({required msg, required gravity}) async {
        calls.add((msg: msg, gravity: gravity));
        return true;
      },
    );

    await factory.createNotification(
      const PushMessage(
        title: "Title",
        body: "Body",
        deeplink: "/details",
        type: "type",
      ),
    );

    expect(calls.single.msg, "Body");
    expect(calls.single.gravity, ToastGravity.TOP_RIGHT);
  });
}
