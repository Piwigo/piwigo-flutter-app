import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_filex/open_filex.dart';
import 'package:piwigo_ng/services/preferences_service.dart';
import 'package:piwigo_ng/utils/localizations.dart';
import 'package:piwigo_ng/utils/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin localNotification = FlutterLocalNotificationsPlugin();

void initLocalNotifications() {
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings(
    '@mipmap/ic_launcher',
  );
  final initSettings = InitializationSettings(android: initializationSettingsAndroid);
  localNotification.initialize(
    initSettings,
    onDidReceiveNotificationResponse: onSelectNotification,
  );
}

Future<void> onSelectNotification(NotificationResponse response) async {
  debugPrint("Notification payload: ${response.payload}");
  if (response.payload == null) return;
  OpenResult result = await OpenFilex.open(response.payload);
  debugPrint(result.message);
}

Future<bool?> requestPermissions() async {
  return localNotification.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();
}

Future<void> showLocalNotification({
  required int id,
  required String title,
  required String body,
  String? payload,
  AndroidNotificationDetails? details,
}) async {
  final bool? hasPermission = await requestPermissions();
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
  final platform = NotificationDetails(android: android);
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
  await localNotification.show(Settings.uploadNotificationId, title, message, platform);
}

Future<void> showAutoUploadNotification([int nbError = 0, int nbImage = 0]) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (!(prefs.getBool(Preferences.uploadNotificationKey) ?? false)) return;
  final android = AndroidNotificationDetails(
    'piwigo-ng-auto-upload',
    'Piwigo NG Auto Upload',
    channelDescription: 'piwigo-ng',
    priority: Priority.high,
    importance: Importance.high,
  );
  final platform = NotificationDetails(android: android);
  late String title;
  String? message;
  if (nbError == 0 && nbImage > 0) {
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
  await localNotification.show(Settings.autoUploadNotificationId, title, message, platform);
}
