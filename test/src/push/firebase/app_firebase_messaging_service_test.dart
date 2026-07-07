import "dart:async";

import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/foundation.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:notifications_flutter/src/push/firebase/app_firebase_messaging_service.dart";
import "package:notifications_flutter/src/push/push_handler.dart";
import "package:notifications_flutter/src/push/push_message.dart";
import "package:notifications_flutter/src/push/push_message_mapper.dart";

class MockPushHandler extends Mock implements PushHandler {}

class MockPushMessageMapper extends Mock implements PushMessageMapper {}

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class FakeFirebaseMessagingClient implements FirebaseMessagingClient {
  final onMessageController = StreamController<RemoteMessage>.broadcast();
  final onMessageOpenedAppController =
      StreamController<RemoteMessage>.broadcast();
  BackgroundMessageHandler? registeredHandler;
  RemoteMessage? initialMessage;

  @override
  Stream<RemoteMessage> get onMessage => onMessageController.stream;

  @override
  Stream<RemoteMessage> get onMessageOpenedApp =>
      onMessageOpenedAppController.stream;

  @override
  Future<RemoteMessage?> getInitialMessage() async => initialMessage;

  @override
  void registerOnBackgroundMessage(BackgroundMessageHandler handler) {
    registeredHandler = handler;
  }

  Future<void> dispose() async {
    await onMessageController.close();
    await onMessageOpenedAppController.close();
  }
}

