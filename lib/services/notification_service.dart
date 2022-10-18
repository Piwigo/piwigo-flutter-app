import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';

final FlutterLocalNotificationsPlugin localNotification = FlutterLocalNotificationsPlugin();

void initLocalNotifications() {
  final android = AndroidInitializationSettings('@mipmap/ic_launcher');
  final initSettings = InitializationSettings(android: android);
  localNotification.initialize(
    initSettings,
    onDidReceiveNotificationResponse: onSelectNotification,
  );
}

Future<void> onSelectNotification(NotificationResponse response) async {
  if (response.payload == null) return;
  OpenResult result = await OpenFile.open(response.payload);
  debugPrint(result.message);
}
