import "package:firebase_messaging/firebase_messaging.dart";

import "push_message.dart";

/// An Adapter for 3rd-party library e.g. Firebase to App Specific implementation
///
class PushMessageMapper {
  /// Maps a [RemoteMessage] offered by Firebase to a [PushMessage]
  ///
  /// @param message A firebase object of [RemoteMessage]
  /// @return A [PushMessage] specific to the App implementation
  ///
  PushMessage map(RemoteMessage message) {
    Map<String, dynamic> data = message.data;
    return PushMessage(
      title: data["title"] as String,
      body: data["body"] as String,
      deeplink: data["deeplink"] as String,
      type: data["type"] as String,
    );
  }
}
