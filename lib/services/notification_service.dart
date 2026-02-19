import 'dart:io';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'api_client.dart';

class NotificationService {
  final ApiClient _api = ApiClient();

  /// BASE URL
  String get _base => _api.baseLeaves;

  /// WEB VAPID KEY
  static const String _webVapidKey =
      "BDl2RpvxVJ442k-TJpCoAFHH3SLFxClV7Zy71uNq_MfRJPWTzi5qRkCPztfD2sIq--7LHESRCHbIVZO1ACehWhM";

  /// LOCAL NOTIFICATION
  final FlutterLocalNotificationsPlugin _local =
  FlutterLocalNotificationsPlugin();

  // ─────────────────────────────────────────────
  // INIT (CALL ON APP START)
  // ─────────────────────────────────────────────
  Future<void> init() async {
    if (kIsWeb) return; // local notifications not used on web

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    await _local.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null) return;
      },
    );
  }

  // ─────────────────────────────────────────────
  // REGISTER DEVICE (LOGIN / APP START)
  // ─────────────────────────────────────────────
  Future<void> registerDevice({required String owner}) async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await messaging.getToken(
      vapidKey: kIsWeb ? _webVapidKey : null,
    );

    if (token == null) {
      debugPrint("❌ FCM TOKEN IS NULL ($owner)");
      return;
    }

    debugPrint("🔥 FCM TOKEN [$owner]: $token");

    await _sendTokenToBackend(token);
  }

  // ─────────────────────────────────────────────
  // TOKEN REFRESH
  // ─────────────────────────────────────────────
  void listenForTokenRefresh({required String owner}) {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      debugPrint("🔁 FCM TOKEN REFRESHED [$owner]: $newToken");
      await _sendTokenToBackend(newToken);
    });
  }

  // ─────────────────────────────────────────────
  // SEND TOKEN TO BACKEND
  // ─────────────────────────────────────────────
  Future<void> _sendTokenToBackend(String token) async {
    await _api.post(
      "$_base/notifications/register-device/",
      body: {
        "fcm_token": token,
        "platform": kIsWeb
            ? "web"
            : Platform.isAndroid
            ? "android"
            : "ios",
      },
    );
  }

  // ─────────────────────────────────────────────
  //  FOREGROUND NOTIFICATIONS (FULL FIX)
  // ─────────────────────────────────────────────
  void listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = message.notification;
      if (notification == null) return;

      debugPrint("📩 Foreground push received");


      if (kIsWeb) {
        if (html.Notification.permission == 'granted') {
          html.Notification(
            notification.title ?? 'Notification',
            body: notification.body,
          );
        } else {
          debugPrint("⚠️ Web notification permission not granted");
        }
        return;
      }


      const androidDetails = AndroidNotificationDetails(
        'general_notifications',
        'General Notifications',
        importance: Importance.max,
        priority: Priority.high,
      );

      const details = NotificationDetails(android: androidDetails);

      await _local.show(
        message.hashCode,
        notification.title,
        notification.body,
        details,
        payload: message.data['event_id'],
      );
    });
  }

  // ─────────────────────────────────────────────
  // NOTIFICATION TAP (BACKGROUND / FOREGROUND)
  // ─────────────────────────────────────────────
  void handleNotificationTap(
      GlobalKey<NavigatorState> navigatorKey,
      ) {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _navigateFromMessage(message, navigatorKey);
    });
  }

  // ─────────────────────────────────────────────
  // COLD START (APP KILLED)
  // ─────────────────────────────────────────────
  Future<void> handleInitialMessage(
      GlobalKey<NavigatorState> navigatorKey,
      ) async {
    final message =
    await FirebaseMessaging.instance.getInitialMessage();

    if (message != null) {
      _navigateFromMessage(message, navigatorKey);
    }
  }

  // ─────────────────────────────────────────────
  // COMMON NAVIGATION
  // ─────────────────────────────────────────────
  void _navigateFromMessage(
      RemoteMessage message,
      GlobalKey<NavigatorState> navigatorKey,
      ) {
    final data = message.data;

    if (!data.containsKey('event_id')) return;

    final int eventId =
        int.tryParse(data['event_id'].toString()) ?? -1;

    if (eventId == -1) return;

    navigatorKey.currentState?.pushNamed(
      '/employeeDashboard',
      arguments: {
        'openCalendar': true,
        'eventId': eventId,
      },
    );
  }
}
