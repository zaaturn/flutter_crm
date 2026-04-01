import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'api_client.dart';
import 'notification_payload_router.dart';

class NotificationService {
  final ApiClient _api = ApiClient();

  String get _base => _api.baseLeaves;

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  GlobalKey<NavigatorState>? _navigatorKey;

  static const _androidChannelId = 'crm_push_channel';
  static const _androidChannelName = 'Tasks & events';

  Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    _navigatorKey = navigatorKey;
    if (kIsWeb) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _local.initialize(
      settings,
      onDidReceiveNotificationResponse: _onLocalNotificationResponse,
    );

    const channel = AndroidNotificationChannel(
      _androidChannelId,
      _androidChannelName,
      importance: Importance.high,
      playSound: true,
    );
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _onLocalNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty || _navigatorKey == null) return;
    try {
      final data = NotificationPayloadRouter.normalizeRaw(
        jsonDecode(payload),
      );
      NotificationPayloadRouter.handle(data, _navigatorKey!);
    } catch (_) {}
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
    _navigatorKey = navigatorKey;
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final title = message.notification?.title ??
          message.data['title']?.toString() ??
          'Notification';
      final body = message.notification?.body ??
          message.data['body']?.toString() ??
          '';

      const androidDetails = AndroidNotificationDetails(
        _androidChannelId,
        _androidChannelName,
        importance: Importance.max,
        priority: Priority.high,
      );

      final payload = jsonEncode(message.data);

      await _local.show(
        message.hashCode,
        title,
        body,
        const NotificationDetails(android: androidDetails),
        payload: payload,
      );
    });
  }

  void handleNotificationTap(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _navigateFromMessage(message);
    });
  }

  Future<void> handleInitialMessage(GlobalKey<NavigatorState> navigatorKey) async {
    _navigatorKey = navigatorKey;
    final message = await FirebaseMessaging.instance
        .getInitialMessage()
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () => null,
        );
    if (message != null) _navigateFromMessage(message);
  }

  void _navigateFromMessage(RemoteMessage message) {
    final key = _navigatorKey;
    if (key == null) return;
    final data = Map<String, dynamic>.from(message.data);
    NotificationPayloadRouter.handle(data, key);
  }
}
