import 'package:flutter/material.dart';

import 'package:my_app/screens/device_specific/login_mobile.dart';

import 'package:my_app/screens/device_specific/login_tablet.dart';


class LoginPage extends StatelessWidget {
  final String role;

  const LoginPage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;


    if (width >= 700) {
      return LoginTablet(role: role);
    }

    return LoginMobile(role: role);
  }
}
