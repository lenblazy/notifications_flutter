import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/foundation.dart";

import "../push_handler.dart";
import "../push_message.dart";
import "../push_message_mapper.dart";

@pragma("vm:entry-point")
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final handler = PushHandler((message) {
    debugPrint("Anonymous handler for: ${message.body}");
  });
  await handler.handle(PushMessageMapper().map(message));
}

class AppFirebaseMessagingService {
  AppFirebaseMessagingService({
    required this.pushHandler,
    required this.pushMessageMapper,
  });

  final PushHandler pushHandler;
  final PushMessageMapper pushMessageMapper;

  final _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await _setupMessageHandlers();
  }

  Future<void> _setupMessageHandlers() async {
    FirebaseMessaging.onMessage.listen((message) async {
      await pushHandler.handle(pushMessageMapper.map(message));
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      await _handleBackgroundMessage(initialMessage);
    }
  }

  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    PushMessage pushMsg = pushMessageMapper.map(message);
    await pushHandler.handle(pushMsg);
    debugPrint(pushMsg.toString());
  }
}
