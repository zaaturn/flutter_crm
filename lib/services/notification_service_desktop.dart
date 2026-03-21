import 'dart:js' as js;
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'api_client.dart';

class NotificationService {
  final ApiClient _api = ApiClient();

  static const String _webVapidKey = "YOUR_KEY";

  Future<void> init() async {}

  Future<void> registerDevice({required String owner}) async {
    final messaging = FirebaseMessaging.instance;

    final token = await messaging.getToken(
      vapidKey: _webVapidKey,
    );

    if (token == null) return;

    await _api.post(
      "${_api.baseLeaves}/notifications/register-device/",
      body: {
        "fcm_token": token,
        "platform": "web",
      },
    );
  }

  void listenForegroundMessages(GlobalKey<NavigatorState> navigatorKey) {
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;

      js.context.callMethod('showWebNotification', [
        notification.title,
        notification.body,
      ]);
    });
  }

  void listenForTokenRefresh({required String owner}) {}

  void handleNotificationTap(GlobalKey<NavigatorState> navigatorKey) {}

  Future<void> handleInitialMessage(GlobalKey<NavigatorState> navigatorKey) async {}
}