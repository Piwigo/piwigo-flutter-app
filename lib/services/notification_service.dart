import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_filex/open_filex.dart';

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
