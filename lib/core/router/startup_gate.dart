import 'package:flutter/material.dart';
import 'package:my_app/services/secure_storage_service.dart';

class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final storage = SecureStorageService();
    final token = await storage.readToken();
    final role = await storage.readRole();

    if (!mounted) return;

    if (token == null) {
      Navigator.pushReplacementNamed(context, '/');
    } else {
      if (role == "admin") {
        Navigator.pushReplacementNamed(context, '/adminDashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/employeeDashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}