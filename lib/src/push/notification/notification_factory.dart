import "../push_message.dart";

/// Creates a notification
///
abstract class NotificationFactory {
  /// Handles creation of a [Notification] object
  ///
  /// @param context [Application Context][Context.getApplicationContext]
  /// @param message [Push Message][PushMessage]
  ///
  Future<void> createNotification(PushMessage message);
}


