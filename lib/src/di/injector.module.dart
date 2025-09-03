//@GeneratedMicroModule;FlutterNotificationsPackageModule;package:flutter_notifications/src/di/injector.module.dart
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:flutter_notifications/src/di/notifications_module.dart'
    as _i258;
import 'package:flutter_notifications/src/push/firebase/app_firebase_messaging_service.dart'
    as _i870;
import 'package:flutter_notifications/src/push/notification/notification_factory.dart'
    as _i107;
import 'package:flutter_notifications/src/push/push_handler.dart' as _i214;
import 'package:flutter_notifications/src/push/push_message_mapper.dart'
    as _i417;
import 'package:flutter_notifications/src/push/push_token_generator.dart'
    as _i794;
import 'package:injectable/injectable.dart' as _i526;

class FlutterNotificationsPackageModule extends _i526.MicroPackageModule {
// initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) async {
    final notificationsModule = _$NotificationsModule();
    await gh.factoryAsync<_i107.NotificationFactory>(
      () => notificationsModule.notificationsFactory(),
      preResolve: true,
    );
    gh.lazySingleton<_i417.PushMessageMapper>(
        () => notificationsModule.pushMapper());
    gh.lazySingleton<_i794.PushTokenGenerator>(
        () => notificationsModule.tokenGenerator());
    gh.lazySingleton<_i214.PushHandler>(() => notificationsModule.pushHandler(
        factory: gh<_i107.NotificationFactory>()));
    gh.lazySingleton<_i870.AppFirebaseMessagingService>(
        () => notificationsModule.messagingService(
              gh<_i214.PushHandler>(),
              gh<_i417.PushMessageMapper>(),
            ));
  }
}

class _$NotificationsModule extends _i258.NotificationsModule {}
