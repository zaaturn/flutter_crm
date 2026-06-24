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
      'Your session has expired. Redirecting to login...';

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
    if (statusCode == 401 || statusCode == 403) return true;

    final msg = _normalize(messageFrom(error));
    if (msg.isEmpty) return false;

    return msg.contains('session expired') ||
        msg.contains('no auth token') ||
        msg.contains('no token') ||
        msg.contains('token present') ||
        msg.contains('not authenticated') ||
        msg.contains('authentication credentials were not provided') ||
        msg.contains('invalid token') ||
        msg.contains('token has expired') ||
        msg.contains('token is invalid') ||
        msg.contains('token not valid') ||
        msg.contains('token_not_valid') ||
        msg.contains('refresh token') ||
        msg.contains('unauthorized') ||
        msg.contains('given token not valid') ||
        msg.contains('authentication_failed');
  }

  /// User-facing copy for snackbars, dialogs, and bloc error states.
  static String displayMessage(Object? error, {int? statusCode}) {
    if (isAuthFailure(error, statusCode: statusCode)) {
      return defaultMessage;
    }
    return messageFrom(error) ?? 'Something went wrong. Please try again.';
  }

  static String _normalize(String? value) =>
      value?.toLowerCase().trim() ?? '';

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
        final codes = data['code'];
        if (codes != null) return codes.toString();
      }
      if (data is String && data.isNotEmpty) return data;
      return error.message;
    }

    if (error is Map) {
      final detail = error['detail'] ?? error['message'] ?? error['error'];
      if (detail != null) return detail.toString();
      return error.toString();
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

      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(message ?? defaultMessage)),
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

    unawaited(forceLogin(message: defaultMessage));
  }
}
