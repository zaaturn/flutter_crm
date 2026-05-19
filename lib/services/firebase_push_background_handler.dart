import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:my_app/firebase_options.dart';

/// Isolate entry for FCM when the app is in background / terminated (Android & iOS).
///
/// - **Notification-payload** FCM: Android shows the system tray using
///   `default_notification_channel_id` in AndroidManifest — that channel must exist.
///   We create `crm_push_channel` here so the first push works even before Flutter UI init.
/// - **Data-only** FCM (same shape as web `firebase-messaging-sw.js`): no system UI unless
///   we post a local notification — mirror title/body from `data`.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@drawable/ic_notification'),
      iOS: DarwinInitializationSettings(),
    ),
  );

  const channel = AndroidNotificationChannel(
    'crm_push_channel',
    'Tasks & events',
    description: 'Tasks & events',
    importance: Importance.high,
    playSound: true,
  );
  await plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  if (message.notification != null) {
    // System/APNs displays this; channel above must match manifest default channel id.
    return;
  }

  final title = message.data['title']?.toString() ?? '';
  final body = message.data['body']?.toString() ??
      message.data['message']?.toString() ??
      '';
  if (title.isEmpty && body.isEmpty) return;

  await plugin.show(
    message.hashCode,
    title.isEmpty ? 'Notification' : title,
    body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'crm_push_channel',
        'Tasks & events',
        channelDescription: 'Tasks & events',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@drawable/ic_notification',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
    payload: jsonEncode(message.data),
  );
}
