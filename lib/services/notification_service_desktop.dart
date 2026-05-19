import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/event_management/features/notification/presentation/bloc/notification_bloc.dart';

import 'api_client.dart';
import 'notification_payload_router.dart';

/// Web (Chrome / Edge / Firefox): system tray notifications only from
/// [web/firebase-messaging-sw.js] (`onBackgroundMessage`). Foreground [FirebaseMessaging.onMessage]
/// only refreshes the in-app list — avoids duplicate tray toasts (SW + page both calling
/// `showNotification`). When the tab is truly focused, you may see no OS banner; the bell/list still updates.
///
/// Listeners are **replaced** (previous [StreamSubscription.cancel]) so login/admin flows do not stack
/// multiple `onMessage` / `onTokenRefresh` handlers (a common cause of duplicate work or duplicate toasts).
class NotificationService {
  final ApiClient _api = ApiClient();

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedSub;

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
      if (!globalContext.hasProperty('navigator'.toJS).toDart) return;
      final navigator = globalContext.getProperty('navigator'.toJS) as JSObject;
      
      if (!navigator.hasProperty('serviceWorker'.toJS).toDart) return;
      final sw = navigator.getProperty('serviceWorker'.toJS) as JSObject;
      
      if (!sw.hasProperty('ready'.toJS).toDart) return;
      final ready = sw.getProperty('ready'.toJS) as JSPromise;
      
      await ready.toDart;
    } catch (_) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }

  void listenForTokenRefresh({required String owner}) {
    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
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
    _foregroundSub?.cancel();
    _foregroundSub = FirebaseMessaging.onMessage.listen((_) {
      _refreshNotificationList(navigatorKey);
    });
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
    _openedSub?.cancel();
    _openedSub =
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
