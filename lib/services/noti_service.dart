import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String> behaviorSubject = BehaviorSubject<String>();

  Future<void> init() async {
    await _requestNotificationPermission();
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  Future<void> _requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }

    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  void onDidReceiveNotificationResponse(NotificationResponse response) {
    if (response.payload != null && response.payload!.isNotEmpty) {
      behaviorSubject.add(response.payload!);
    }
  }

  Future<void> scheduleNotificationBefore(int notificationId,
      String taskName, DateTime dateTime, int minutesBefore) async {
    final tz.TZDateTime scheduledTime = tz.TZDateTime.from(
        dateTime.subtract(Duration(minutes: minutesBefore)), tz.local);

    try {
      await _notificationsPlugin.zonedSchedule(
        notificationId,
        "Task Reminder",
        "Your task: $taskName is due in $minutesBefore minutes",
        scheduledTime,
        _notificationDetails(),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint('Notification scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'task_reminder_channel',
        'Task Reminders',
        channelDescription: 'This channel is used for task reminders',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> cancelNotification(int notificationId) async {
    try {
      await _notificationsPlugin.cancel(notificationId);
      debugPrint('Notification cancelled successfully');
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
    }
  }
}
