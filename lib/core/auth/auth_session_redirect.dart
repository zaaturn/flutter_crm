import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:my_app/core/scaffold_messenger_scope.dart';
import 'package:my_app/services/api_client.dart';
import 'package:my_app/services/secure_storage_service.dart';

/// Sends the user to `/employeeLogin` when the backend/session is no longer valid.
class AuthSessionRedirect {
  AuthSessionRedirect._();

  static GlobalKey<NavigatorState>? Function()? _navigatorKey;
  static bool _redirectInProgress = false;

  static const String loginRoute = '/employeeLogin';

  static const Set<String> _publicRoutes = {
    loginRoute,
    '/',
    '/dashboardChooser',
  };

  static bool _isPublicRoute(String? route) {
    if (route == null || route.isEmpty) return true;
    return _publicRoutes.contains(route);
  }
  static const String defaultMessage =
      'Session expired. Please login again.';

  static void bindNavigator(GlobalKey<NavigatorState> Function() provider) {
    _navigatorKey = provider;
  }

  static bool isAuthFailure(
    Object? error, {
    int? statusCode,
  }) {
    final msg = messageFrom(error)?.toLowerCase() ?? '';
    if (msg.isEmpty) {
      return statusCode == 401;
    }

    return msg.contains('session expired') ||
        msg.contains('no auth token') ||
        msg.contains('not authenticated') ||
        msg.contains('authentication credentials were not provided') ||
        msg.contains('invalid token') ||
        msg.contains('token has expired') ||
        msg.contains('token is invalid') ||
        msg.contains('token not valid') ||
        msg.contains('refresh token') ||
        msg.contains('unauthorized');
  }

  static String? messageFrom(Object? error) {
    if (error == null) return null;
    if (error is String) return error;

    if (error is DioException) {
      final inline = error.error?.toString();
      if (inline != null &&
          inline.isNotEmpty &&
          inline != 'null' &&
          !inline.startsWith('DioException')) {
        return inline;
      }
      final data = error.response?.data;
      if (data is Map) {
        final detail = data['detail'] ?? data['message'] ?? data['error'];
        if (detail != null) return detail.toString();
      }
      if (data is String && data.isNotEmpty) return data;
      return error.message;
    }

    final text = error.toString();
    if (text.startsWith('ApiException')) {
      return text.replaceFirst(RegExp(r'^ApiException\(\d+\):\s*'), '');
    }
    return text;
  }

  /// Clears stored auth and opens the login screen (mobile + web).
  static Future<void> forceLogin({String? message}) async {
    if (_redirectInProgress) return;
    _redirectInProgress = true;

    try {
      await ApiClient().logout();
      await SecureStorageService().clearAll();
      ApiClient().forceUnauthenticated();
    } catch (_) {}

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirectInProgress = false;

      final nav = _navigatorKey?.call()?.currentState;
      if (nav == null) return;

      final currentRoute = ModalRoute.of(nav.context)?.settings.name;
      if (_isPublicRoute(currentRoute)) return;

      final msg = message ?? defaultMessage;

      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(msg)),
      );

      nav.pushNamedAndRemoveUntil(loginRoute, (_) => false);
    });
  }

  static void onAuthFailure({
    Object? error,
    int? statusCode,
    String? message,
  }) {
    if (!isAuthFailure(error, statusCode: statusCode)) return;

    final resolved = (message ?? messageFrom(error) ?? defaultMessage).toLowerCase();
    if (resolved.contains('no auth token')) return;

    unawaited(
      forceLogin(message: message ?? messageFrom(error) ?? defaultMessage),
    );
  }
}
