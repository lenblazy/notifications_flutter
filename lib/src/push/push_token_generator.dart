import "package:flutter/foundation.dart" show ValueChanged;

/// Handles generating push tokens.
///
abstract class PushTokenGenerator {
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
