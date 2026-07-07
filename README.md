# Notifications Flutter

`notifications_flutter` is a Flutter package for receiving Firebase push messages and showing local notifications on Android, iOS, and Web.

It wraps:

- `firebase_core`
- `firebase_messaging`
- `flutter_local_notifications`

It also expects the host app to provide an `AppNavigator` from `core_flutter` so notification taps can open deeplinks.

## What This Package Does

- Initializes Firebase Messaging through DI
- Listens for foreground, background, and notification-open events
- Maps Firebase payloads into a `PushMessage`
- Shows local notifications on Android and iOS
- Opens the notification `deeplink` when the user taps the notification

## Requirements

- Flutter project with Firebase already connected
- Android compile SDK `35`
- A host app that registers `AppNavigator` in `GetIt`

## Install

### Option 1: local package

Add the package into your project, for example under `core/notifications_flutter`, then reference it from your app `pubspec.yaml`:

```yaml
dependencies:
  notifications_flutter:
    path: core/notifications_flutter
```

Then run:

```bash
flutter pub get
```

## Firebase Setup

This package depends on Firebase Cloud Messaging, so your host app must already be configured with Firebase.

### Android

Add `android/app/google-services.json`.

### iOS

Add `ios/Runner/GoogleService-Info.plist`.

If your app is not connected to Firebase yet, complete the normal Firebase setup for both platforms before using this package.

## Android Setup

### 1. Set compile SDK and desugaring

In `android/app/build.gradle.kts` or `android/app/build.gradle`, make sure the app uses compile SDK `35` and enables desugaring:

```kotlin
android {
    compileSdk = 35

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

### 2. Add Android 12L window dependency

To avoid known crashes on newer Android versions, add:

```kotlin
dependencies {
    implementation("androidx.window:window:1.0.0")
    implementation("androidx.window:window-java:1.0.0")
}
```

### 3. Add notification permissions

In `android/app/src/main/AndroidManifest.xml`, add:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.VIBRATE" />
```

Inside `<application>`, make sure you are using the Firebase and notification defaults you want. A typical setup is:

```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="high_importance_channel" />
```

### 4. Use the right launcher icon

This package shows notifications with:

```text
@mipmap/launcher_icon
```

Make sure your host app has that icon resource. If your app uses another icon name, update the package code or add a matching launcher icon resource in the app.

## iOS Setup

### 1. Enable Push Notifications

In Xcode:

1. Open `ios/Runner.xcworkspace`
2. Select the `Runner` target
3. Open `Signing & Capabilities`
4. Add `Push Notifications`
5. Add `Background Modes`
6. Enable `Remote notifications`

### 2. Set the minimum iOS version if needed

Make sure your iOS deployment target is compatible with your Firebase and notifications setup. This is usually controlled in:

- `ios/Podfile`
- Xcode project settings

### 3. Request notification permission

The package configures iOS local notification presentation using `DarwinNotificationDetails`, but your app should still explicitly request permission from Firebase Messaging during startup:

```dart
await FirebaseMessaging.instance.requestPermission(
  alert: true,
  badge: true,
  sound: true,
);
```

### 4. APNs and Firebase

Your app must also have APNs configured in the Apple Developer account and linked to Firebase Messaging. Without that, iOS push notifications will not be delivered.

## Web Setup

Create `web/firebase-messaging-sw.js`:

```js
importScripts("https://www.gstatic.com/firebasejs/9.19.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.19.1/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "YOUR_API_KEY",
  appId: "YOUR_APP_ID",
  messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
  projectId: "YOUR_PROJECT_ID",
  authDomain: "YOUR_AUTH_DOMAIN",
  storageBucket: "YOUR_STORAGE_BUCKET",
  measurementId: "YOUR_MEASUREMENT_ID",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(async (payload) => {
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: "/icons/Icon-192.png",
    badge: "/icons/Icon-192.png",
    data: payload.data,
    click_action: payload.notification.click_action,
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
```

Then register it in `web/index.html`:

```html
<script>
  if ("serviceWorker" in navigator) {
    window.addEventListener("load", function () {
      navigator.serviceWorker
        .register("/firebase-messaging-sw.js")
        .then(function (registration) {
          console.log("Service Worker registered with scope:", registration.scope);
        })
        .catch(function (err) {
          console.error("Service Worker registration failed:", err);
        });
    });
  }
</script>
```

## Host App Wiring

This package exports:

- `initNotificationsPackage()`
- `PushHandler`
- `PushMessage`
- `PushTokenGenerator`

### 1. Register your `AppNavigator`

Notification taps call:

```dart
GetIt.I.get<AppNavigator>().toDeepLink(...)
```

So your host app must register an implementation before notifications are used.

Example:

```dart
import "package:core_flutter/core.dart";
import "package:get_it/get_it.dart";

class MyAppNavigator implements AppNavigator {
  @override
  void toDeepLink(String? deeplink) {
    if (deeplink == null || deeplink.isEmpty) return;
    // Handle app navigation here.
  }
}

void setupNavigation() {
  GetIt.I.registerSingleton<AppNavigator>(MyAppNavigator());
}
```

### 2. Initialize DI

If your app uses `injectable`, import the package micro-module and initialize your main injector as usual so the package registrations are included.

The package module is exposed through:

```dart
import "package:notifications_flutter/notifications.dart";
```

### 3. Initialize messaging in app startup

Example startup flow:

```dart
import "package:firebase_core/firebase_core.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/material.dart";
import "package:get_it/get_it.dart";
import "package:notifications_flutter/src/push/firebase/app_firebase_messaging_service.dart";
import "package:notifications_flutter/src/push/push_token_generator.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  setupNavigation();

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  final messagingService = GetIt.I<AppFirebaseMessagingService>();
  await messagingService.initialize();

  final tokenGenerator = GetIt.I<PushTokenGenerator>();
  tokenGenerator.generateToken(
    onSuccess: (token) {
      debugPrint("Push token: $token");
    },
    onFailure: (error) {
      debugPrint("Push token error: $error");
    },
  );

  runApp(const MyApp());
}
```

## Firebase Message Payload Shape

This package maps Firebase `data` payload into:

```dart
PushMessage(
  title: data["title"],
  body: data["body"],
  deeplink: data["deeplink"],
  type: data["type"],
)
```

So your push payload should include these `data` keys:

```json
{
  "title": "New message",
  "body": "Open conversation",
  "deeplink": "/messages/123",
  "type": "chat"
}
```

## Background Notifications Helper

If your app needs local notifications from a background worker, this package also exposes:

```dart
await initWorkManagerNotifications();

await showWMNotification(
  title: "Sync complete",
  body: "Your background task finished",
  payload: "/jobs/42",
);
```

## Common Issues

### Notifications tap but app does not navigate

Make sure:

- `AppNavigator` is registered in `GetIt`
- the payload contains a valid `deeplink`
- your `toDeepLink` implementation handles that route

### Android notifications do not appear

Make sure:

- `POST_NOTIFICATIONS` permission is declared
- the user granted notification permission on Android 13+
- Firebase is configured correctly
- `@mipmap/launcher_icon` exists

### iOS notifications do not arrive

Make sure:

- Push Notifications capability is enabled
- Background Modes > Remote notifications is enabled
- APNs is configured correctly
- Firebase Messaging permission was requested

## Running Tests

```bash
flutter test --coverage
```

## Generating DI Code

```bash
dart run build_runner build --delete-conflicting-outputs
```
