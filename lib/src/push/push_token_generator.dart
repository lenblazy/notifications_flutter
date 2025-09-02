import "package:flutter/foundation.dart" show ValueChanged, VoidCallback;

/// Handles generating push tokens.
///
mixin PushTokenGenerator {
  /// Handles generation of a Push Token
  /// Usage: -
  /// generate(
  ///   onSuccess: (token) {
  ///     print("Token: $token");
  ///   },
  ///   onCancel: () {
  ///     print("Cancelled");
  ///   },
  /// );
  void generateToken({
    required ValueChanged<String> onSuccess,
    required ValueChanged<String> onFailure,
  });
}
