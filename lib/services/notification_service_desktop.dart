import 'dart:js' as js;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'api_client.dart';
import 'notification_payload_router.dart';

/// Web (Chrome) FCM: foreground uses JS bridge in `web/index.html` (`showWebNotification`).
class NotificationService {
  final ApiClient _api = ApiClient();

  static const String _webVapidKey =
      'BDl2RpvxVJ442k-TJpCoAFHH3SLFxClV7Zy71uNq_MfRJPWTzi5qRkCPztfD2sIq--7LHESRCHbIVZO1ACehWhM';

  GlobalKey<NavigatorState>? _navigatorKey;

  Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    _navigatorKey = navigatorKey;
  }

  Future<void> registerDevice({required String owner}) async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional) {
      return;
    }

    final token = await messaging.getToken(
      vapidKey: _webVapidKey,
    );

    if (token == null) return;

    await _api.post(
      '${_api.baseLeaves}/notifications/register-device/',
      body: {
        'fcm_token': token,
        'platform': 'web',
      },
    );
  }

  void listenForTokenRefresh({required String owner}) {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      try {
        await _api.post(
          '${_api.baseLeaves}/notifications/register-device/',
          body: {
            'fcm_token': newToken,
            'platform': 'web',
          },
        );
      } catch (_) {}
    });
  }

  void listenForegroundMessages(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ??
          message.data['title']?.toString() ??
          'Notification';
      final body = message.notification?.body ??
          message.data['body']?.toString() ??
          '';

      if (title.isEmpty && body.isEmpty) return;

      try {
        js.context.callMethod('showWebNotification', [title, body]);
      } catch (_) {}
    });
  }

  void handleNotificationTap(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    FirebaseMessaging.onMessageOpenedApp.listen(_navigateFromMessage);
  }

  Future<void> handleInitialMessage(GlobalKey<NavigatorState> navigatorKey) async {
    _navigatorKey = navigatorKey;
    try {
      final message = await FirebaseMessaging.instance.getInitialMessage();
      if (message != null) {
        _navigateFromMessage(message);
      }
    } catch (_) {}
  }

  void _navigateFromMessage(RemoteMessage message) {
    final key = _navigatorKey;
    if (key == null) return;
    final data = Map<String, dynamic>.from(message.data);
    NotificationPayloadRouter.handle(data, key);
  }
}
