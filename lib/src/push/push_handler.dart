import "push_message.dart";

abstract class PushHandler {
    /// Handles a push message contents
    /// @param message the push message model abstraction
    ///
  void handle(PushMessage message);
}