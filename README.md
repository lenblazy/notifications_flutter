# Flutter Notifications

A dart Notifications package that handles Notifications

## Features


## Getting started

### Steps:
1. Run the following command while on the root of your flutter project:
    ```bash
    mkdir -p core/notifications_flutter && cd core/notifications_flutter
    git clone "https://github.com/lenblazy/notifications_flutter.git" .
    flutter pub get
    ```
2. Run the following command to add it as part of the local packages:
    ```bash
   
   flutter pub get
    ```

### Android
---
- Minimum compile SDK supported `35`

- Requires desugaring API on Android
```kotlin
android {
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

- To prevent crash instances on Android 12L and above, add this line to app's build.gradle:
```kotlin
dependencies {
    implementation("androidx.window:window:1.0.0")
    implementation("androidx.window:window-java:1.0.0")
}
```

### Web

Create a `firebase-messaging-sw.js` file in your web folder to handle background messages:

```
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

// Handle background messages
messaging.onBackgroundMessage(async (payload) => {
  console.log('Received background message:', payload);

  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: payload.data,
    click_action: payload.notification.click_action,
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
```

- In your `index.html`, register the service worker:

```
<script>
  if ('serviceWorker' in navigator) {
    window.addEventListener('load', function() {
      navigator.serviceWorker.register('/firebase-messaging-sw.js')
        .then(function(registration) {
          console.log('Service Worker registered with scope:', registration.scope);
        })
        .catch(function(err) {
          console.error('Service Worker registration failed:', err);
        });
    });
  }
</script>
```


## Running Tests

The package utilizes flutter test to run tests.
```bash
flutter test --coverage
coverde report
```

## Generating Dependencies

The package utilizes injectable package for DI:
To generate new dependencies:
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Usage
