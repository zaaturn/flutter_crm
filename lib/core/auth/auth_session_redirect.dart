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

  static const String defaultMessage = 'Session expired';

  static const String defaultSubtitle = 'Redirecting you to sign in…';

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

  /// Returns `true` when [error] is an auth failure and redirect was triggered.
  static bool handleIfAuthFailure(Object? error, {int? statusCode}) {
    final code = statusCode ?? extractStatusCode(error);
    if (!isAuthFailure(error, statusCode: code)) return false;
    onAuthFailure(error: error, statusCode: code);
    return true;
  }

  /// For bloc/cubit `catch` blocks — returns `null` on auth failure so UI stays clean.
  static String? resolveBlocError(Object error, {int? statusCode}) {
    if (handleIfAuthFailure(error, statusCode: statusCode)) return null;
    return displayMessage(error, statusCode: statusCode);
  }

  static int? extractStatusCode(Object? error) {
    if (error is DioException) return error.response?.statusCode;
    try {
      final dynamic value = error;
      final code = value.statusCode ?? value.code;
      if (code is int) return code;
    } catch (_) {}
    return null;
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

      _showSessionExpiredSnackBar(
        title: message ?? defaultMessage,
        subtitle: defaultSubtitle,
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

    unawaited(forceLogin(message: message ?? defaultMessage));
  }

  static void _showSessionExpiredSnackBar({
    required String title,
    required String subtitle,
  }) {
    final messenger = rootScaffoldMessengerKey.currentState;
    if (messenger == null) return;

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 8,
        backgroundColor: const Color(0xFFB71C1C),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.lock_clock_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Colors.white,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFFFCDD2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
