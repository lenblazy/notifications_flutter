import "package:flutter_test/flutter_test.dart";
import "package:notifications_flutter/src/di/injector.dart";

void main() {
  test("initNotificationsPackage completes", () {
    expect(initNotificationsPackage, returnsNormally);
  });
}
