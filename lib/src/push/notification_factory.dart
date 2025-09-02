/// Creates a notification
///
abstract class NotificationFactory {
/// Handles creation of a [Notification] object
///
/// @param context [Application Context][Context.getApplicationContext]
/// @param message [Push Message][PushMessage]
///
// Notification createNotification(
// context: Context,
// message: PushMessage,
// ): Notification
}

// class AppNotificationFactory(
// context: Context,
// ) : NotificationFactory {
// init {
// createNotificationChannel(context)
// }
//
// override fun createNotification(
// context: Context,
// message: PushMessage,
// ): Notification {
// val deepLinkUri = message.deeplink.toUri()
//
// val intent =
// Intent(Intent.ACTION_VIEW, deepLinkUri).apply {
// flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
// }
//
// val pendingIntent =
// PendingIntent.getActivity(
// context,
// 0,
// intent,
// PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
// )
//
// val notification =
// NotificationCompat
//     .Builder(context, CHANNEL_ID)
//     .setContentTitle(message.title)
//     .setContentText(message.body)
//     .setSmallIcon(R.drawable.icon)
//     .setPriority(NotificationCompat.PRIORITY_HIGH)
//     .setAutoCancel(true)
//     .setContentIntent(pendingIntent)
//     .build()
//
// if (ActivityCompat.checkSelfPermission(
// context,
// POST_NOTIFICATIONS,
// ) == PERMISSION_GRANTED
// ) {
// NotificationManagerCompat.from(context).notify(NOTIFICATION_ID, notification)
// }
// return notification
// }
//
// private fun createNotificationChannel(context: Context) {
// if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
// val name = "App Channel"
// val importance = NotificationManager.IMPORTANCE_HIGH
// val channel = NotificationChannel(CHANNEL_ID, name, importance)
// NotificationManagerCompat.from(context).createNotificationChannel(channel)
// }
// }
//
// companion object {
// private const val CHANNEL_ID = "app_channel"
// private const val NOTIFICATION_ID = 1001
// }
// }