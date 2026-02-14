import 'package:flutter/material.dart';
import 'package:my_app/services/secure_storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SecureStorageService _storage = SecureStorageService();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final token = await _storage.readToken();

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      Navigator.pushReplacementNamed(context, '/');
      return;
    }


    final user = await _storage.readUser();
    final role = user?['role']?.toString().toLowerCase();

    if (role == 'admin') {
      Navigator.pushReplacementNamed(context, '/adminDashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/employeeDashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
