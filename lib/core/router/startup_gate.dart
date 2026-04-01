import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_app/services/secure_storage_service.dart';

class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  static const _storageTimeout = Duration(seconds: 12);

  Future<void> _checkAuth() async {
    final storage = SecureStorageService();

    String? token;
    String? role;

    try {
      token = await storage.readToken().timeout(_storageTimeout);
      role = await storage.readRole().timeout(_storageTimeout);
    } on TimeoutException {
      token = null;
      role = null;
    } catch (_) {
      token = null;
      role = null;
    }

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/employeeLogin',
            (route) => false,
      );
      return;
    }

    if (role == "admin") {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/adminDashboard',
            (route) => false,
      );
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/employeeDashboard',
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}