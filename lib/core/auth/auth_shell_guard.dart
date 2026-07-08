import 'dart:async';

import 'package:flutter/material.dart';

import 'package:my_app/core/auth/auth_session_redirect.dart';
import 'package:my_app/core/auth/jwt_utils.dart';
import 'package:my_app/services/api_client.dart';
import 'package:my_app/services/secure_storage_service.dart';

/// Validates stored tokens before showing a protected shell route (web refresh).
abstract final class AuthSessionBootstrap {
  static const _storageTimeout = Duration(seconds: 12);

  static Future<bool> hasValidSession() async {
    final storage = SecureStorageService();
    String? token;

    try {
      token = await storage.readToken().timeout(_storageTimeout);
    } catch (_) {
      return false;
    }

    final accessExpired =
        token != null && token.isNotEmpty && JwtUtils.isExpired(token);

    if (token != null && token.isNotEmpty && !accessExpired) {
      ApiClient().forceAuthenticated();
      return true;
    }

    String? refresh;
    try {
      refresh = await storage.readRefreshToken().timeout(_storageTimeout);
    } catch (_) {
      return false;
    }

    if (refresh == null || refresh.isEmpty) return false;

    try {
      final ok = await ApiClient().ensureSessionValid(redirectOnFailure: false);
      if (ok) {
        ApiClient().forceAuthenticated();
        return true;
      }
    } catch (_) {}

    return false;
  }
}

/// Blocks protected routes until auth is verified; redirects to login when logged out.
class AuthShellGuard extends StatefulWidget {
  const AuthShellGuard({super.key, required this.child});

  final Widget child;

  @override
  State<AuthShellGuard> createState() => _AuthShellGuardState();
}

class _AuthShellGuardState extends State<AuthShellGuard> {
  bool _allowed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _verify());
  }

  Future<void> _verify() async {
    final ok = await AuthSessionBootstrap.hasValidSession();
    if (!mounted) return;

    if (!ok) {
      await AuthSessionRedirect.logoutAndGoToLogin(context: context);
      return;
    }

    setState(() => _allowed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_allowed) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return widget.child;
  }
}
