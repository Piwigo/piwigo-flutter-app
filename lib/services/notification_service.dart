import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_filex/open_filex.dart';
import 'package:piwigo_ng/services/locale_provider.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/utils/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin localNotification = FlutterLocalNotificationsPlugin();

Future<void> initLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings(
    '@mipmap/ic_launcher',
  );
  final initSettings = InitializationSettings(android: initializationSettingsAndroid);
  localNotification.initialize(
    initSettings,
    onDidReceiveNotificationResponse: onSelectNotification,
  );
  await askNotificationPermissions();
}

Future<void> onSelectNotification(NotificationResponse response) async {
  debugPrint("Notification payload: ${response.payload}");
  if (response.payload == null) return;
  OpenResult result = await OpenFilex.open(response.payload);
  debugPrint(result.message);
}

Future<bool?> askNotificationPermissions() async {
  return localNotification
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
}

Future<void> showLocalNotification({
  required int id,
  required String title,
  String? body,
  String? payload,
  AndroidNotificationDetails? details,
}) async {
  final bool? hasPermission = await askNotificationPermissions();
  if (hasPermission != null && !hasPermission) {
    return;
  }
  await localNotification.show(
    id,
    title,
    body,
    NotificationDetails(
      android: details ??
          AndroidNotificationDetails(
            'piwigo-ng-notification',
            'Piwigo NG Notification',
            groupKey: 'com.piwigo.piwigo-ng',
            channelDescription: 'Piwigo NG',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
    ),
    payload: payload,
  );
}

Future<void> showUploadNotification([int nbError = 0, int nbImage = 0]) async {
  if (!Preferences.getUploadNotification) return;
  final android = AndroidNotificationDetails(
    'piwigo-ng-upload',
    'Piwigo NG Upload',
    channelDescription: 'piwigo-ng',
    priority: Priority.high,
    importance: Importance.high,
  );
  late String title;
  String? message;
  if (nbError == 0 && nbImage == 0) {
    // Upload cancelled
    title = appStrings.uploadCancelled_title;
  } else if (nbError == 0 && nbImage > 0) {
    // Upload completed
    title = appStrings.imageUploadCompleted_title;
    message = nbImage == 1 ? appStrings.imageUploadCompleted_message : appStrings.imageUploadCompleted_message1;
  } else if (nbError > 0 && nbImage != nbError) {
    // Upload partially completed
    title = appStrings.coreDataStore_WarningTitle;
    message = appStrings.imageUploadCompleted_warning;
  } else {
    // Upload failed
    title = appStrings.uploadError_title;
    message = appStrings.uploadError_message;
  }
  await showLocalNotification(
    id: Settings.uploadNotificationId,
    title: title,
    body: message,
    details: android,
  );
}

Future<void> showAutoUploadNotification([
  int nbError = 0,
  int nbImage = 0,
]) async {
  debugPrint("$nbError / $nbImage");
  // Is auto upload notification enabled
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (!(prefs.getBool(AutoUploadPreferences.notificationKey) ?? false)) return;

  // Find localizations
  Locale locale = Locale(prefs.getString(LocaleNotifier.key) ?? Platform.localeName.split('_').first);
  AppLocalizations backgroundStrings = await AppLocalizations.delegate.load(locale);

  // Init notifications
  final android = AndroidNotificationDetails(
    'piwigo-ng-auto-upload',
    'Piwigo NG Auto Upload',
    channelDescription: 'piwigo-ng',
    priority: Priority.high,
    importance: Importance.high,
  );
  final platform = NotificationDetails(android: android);

  // Create title and message on case
  late String title;
  String? message;
  if (nbError == 0 && nbImage > 0) {
    // Upload completed
    title = backgroundStrings.imageUploadCompleted_title;
    message =
        nbImage == 1 ? backgroundStrings.imageUploadCompleted_message : backgroundStrings.imageUploadCompleted_message1;
  } else if (nbError > 0 && nbImage != nbError) {
    // Upload partially completed
    title = backgroundStrings.coreDataStore_WarningTitle;
    message = backgroundStrings.imageUploadCompleted_warning;
  } else {
    // Upload failed
    title = backgroundStrings.uploadError_title;
    message = backgroundStrings.uploadError_message;
  }

  // Send notification
  await localNotification.show(
    Settings.autoUploadNotificationId,
    title,
    message,
    platform,
  );
}
