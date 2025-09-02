import "package:equatable/equatable.dart";

/// Represents a push notification message
///
/// @constructor Creates a new instance of the [PushMessage] class
/// @property title The title of the push notification
/// @property body The body of the push notification
/// @property deeplink The deeplink of the push notification
/// @property type The type of the push notification
///
class PushMessage extends Equatable {
  const PushMessage({
    required this.title,
    required this.body,
    required this.deeplink,
    required this.type,
  });

  final String title;
  final String body;
  final String deeplink;
  final String type;

  @override
  List<Object> get props => [title, body, deeplink, type];
}
