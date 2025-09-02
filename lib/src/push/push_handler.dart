import "notification_factory.dart";
import "push_message.dart";

abstract class PushHandler {
  factory PushHandler(void Function(PushMessage) onHandle) {
    return _LambdaPushHandler(onHandle);
  }

  /// Handles a push message contents
  /// @param message the push message model abstraction
  ///
  Future<void> handle(PushMessage message);
}

class _LambdaPushHandler implements PushHandler {
  _LambdaPushHandler(this._onHandle);

  final void Function(PushMessage) _onHandle;

  @override
  Future<void> handle(PushMessage message) async {
    _onHandle(message);
  }
}

class AppPushHandler implements PushHandler {
  AppPushHandler({required this.notificationFactory});

  final NotificationFactory notificationFactory;

  @override
  Future<void> handle(PushMessage message) async {
    await notificationFactory.createNotification(message);
  }
}
