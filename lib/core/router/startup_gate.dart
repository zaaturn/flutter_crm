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

  Future<void> _checkAuth() async {
    final storage = SecureStorageService();

    final token = await storage.readToken();
    final role = await storage.readRole();

    if (!mounted) return;

    if (token == null) {
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