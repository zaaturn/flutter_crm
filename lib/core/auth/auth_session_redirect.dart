import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';
import 'package:my_app/core/auth/session_expiry_notice_storage.dart';
import 'package:my_app/core/scaffold_messenger_scope.dart';
import 'package:my_app/services/api_client.dart';
import 'package:my_app/services/secure_storage_service.dart';

/// Sends the user to `/employeeLogin` when the backend/session is no longer valid.
class AuthSessionRedirect {
  AuthSessionRedirect._();

  static GlobalKey<NavigatorState>? Function()? _navigatorKey;
  static bool _redirectInProgress = false;
  static String? _pendingSessionMessage;

  static const String loginRoute = '/employeeLogin';

  static const String defaultMessage = 'Session expired. Please login.';

  static const String defaultSubtitle = 'Please sign in again to continue.';

  static const Set<String> _loginRoutes = {
    loginRoute,
    '/adminLogin',
  };

  static void bindNavigator(GlobalKey<NavigatorState> Function() provider) {
    _navigatorKey = provider;
  }

  /// Drop any queued expiry toast (e.g. cold start redirect to login).
  static void discardPendingSessionMessage() {
    _pendingSessionMessage = null;
  }

  /// Call after a successful login so the next expiry can notify again.
  static void clearExpiryNotice() {
    SessionExpiryNoticeStorage.clear();
    discardPendingSessionMessage();
  }

  static bool get _expiryNoticeAlreadyShown =>
      SessionExpiryNoticeStorage.wasShown;

  static bool get isOnLoginRoute {
    final nav = _navigatorKey?.call()?.currentState;
    if (nav == null) return false;
    return _isAlreadyOnLogin(nav);
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
    final raw = messageFrom(error);
    return _friendlyMessage(raw, statusCode: statusCode);
  }

  static String _friendlyMessage(String? raw, {int? statusCode}) {
    if (raw == null || raw.trim().isEmpty) {
      return 'Something went wrong. Please try again.';
    }
    final m = raw.toLowerCase();

    if (m.contains('failed host lookup') ||
        m.contains('connection refused') ||
        m.contains('network is unreachable') ||
        m.contains('socketexception') ||
        m.contains('connection errored') ||
        m.contains('connection error')) {
      return 'Unable to reach the server. Check your internet or API URL.';
    }
    if (m.contains('formatexception') ||
        m.contains('unexpected character') ||
        m.contains('is not valid json') ||
        m.contains('syntaxerror')) {
      return 'Invalid server response. Please check the API URL.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Server error. Please try again later.';
    }
    if (statusCode == 404) {
      return 'Service not found. Please check the API URL.';
    }
    if (raw.startsWith('DioException') ||
        raw.contains('DioException [') ||
        raw.contains('ApiException(')) {
      return 'Request failed. Please check your connection and try again.';
    }
    return raw;
  }

  /// Returns `true` when [error] is an auth failure and redirect was triggered.
  static bool handleIfAuthFailure(Object? error, {int? statusCode}) {
    final code = statusCode ?? extractStatusCode(error);
    if (!isAuthFailure(error, statusCode: code)) return false;
    onAuthFailure(
      error: error,
      statusCode: code,
      notifyUser: ApiClient().isAuthenticated,
    );
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

  /// Call from login screens after mount so the snackbar appears on the login page.
  static void flushPendingSessionSnackBar() {
    final message = _pendingSessionMessage;
    if (message == null || message.isEmpty) return;
    _pendingSessionMessage = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSessionExpiredSnackBar(
        title: message,
        subtitle: defaultSubtitle,
      );
    });
  }

  /// Clears stored auth and opens the login screen (mobile + web).
  static Future<void> forceLogin({
    String? message,
    bool notifyUser = true,
  }) async {
    if (_redirectInProgress) return;
    _redirectInProgress = true;

    final navNow = _navigatorKey?.call()?.currentState;
    final alreadyOnLogin =
        navNow != null && _isAlreadyOnLogin(navNow);
    final shouldNotify = notifyUser &&
        !alreadyOnLogin &&
        !_expiryNoticeAlreadyShown;

    if (shouldNotify) {
      _pendingSessionMessage = message ?? defaultMessage;
    } else {
      _pendingSessionMessage = null;
    }

    try {
      await ApiClient().logout();
      await SecureStorageService().clearAll();
      ApiClient().forceUnauthenticated();
    } catch (_) {}

    void redirect(NavigatorState nav) {
      if (!_isAlreadyOnLogin(nav)) {
        nav.pushNamedAndRemoveUntil(loginRoute, (_) => false);
      }
      if (shouldNotify) {
        flushPendingSessionSnackBar();
      }
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
    bool notifyUser = false,
  }) {
    if (!isAuthFailure(error, statusCode: statusCode)) return;

    unawaited(
      forceLogin(
        message: message ?? defaultMessage,
        notifyUser: notifyUser && !isOnLoginRoute,
      ),
    );
  }

  static void _showSessionExpiredSnackBar({
    required String title,
    required String subtitle,
    int attempt = 0,
  }) {
    final messenger = rootScaffoldMessengerKey.currentState;
    if (messenger == null) {
      if (attempt >= 8) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSessionExpiredSnackBar(
          title: title,
          subtitle: subtitle,
          attempt: attempt + 1,
        );
      });
      return;
    }

    SessionExpiryNoticeStorage.markShown();
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: AdminDashboardTheme.shellMint,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AdminDashboardTheme.border),
        ),
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AdminDashboardTheme.tealLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AdminDashboardTheme.teal.withValues(alpha: 0.25),
                ),
              ),
              child: const Icon(
                Icons.lock_clock_rounded,
                color: AdminDashboardTheme.teal,
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
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AdminDashboardTheme.textDark,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AdminDashboardTheme.textMuted,
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
