import 'dart:js' as js;
import 'dart:js_util' as js_util;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/event_management/features/notification/presentation/bloc/notification_bloc.dart';

import 'api_client.dart';
import 'notification_payload_router.dart';

/// Web (Chrome / Edge / Firefox): background delivery via [web/firebase-messaging-sw.js];
/// foreground via [FirebaseMessaging.onMessage] and `showWebNotification` in [web/index.html].
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

    await _waitForServiceWorkerReady();

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

  Future<void> _waitForServiceWorkerReady() async {
    try {
      final navigator = js.context['navigator'];
      if (navigator == null) return;
      final sw = js_util.getProperty<Object?>(navigator, 'serviceWorker');
      if (sw == null) return;
      final ready = js_util.callMethod<Object>(sw, 'ready', const []);
      await js_util.promiseToFuture<void>(ready);
    } catch (_) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
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
      final parts = _webNotificationContent(message);
      if (parts.$1.isEmpty && parts.$2.isEmpty) return;

      try {
        js.context.callMethod('showWebNotification', [
          parts.$1,
          parts.$2,
          parts.$3,
          parts.$4,
        ]);
      } catch (_) {}

      _refreshNotificationList(navigatorKey);
    });
  }

  /// (title, body, imageUrl or null, tag)
  (String, String, String?, String) _webNotificationContent(RemoteMessage message) {
    final n = message.notification;
    final d = message.data;
    var title = n?.title ?? _dataStr(d, 'title') ?? _dataStr(d, 'headline') ?? '';
    var body = n?.body ??
        _dataStr(d, 'body') ??
        _dataStr(d, 'message') ??
        _dataStr(d, 'content') ??
        '';
    if (title.isEmpty && body.isEmpty) {
      return ('Notification', 'You have a new message', null, _tagFor(message));
    }
    if (title.isEmpty) title = 'Notification';

    final image = _dataStr(d, 'image') ?? _dataStr(d, 'image_url');
    return (title, body, image, _tagFor(message));
  }

  String? _dataStr(Map<String, dynamic> d, String key) {
    final v = d[key];
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  String _tagFor(RemoteMessage message) {
    final id = (message.messageId ?? '').trim();
    if (id.isNotEmpty) return 'fcm-$id';
    final mid = message.data['message_id'] ?? message.data['fcm_message_id'];
    if (mid != null && mid.toString().isNotEmpty) {
      return 'fcm-${mid.toString()}';
    }
    // Unique fallback so unrelated alerts do not replace each other (SW uses same priority list).
    return 'fcm-${DateTime.now().millisecondsSinceEpoch}';
  }

  void _refreshNotificationList(GlobalKey<NavigatorState> navigatorKey) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) return;
    try {
      ctx.read<NotificationBloc>().add(NotificationLoadRequested());
    } catch (_) {}
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
