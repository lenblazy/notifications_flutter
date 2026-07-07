import "package:flutter_test/flutter_test.dart";
import "package:notifications_flutter/src/push/push_message.dart";

void main() {
  test("PushMessage equality is based on field values", () {
    const first = PushMessage(
      title: "Title",
      body: "Body",
      deeplink: "/details",
      type: "info",
    );
    const second = PushMessage(
      title: "Title",
      body: "Body",
      deeplink: "/details",
      type: "info",
    );
    const third = PushMessage(
      title: "Other",
      body: "Body",
      deeplink: "/details",
      type: "info",
    );

    expect(first, second);
    expect(first.props, ["Title", "Body", "/details", "info"]);
    expect(first, isNot(third));
  });
}
