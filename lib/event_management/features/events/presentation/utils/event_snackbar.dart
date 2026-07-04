import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/core/auth/auth_session_redirect.dart';
import 'package:my_app/core/scaffold_messenger_scope.dart';
import 'package:my_app/event_management/features/events/presentation/mobile/mobile_event_theme.dart';

/// Terracotta snackbars + friendly API copy for event management.
abstract final class EventSnackBars {
  static bool _isAuthCopy(String message) {
    final m = message.toLowerCase();
    return m.contains('session expired') ||
        m.contains('please login') ||
        m.contains('please sign in') ||
        m.contains('not authenticated');
  }

  static SnackBar terracotta(String message, {Duration? duration}) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: MobileEventTheme.terracotta,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      duration: duration ?? const Duration(seconds: 4),
      content: Text(
        message,
        style: GoogleFonts.manrope(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: Colors.white,
        ),
      ),
    );
  }

  static void show(String message, {Duration? duration}) {
    if (message.trim().isEmpty) return;
    if (_isAuthCopy(message)) return;
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      terracotta(message, duration: duration),
    );
  }

  static void showFromError(Object? error, {int? statusCode}) {
    if (AuthSessionRedirect.handleIfAuthFailure(error, statusCode: statusCode)) {
      return;
    }
    show(AuthSessionRedirect.displayMessage(error, statusCode: statusCode));
  }

  static void showSuccess(String message) {
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      terracotta(message, duration: const Duration(seconds: 3)),
    );
  }
}

/// Pops [routeContext] then shows a snackbar on the app root messenger.
void popRouteThenShowSnackBar(
  BuildContext routeContext,
  SnackBar snackBar,
) {
  if (!routeContext.mounted) return;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!routeContext.mounted) return;
    final nav = Navigator.of(routeContext);
    if (nav.canPop()) nav.pop();

    rootScaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  });
}
