import "package:fluttertoast/fluttertoast.dart";

import "../../../notifications.dart";
import "notification_factory.dart";

class WebNotificationFactory extends NotificationFactory {
  WebNotificationFactory._();

  static Future<WebNotificationFactory> create() async {
    final factory = WebNotificationFactory._();
    return factory;
  }

  @override
  Future<void> createNotification(PushMessage message) async {
    await Fluttertoast.showToast(msg: message.body, gravity: ToastGravity.TOP_RIGHT);
  }
}
