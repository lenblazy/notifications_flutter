import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:notifications_flutter/src/push/firebase/firebase_push_token_generator.dart";

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

void main() {
  late MockFirebaseMessaging mockMessaging;
  late FirebasePushTokenGenerator generator;

  setUp(() {
    mockMessaging = MockFirebaseMessaging();
    generator = FirebasePushTokenGenerator(mockMessaging);
  });

  test("should call onSuccess when token is retrieved", () async {
    // Arrange
    const testToken = "abc123";
    when(() => mockMessaging.getToken()).thenAnswer((_) async => testToken);

    // Act
    String? result;
    await generator.generateToken(
      onSuccess: (token) => result = token,
      onFailure: (_) {},
    );

    // Assert
    expect(result, testToken);
    verify(() => mockMessaging.getToken()).called(1);
  });

  test("should call onFailure when token is null", () async {
    // Arrange
    when(() => mockMessaging.getToken()).thenAnswer((_) async => null);

    // Act
    String? error;
    await generator.generateToken(
      onSuccess: (_) {},
      onFailure: (err) => error = err,
    );

    // Assert
    expect(error, "Failed to Fetch Token");
    verify(() => mockMessaging.getToken()).called(1);
  });

  test("should call onFailure when exception occurs", () async {
    // Arrange
    when(() => mockMessaging.getToken()).thenThrow(Exception("Error fetching Token"));

    // Act
    String? error;
    await generator.generateToken(
      onSuccess: (_) {},
      onFailure: (err) => error = err,
    );

    // Assert
    expect(error, contains("Error fetching Token"));
    verify(() => mockMessaging.getToken()).called(1);
  });
}
