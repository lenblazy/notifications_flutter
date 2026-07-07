import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/foundation.dart";

import "../push_handler.dart";
import "../push_message.dart";
import "../push_message_mapper.dart";

abstract class FirebaseMessagingClient {
  Stream<RemoteMessage> get onMessage;
  Stream<RemoteMessage> get onMessageOpenedApp;

  Future<RemoteMessage?> getInitialMessage();
  void registerOnBackgroundMessage(BackgroundMessageHandler handler);
}

class DefaultFirebaseMessagingClient implements FirebaseMessagingClient {
  DefaultFirebaseMessagingClient({
    FirebaseMessaging? messaging,
    FirebaseMessaging Function()? messagingProvider,
    Stream<RemoteMessage>? onMessageStream,
    Stream<RemoteMessage> Function()? onMessageStreamProvider,
    Stream<RemoteMessage>? onMessageOpenedAppStream,
    Stream<RemoteMessage> Function()? onMessageOpenedAppStreamProvider,
    void Function(BackgroundMessageHandler handler)?
    onBackgroundMessageRegistrar,
    void Function(BackgroundMessageHandler handler)? Function()?
    onBackgroundMessageRegistrarProvider,
  }) : _messaging = messaging ?? _defaultMessaging(messagingProvider),
       _onMessageStream =
           onMessageStream ?? _defaultOnMessage(onMessageStreamProvider),
       _onMessageOpenedAppStream =
           onMessageOpenedAppStream ??
           _defaultOnMessageOpenedApp(onMessageOpenedAppStreamProvider),
       _onBackgroundMessageRegistrar =
           onBackgroundMessageRegistrar ??
           _defaultOnBackgroundMessageRegistrar(
             onBackgroundMessageRegistrarProvider,
           );

  final FirebaseMessaging _messaging;
  final Stream<RemoteMessage> _onMessageStream;
  final Stream<RemoteMessage> _onMessageOpenedAppStream;
  final void Function(BackgroundMessageHandler handler)
  _onBackgroundMessageRegistrar;

  static FirebaseMessaging _defaultMessaging(
    FirebaseMessaging Function()? messagingProvider,
  ) => (messagingProvider ?? (() => FirebaseMessaging.instance))();

  static Stream<RemoteMessage> _defaultOnMessage(
    Stream<RemoteMessage> Function()? onMessageStreamProvider,
  ) => (onMessageStreamProvider ?? (() => FirebaseMessaging.onMessage))();

  static Stream<RemoteMessage> _defaultOnMessageOpenedApp(
    Stream<RemoteMessage> Function()? onMessageOpenedAppStreamProvider,
  ) =>
      (onMessageOpenedAppStreamProvider ??
      (() => FirebaseMessaging.onMessageOpenedApp))();

  static void Function(BackgroundMessageHandler handler)
  _defaultOnBackgroundMessageRegistrar(
    void Function(BackgroundMessageHandler handler)? Function()?
    onBackgroundMessageRegistrarProvider,
  ) {
    if (onBackgroundMessageRegistrarProvider != null) {
      return onBackgroundMessageRegistrarProvider()!;
    }

    return FirebaseMessaging.onBackgroundMessage;
  }

  @override
  Stream<RemoteMessage> get onMessage => _onMessageStream;

  @override
  Stream<RemoteMessage> get onMessageOpenedApp => _onMessageOpenedAppStream;

  @override
  Future<RemoteMessage?> getInitialMessage() => _messaging.getInitialMessage();

  @override
  void registerOnBackgroundMessage(BackgroundMessageHandler handler) {
    _onBackgroundMessageRegistrar(handler);
  }
}

@pragma("vm:entry-point")
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message, {
  PushHandler? pushHandler,
  PushMessageMapper? pushMessageMapper,
  void Function(String)? logger,
}) async {
  final PushHandler handler =
      pushHandler ??
      PushHandler((mappedMessage) {
        (logger ?? debugPrint)("Anonymous handler for: ${mappedMessage.body}");
      });
  await handler.handle((pushMessageMapper ?? PushMessageMapper()).map(message));
}

class AppFirebaseMessagingService {
  AppFirebaseMessagingService({
    required this.pushHandler,
    required this.pushMessageMapper,
    FirebaseMessagingClient? messagingClient,
    FirebaseMessagingClient Function()? messagingClientFactory,
    void Function(String)? logger,
  }) : _messagingClient =
           messagingClient ??
           (messagingClientFactory ?? DefaultFirebaseMessagingClient.new)(),
       _logger = logger ?? debugPrint;

  final PushHandler pushHandler;
  final PushMessageMapper pushMessageMapper;
  final FirebaseMessagingClient _messagingClient;
  final void Function(String) _logger;

  Future<void> initialize() async {
    _messagingClient.registerOnBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );
    await _setupMessageHandlers();
  }

  Future<void> _setupMessageHandlers() async {
    _messagingClient.onMessage.listen((message) async {
      await pushHandler.handle(pushMessageMapper.map(message));
    });

    _messagingClient.onMessageOpenedApp.listen(_handleBackgroundMessage);

    final RemoteMessage? initialMessage = await _messagingClient.getInitialMessage();
    if (initialMessage != null) {
      await _handleBackgroundMessage(initialMessage);
    }
  }

  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    final PushMessage pushMsg = pushMessageMapper.map(message);
    await pushHandler.handle(pushMsg);
    _logger(pushMsg.toString());
  }
}
