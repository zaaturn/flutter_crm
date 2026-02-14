import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@drawable/ic_notification');

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    await _flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          debugPrint("🔔 Notification payload: ${response.payload}");
        }
      },
    );
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'leave_channel',
      'Leave Notifications',
      channelDescription: 'Leave status updates',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload != null ? jsonEncode(payload) : null,
    );
  }
}