void main() {
  late MockPushHandler pushHandler;
  late MockPushMessageMapper pushMessageMapper;
  late FakeFirebaseMessagingClient messagingClient;
  late List<String> logs;
  const mappedMessage = PushMessage(
    title: "Title",
    body: "Body",
    deeplink: "/details",
    type: "type",
  );

  setUpAll(() {
    registerFallbackValue(const RemoteMessage());
    registerFallbackValue(mappedMessage);
  });

  setUp(() {
    pushHandler = MockPushHandler();
    pushMessageMapper = MockPushMessageMapper();
    messagingClient = FakeFirebaseMessagingClient();
    logs = [];
    when(() => pushMessageMapper.map(any())).thenReturn(mappedMessage);
    when(() => pushHandler.handle(any())).thenAnswer((_) async {});
  });

  tearDown(() async {
    await messagingClient.dispose();
  });

  test("background handler maps message and handles it", () async {
    final remoteMessage = const RemoteMessage(
      data: {
        "title": "Title",
        "body": "Body",
        "deeplink": "/details",
        "type": "type",
      },
    );
    final handled = <PushMessage>[];
    final logged = <String>[];

    await firebaseMessagingBackgroundHandler(
      remoteMessage,
      pushHandler: PushHandler(handled.add),
      logger: logged.add,
    );

    expect(handled.single, mappedMessage);
    expect(logged, isEmpty);
  });

  test(
    "background handler uses default callback logger when handler omitted",
    () async {
      final remoteMessage = const RemoteMessage(
        data: {
          "title": "Title",
          "body": "Body",
          "deeplink": "/details",
          "type": "type",
        },
      );
      final logged = <String>[];

      await firebaseMessagingBackgroundHandler(
        remoteMessage,
        logger: logged.add,
      );

      expect(logged, ["Anonymous handler for: Body"]);
    },
  );

  test(
    "DefaultFirebaseMessagingClient delegates to provided dependencies",
    () async {
      final messaging = MockFirebaseMessaging();
      final onMessage = StreamController<RemoteMessage>.broadcast();
      final onMessageOpenedApp = StreamController<RemoteMessage>.broadcast();
      BackgroundMessageHandler? registeredHandler;
      const initialMessage = RemoteMessage();
      when(
        () => messaging.getInitialMessage(),
      ).thenAnswer((_) async => initialMessage);
      final client = DefaultFirebaseMessagingClient(
        messaging: messaging,
        onMessageStream: onMessage.stream,
        onMessageOpenedAppStream: onMessageOpenedApp.stream,
        onBackgroundMessageRegistrar: (handler) => registeredHandler = handler,
      );

      expect(client.onMessage, isA<Stream<RemoteMessage>>());
      expect(client.onMessageOpenedApp, isA<Stream<RemoteMessage>>());
      expect(await client.getInitialMessage(), initialMessage);
      client.registerOnBackgroundMessage(firebaseMessagingBackgroundHandler);

      verify(() => messaging.getInitialMessage()).called(1);
      expect(registeredHandler, firebaseMessagingBackgroundHandler);
      await onMessage.close();
      await onMessageOpenedApp.close();
    },
  );

  test(
    "DefaultFirebaseMessagingClient supports provider-based defaults",
    () async {
      final messaging = MockFirebaseMessaging();
      final onMessage = StreamController<RemoteMessage>.broadcast();
      final onMessageOpenedApp = StreamController<RemoteMessage>.broadcast();
      BackgroundMessageHandler? registeredHandler;
      when(() => messaging.getInitialMessage()).thenAnswer((_) async => null);
      final client = DefaultFirebaseMessagingClient(
        messagingProvider: () => messaging,
        onMessageStreamProvider: () => onMessage.stream,
        onMessageOpenedAppStreamProvider: () => onMessageOpenedApp.stream,
        onBackgroundMessageRegistrarProvider: () =>
            (handler) => registeredHandler = handler,
      );

      expect(await client.getInitialMessage(), isNull);
      expect(client.onMessage, isA<Stream<RemoteMessage>>());
      expect(client.onMessageOpenedApp, isA<Stream<RemoteMessage>>());
      client.registerOnBackgroundMessage(firebaseMessagingBackgroundHandler);

      expect(registeredHandler, firebaseMessagingBackgroundHandler);
      await onMessage.close();
      await onMessageOpenedApp.close();
    },
  );

  test(
    "DefaultFirebaseMessagingClient can call the built-in registrar",
    () async {
      final messaging = MockFirebaseMessaging();
      when(() => messaging.getInitialMessage()).thenAnswer((_) async => null);
      final client = DefaultFirebaseMessagingClient(
        messagingProvider: () => messaging,
        onMessageStreamProvider: Stream<RemoteMessage>.empty,
        onMessageOpenedAppStreamProvider: Stream<RemoteMessage>.empty,
      );

      expect(
        () => client.registerOnBackgroundMessage(
          firebaseMessagingBackgroundHandler,
        ),
        throwsA(isA<AssertionError>()),
      );
    },
  );

  test(
    "initialize registers background handler and handles foreground messages",
    () async {
      final service = AppFirebaseMessagingService(
        pushHandler: pushHandler,
        pushMessageMapper: pushMessageMapper,
        messagingClient: messagingClient,
        logger: logs.add,
      );

      await service.initialize();
      messagingClient.onMessageController.add(const RemoteMessage());
      await Future<void>.delayed(Duration.zero);

      expect(
        messagingClient.registeredHandler,
        firebaseMessagingBackgroundHandler,
      );
      verify(() => pushMessageMapper.map(any())).called(1);
      verify(() => pushHandler.handle(mappedMessage)).called(1);
      expect(logs, isEmpty);
    },
  );

  test("initialize handles opened-app and initial messages", () async {
    final service = AppFirebaseMessagingService(
      pushHandler: pushHandler,
      pushMessageMapper: pushMessageMapper,
      messagingClient: messagingClient,
      logger: logs.add,
    );
    messagingClient.initialMessage = const RemoteMessage();

    await service.initialize();
    messagingClient.onMessageOpenedAppController.add(const RemoteMessage());
    await Future<void>.delayed(Duration.zero);

    verify(() => pushMessageMapper.map(any())).called(2);
    verify(() => pushHandler.handle(mappedMessage)).called(2);
    expect(logs, [mappedMessage.toString(), mappedMessage.toString()]);
  });

  test("constructor uses messagingClientFactory and default logger", () async {
    final originalDebugPrint = debugPrint;
    final createdClient = FakeFirebaseMessagingClient();
    final remoteMessage = const RemoteMessage();
    final logged = <String?>[];
    debugPrint = (String? message, {int? wrapWidth}) {
      logged.add(message);
    };

    try {
      final service = AppFirebaseMessagingService(
        pushHandler: pushHandler,
        pushMessageMapper: pushMessageMapper,
        messagingClientFactory: () => createdClient,
      );
      createdClient.initialMessage = remoteMessage;

      await service.initialize();

      expect(
        createdClient.registeredHandler,
        firebaseMessagingBackgroundHandler,
      );
      verify(() => pushMessageMapper.map(remoteMessage)).called(1);
      verify(() => pushHandler.handle(mappedMessage)).called(1);
      expect(logged, [mappedMessage.toString()]);
    } finally {
      debugPrint = originalDebugPrint;
      await createdClient.dispose();
    }
  });
}
