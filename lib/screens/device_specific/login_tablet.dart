import 'package:flutter/material.dart';
import 'login_mobile.dart';

class LoginTablet extends StatelessWidget {
  final String role;

  const LoginTablet({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 520,
          child: LoginMobile(role: role),
        ),
      ),
    );
  }
}
