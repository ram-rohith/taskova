import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;

final FlutterLocalNotificationsPlugin localNotifications =
    FlutterLocalNotificationsPlugin();

bool? notificationGranted = false;

Future<void> initNotificationsSettings() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings iosSettings =
      DarwinInitializationSettings();

  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await localNotifications.initialize(settings: initSettings);
}

Future<void> requestNotificationsPermission() async {
  notificationGranted = await localNotifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.areNotificationsEnabled();
  if (notificationGranted == false || notificationGranted == null) {
    notificationGranted = await localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }
}

Future<void> TriggerNotification({required dateTime, required title}) async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
        'tasks_alerts',
        'scheduled_notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      );
  const NotificationDetails localNotificationDetails = NotificationDetails(
    android: androidNotificationDetails,
  );
  print("task-1");
  await localNotifications.zonedSchedule(
    id: 007,
    title: title,
    body: "test",
    scheduledDate: dateTime,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    notificationDetails: localNotificationDetails,
  );
  print("task-2");
}

Future<void> Notifications({required dateTime, required title}) async {
  if (notificationGranted == true) {
    tz.initializeTimeZones();
    await TriggerNotification(dateTime: dateTime, title: title);
  }
}
