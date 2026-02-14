import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHandler {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// INITIALIZE NOTIFICATIONS
  static Future<void> init(BuildContext context) async {
    // ANDROID INIT
    const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@drawable/ic_notification');

    const InitializationSettings initSettings =
    InitializationSettings(android: androidInit);

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          final data = jsonDecode(response.payload!);
          _handleNavigation(context, data);
        }
      },
    );

    // FOREGROUND MESSAGE
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });

    // BACKGROUND → APP OPEN
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNavigation(context, message.data);
    });
  }

  /// SHOW NOTIFICATION WITH CUSTOM UI
  static Future<void> _showNotification(RemoteMessage message) async {
    final title = message.notification?.title ?? "Notification";
    final body = message.notification?.body ?? "";
    final data = message.data;

    final status = data['status'] ?? "pending";

    final AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'leave_channel',
      'Leave Notifications',
      channelDescription: 'Leave status updates',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
      color: status == "approved"
          ? Colors.green
          : status == "rejected"
          ? Colors.red
          : Colors.orange,
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
      ),
    );

    final NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: jsonEncode(data),
    );
  }

  /// HANDLE NAVIGATION ON NOTIFICATION CLICK
  static void _handleNavigation(
      BuildContext context, Map<String, dynamic> data) {
    final type = data['type'];

    if (type == 'leave_status') {
      final leaveId = data['leave_id'];
      final status = data['status'];

      Navigator.pushNamed(
        context,
        '/leaveStatus',
        arguments: {
          'leave_id': leaveId,
          'status': status,
        },
      );
    }
  }
}
