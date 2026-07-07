import "package:fluttertoast/fluttertoast.dart";

import "../../../notifications.dart";
import "notification_factory.dart";

typedef ToastPresenter =
    Future<bool?> Function({
      required String msg,
      required ToastGravity gravity,
    });

class WebNotificationFactory extends NotificationFactory {
  WebNotificationFactory._({ToastPresenter? showToast})
    : _showToast = showToast ?? Fluttertoast.showToast;

  final ToastPresenter _showToast;

  static Future<WebNotificationFactory> create({
    ToastPresenter? showToast,
  }) async {
    final factory = WebNotificationFactory._(showToast: showToast);
    return factory;
  }

  @override
  Future<void> createNotification(PushMessage message) async {
    await _showToast(msg: message.body, gravity: ToastGravity.TOP_RIGHT);
  }
}
