//@GeneratedMicroModule;NotificationsFlutterPackageModule;package:notifications_flutter/src/di/injector.module.dart
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:firebase_core/firebase_core.dart' as _i982;
import 'package:firebase_messaging/firebase_messaging.dart' as _i892;
import 'package:injectable/injectable.dart' as _i526;
import 'package:notifications_flutter/src/di/notifications_module.dart'
    as _i431;
import 'package:notifications_flutter/src/push/firebase/app_firebase_messaging_service.dart'
    as _i590;
import 'package:notifications_flutter/src/push/notification/notification_factory.dart'
    as _i754;
import 'package:notifications_flutter/src/push/push_handler.dart' as _i82;
import 'package:notifications_flutter/src/push/push_message_mapper.dart'
    as _i216;
import 'package:notifications_flutter/src/push/push_token_generator.dart'
    as _i773;

class NotificationsFlutterPackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) async {
    final notificationsModule = _$NotificationsModule();
    await gh.factoryAsync<_i982.FirebaseApp>(
      () => notificationsModule.provideFirebaseApp(),
      preResolve: true,
    );
    await gh.factoryAsync<_i754.NotificationFactory>(
      () => notificationsModule.notificationsFactory(),
      preResolve: true,
    );
    gh.lazySingleton<_i892.FirebaseMessaging>(
        () => notificationsModule.firebaseMessaging());
    gh.lazySingleton<_i216.PushMessageMapper>(
        () => notificationsModule.pushMapper());
    gh.lazySingleton<_i82.PushHandler>(() => notificationsModule.pushHandler(
        factory: gh<_i754.NotificationFactory>()));
    gh.lazySingleton<_i590.AppFirebaseMessagingService>(
        () => notificationsModule.messagingService(
              gh<_i82.PushHandler>(),
              gh<_i216.PushMessageMapper>(),
            ));
    gh.lazySingleton<_i773.PushTokenGenerator>(() => notificationsModule
        .tokenGenerator(messaging: gh<_i892.FirebaseMessaging>()));
  }
}

class _$NotificationsModule extends _i431.NotificationsModule {}
