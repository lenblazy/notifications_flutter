import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/foundation.dart" show ValueChanged;

import "../push_token_generator.dart";

class FirebasePushTokenGenerator implements PushTokenGenerator {
  const FirebasePushTokenGenerator(this._messaging);
  final FirebaseMessaging _messaging;

  @override
  Future<void> generateToken({required ValueChanged<String> onSuccess, required ValueChanged<String> onFailure}) async {
    try {
      final String? token = await _messaging.getToken();
      if (token != null) {
        onSuccess(token);
      } else {
        onFailure("Failed to Fetch Token");
      }
    } catch (e) {
        onFailure(e.toString());
    }
  }

}
