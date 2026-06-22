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

  static const String defaultMessage =
      'Session expired. Please login again.';

  static const Set<String> _loginRoutes = {
    loginRoute,
    '/adminLogin',
  };

  static void bindNavigator(GlobalKey<NavigatorState> Function() provider) {
    _navigatorKey = provider;
  }

  /// Reads the top route name without popping anything from the stack.
  static String? _topRouteName(NavigatorState nav) {
    String? name;
    nav.popUntil((route) {
      name = route.settings.name;
      return true;
    });
    return name;
  }

  static bool _isAlreadyOnLogin(NavigatorState nav) {
    final name = _topRouteName(nav);
    return name != null && _loginRoutes.contains(name);
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

    void redirect(NavigatorState nav) {
      if (_isAlreadyOnLogin(nav)) return;

      final msg = message ?? defaultMessage;
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(msg)),
      );
      nav.pushNamedAndRemoveUntil(loginRoute, (_) => false);
    }

    void finishRedirect() {
      _redirectInProgress = false;
      final nav = _navigatorKey?.call()?.currentState;
      if (nav != null) {
        redirect(nav);
        return;
      }
      // Navigator may not be mounted yet (e.g. first frame on web).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final retryNav = _navigatorKey?.call()?.currentState;
        if (retryNav != null) redirect(retryNav);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => finishRedirect());
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
