import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'api_client.dart';

class NotificationService {
  final ApiClient _api = ApiClient();

  String get _base => _api.baseLeaves;

  final FlutterLocalNotificationsPlugin _local =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (kIsWeb) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _local.initialize(settings);
  }

  Future<void> registerDevice({required String owner}) async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await messaging.getToken();

    if (token == null) return;

    await _sendTokenToBackend(token);
  }

  void listenForTokenRefresh({required String owner}) {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await _sendTokenToBackend(newToken);
    });
  }

  Future<void> _sendTokenToBackend(String token) async {
    await _api.post(
      "$_base/notifications/register-device/",
      body: {
        "fcm_token": token,
        "platform": Platform.isAndroid ? "android" : "ios",
      },
    );
  }

  void listenForegroundMessages(GlobalKey<NavigatorState> navigatorKey) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = message.notification;
      if (notification == null) return;

      const androidDetails = AndroidNotificationDetails(
        'general_notifications',
        'General Notifications',
        importance: Importance.max,
        priority: Priority.high,
      );

      await _local.show(
        message.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(android: androidDetails),
      );
    });
  }

  void handleNotificationTap(GlobalKey<NavigatorState> navigatorKey) {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _navigateFromMessage(message, navigatorKey);
    });
  }

  Future<void> handleInitialMessage(GlobalKey<NavigatorState> navigatorKey) async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) _navigateFromMessage(message, navigatorKey);
  }

  void _navigateFromMessage(RemoteMessage message, GlobalKey<NavigatorState> navigatorKey) {
    final data = message.data;
    if (!data.containsKey('event_id')) return;

    final int eventId = int.tryParse(data['event_id'].toString()) ?? -1;
    if (eventId == -1) return;

    navigatorKey.currentState?.pushNamed(
      '/employeeDashboard',
      arguments: {'openCalendar': true, 'eventId': eventId},
    );
  }
}